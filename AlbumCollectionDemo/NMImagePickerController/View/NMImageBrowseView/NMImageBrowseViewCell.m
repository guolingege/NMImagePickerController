//
//  NMImageBrowseViewCell.m
//  AlbumCollectionDemo
//
//  Created by 孙国林 on 2017/7/20.
//  Copyright © 2017年 孙国林. All rights reserved.
//

#import "NMImageBrowseViewCell.h"
#import "NMImageConfig.h"

@interface NMImageBrowseViewCell ()
<UIScrollViewDelegate, UIGestureRecognizerDelegate>

@end

@implementation NMImageBrowseViewCell {
    UIScrollView *zoomScrollView;
    UIImageView *imageView;
    UIPanGestureRecognizer *panGR;
    CGFloat lastScale;
    CGPoint collectionViewOffset;
    PHImageRequestID requestID;
    UIRotationGestureRecognizer *roGR;
    NSUInteger currentNumberOfTouches;
    CGPoint contentOffsetWhenPanGRBegin;
    CGFloat zoomScaleWhenPanGRBegin;
    BOOL panGRShouldRecognize;
    UIPinchGestureRecognizer *pinchGR;
    /**
     在开始响应之前判断，如果是向上滑动的，则拒绝响应
     */
    UITapGestureRecognizer *singleTapGR;
    UITapGestureRecognizer *doubleTapGR;
    CGPoint panGRBeginLocationInCell;
    CGPoint panGRBeginLocationInScrollView;
    BOOL isDoubleTapped;
    BOOL isToZoomIn;
    BOOL isBeingPaned;
    UIPinchGestureRecognizer *scrollViewPinchGR;
    CGFloat lastValidPanGRVerticalVelocity;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat ww = [UIScreen mainScreen].bounds.size.width;
        CGFloat hh = [UIScreen mainScreen].bounds.size.height;
        
        zoomScrollView = [UIScrollView new];
        zoomScrollView.frame = CGRectMake(NMImageBrowseCollectionViewCellGap * 0.5, 0, ww, hh);
        zoomScrollView.backgroundColor = [UIColor clearColor];
        zoomScrollView.delegate = self;
        zoomScrollView.minimumZoomScale = 1;
        zoomScrollView.maximumZoomScale = 2;
        zoomScrollView.zoomScale = 1;
        zoomScrollView.showsHorizontalScrollIndicator = NO;
        zoomScrollView.showsVerticalScrollIndicator = NO;
        zoomScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
        zoomScrollView.contentMode = UIViewContentModeCenter;
        scrollViewPinchGR = zoomScrollView.gestureRecognizers[2];
        [self.contentView addSubview:zoomScrollView];
        
        imageView = [UIImageView new];
        imageView.frame = [UIScreen mainScreen].bounds;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.userInteractionEnabled = YES;
        [zoomScrollView addSubview:imageView];
        
        panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(collectionViewCellPanned:)];
        panGR.delegate = self;
        [self addGestureRecognizer:panGR];
        
//        roGR = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(collectionViewRotated:)];
//        roGR.delegate = self;
//        [zoomScrollView addGestureRecognizer:roGR];
        
        singleTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewSingleTapped:)];
        singleTapGR.delegate = self;
        [zoomScrollView addGestureRecognizer:singleTapGR];
        
        doubleTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewDoubleTapped:)];
        doubleTapGR.delegate = self;
        doubleTapGR.numberOfTapsRequired = 2;
        [singleTapGR requireGestureRecognizerToFail:doubleTapGR];
        [imageView addGestureRecognizer:doubleTapGR];
        
        panGRShouldRecognize = YES;
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    NSArray *array = touches.allObjects;
    NSUInteger count = 0;
    for (UITouch *touch in array) {
        for (UIGestureRecognizer *GR in touch.gestureRecognizers) {
            if (count < GR.numberOfTouches) {
                count = GR.numberOfTouches;
            }
        }
    }
    [self.delegate imageBrowseCollectionViewCell:self didBeginTouchWithTouchCount:count];
}

- (void)scrollViewSingleTapped:(UITapGestureRecognizer *)sender {
    [self.delegate imageBrowseCollectionViewCellSingleTapped:self];
}

- (void)imageViewDoubleTapped:(UITapGestureRecognizer *)sender {
    isDoubleTapped = YES;
    
    CGFloat zoomScale = zoomScrollView.zoomScale;
    isToZoomIn = zoomScale == 1;
    if (isToZoomIn) {
        zoomScrollView.maximumZoomScale = 999;
        CGFloat newZoomScale = 0;
        
        CGPoint location = [sender locationInView:zoomScrollView];
        // is location1 in image-rect
        CGSize size = self.model.image.size;
        CGFloat ww = [UIScreen mainScreen].bounds.size.width;
        CGFloat hh = [UIScreen mainScreen].bounds.size.height;
        
        CGRect imageViewFrame = imageView.frame;
        imageViewFrame.origin = CGPointZero;
        BOOL isWideImage = size.width / size.height > ww / hh;
        if (isWideImage) {//宽图
            newZoomScale = hh / imageViewFrame.size.height;
            location.y -= (hh - imageViewFrame.size.height) * 0.5;
        } else {//窄图
            newZoomScale = ww / imageViewFrame.size.width;
            location.x -= (ww - imageViewFrame.size.width) * 0.5;
        }
        if (newZoomScale < 2.6) {
            newZoomScale = 2.6;
        }
        
        CGPoint contentOffset = CGPointZero;
        
        CGFloat xsize = ww / newZoomScale;
        CGFloat ysize = hh / newZoomScale;
        CGRect rect = CGRectMake(location.x - xsize/2, location.y - ysize/2, xsize, ysize);
        contentOffset.x = rect.origin.x * newZoomScale;
        contentOffset.y = rect.origin.y * newZoomScale;
        
        if (rect.origin.y <= 0) {//top贴边
            contentOffset.y = 0;
        } else {
            CGFloat gap = CGRectGetMaxY(rect) - CGRectGetMaxY(imageViewFrame);
            if (gap > 0) {//bottom贴边
                contentOffset.y -= gap * newZoomScale;
            }
        }
        if (rect.origin.x <= 0) {//left贴边
            contentOffset.x = 0;
        } else {
            CGFloat gap = CGRectGetMaxX(rect) - CGRectGetMaxX(imageViewFrame);
            if (gap > 0) {//right贴边
                contentOffset.x -= gap * newZoomScale;
            }
        }
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDuration:0.25];
        imageView.frame = imageViewFrame;
        zoomScrollView.zoomScale = newZoomScale;
        zoomScrollView.contentOffset = contentOffset;
        [UIView commitAnimations];
    } else {
        [zoomScrollView setZoomScale:1 animated:YES];
    }
}

- (void)collectionViewCellPanned:(UIPanGestureRecognizer *)sender {
    switch (sender.state) {
        case UIGestureRecognizerStateBegan: {
            isBeingPaned = YES;
            
            panGRBeginLocationInCell = [sender locationInView:self];
            panGRBeginLocationInScrollView = [sender locationInView:zoomScrollView];
            zoomScrollView.minimumZoomScale = 0;
            lastValidPanGRVerticalVelocity = 0;
            zoomScaleWhenPanGRBegin = zoomScrollView.zoomScale;
            contentOffsetWhenPanGRBegin = zoomScrollView.contentOffset;
            
            collectionViewOffset = [self.delegate contentOffsetForCollectionView:self];
            [self.delegate imageBrowseViewCellDidBeginHide:self];
        } break;
        default:
            break;
    }
    
    CGPoint location = [sender locationInView:self];
    CGPoint translation = CGPointMake(location.x - panGRBeginLocationInCell.x, location.y - panGRBeginLocationInCell.y);
    CGFloat distance = sqrtf(powf(translation.x, 2) + powf(translation.y, 2));
    CGFloat diagonal = sqrtf(powf([UIScreen mainScreen].bounds.size.width, 2) + powf([UIScreen mainScreen].bounds.size.height, 2));
    CGFloat rate = powf((1 - distance / diagonal), 1.5);
    CGFloat zoomScale = rate;
    
    zoomScrollView.zoomScale = zoomScale;
    CGPoint locationInScrollView = panGRBeginLocationInScrollView;
    locationInScrollView.x *= zoomScale / zoomScaleWhenPanGRBegin;
    locationInScrollView.y *= zoomScale / zoomScaleWhenPanGRBegin;
    CGFloat xx = location.x - locationInScrollView.x;
    CGFloat yy = location.y - locationInScrollView.y;
    zoomScrollView.contentOffset = CGPointMake(-xx, -yy);
//    NSLog(@"CGPointMake(-xx, -yy):%@", NSStringFromCGPoint(CGPointMake(-xx, -yy)));
    CGFloat vScale = powf(rate, 4);
    [self.delegate imageBrowseViewCellDidBeDragged:self withCollectionViewContentOffset:collectionViewOffset progress:1 - vScale];
    
    translation = [sender velocityInView:zoomScrollView];
    if (translation.y != 0) {
        lastValidPanGRVerticalVelocity = translation.y;
    }
    
    switch (sender.state) {
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            
            isBeingPaned = NO;
            if (lastValidPanGRVerticalVelocity > 0) {//手指向下移动
                [self scaleDown];
            } else {//手指向上移动
                [self scaleUp];
            }
        } break;
            
        default:
            break;
    }
    
}

- (void)collectionViewRotated:(UIRotationGestureRecognizer *)sender {
    CGFloat rotation = sender.rotation;
    if (panGRShouldRecognize) {
        CGAffineTransform ttt0 = CGAffineTransformRotate(zoomScrollView.transform, rotation);
        
        CGFloat bx = CGRectGetMidX(zoomScrollView.frame);
        CGFloat by = CGRectGetMidY(zoomScrollView.frame);
        
        CGPoint anchor = [sender locationInView:zoomScrollView];
        CGFloat ax = anchor.x;
        CGFloat ay = anchor.y;
        CGFloat radius = sqrt(pow(anchor.x - bx, 2) + pow(anchor.y - by, 2));
        
        CGFloat cx = 0, cy = 0;
        
        CGFloat radianB = 0;
        CGFloat bax = bx - ax;
        if (by < ay) {//第一、四象限
            radianB = M_PI * 2.0 - acosf(bax / radius);
        } else {//第二、三象限
            radianB = acosf(bax / radius);
        }
        CGFloat angleB = radianB / M_PI * 180;
        
        CGFloat radianC = radianB + rotation;
        CGFloat angleC = radianC / M_PI * 180 ;
        CGFloat cosC = cos(radianC);
        CGFloat sinC = sin(radianC);
        cx = cosC * radius + ax;
        cy = sinC * radius + ay;

        
        CGFloat tx = cx - bx;
        CGFloat ty = cy - by;
        
        CGAffineTransform ttt1 = CGAffineTransformTranslate(zoomScrollView.transform, tx, ty);
        
        zoomScrollView.transform = CGAffineTransformConcat(ttt0, ttt1);
        
        
        CGFloat rotate;
        
        if (zoomScrollView.transform.b > 0) {
            rotate = acos(zoomScrollView.transform.a);
        } else {
            rotate = M_PI * 2.0 - acos(zoomScrollView.transform.a);
        }
        CGFloat angle = rotate / M_PI * 180;
        CGFloat roAngle = rotation / M_PI * 180;
        NSLog(@"angle:%f, roAngle:%f, angleB:%f, angleC:%f, tx:%f, ty:%f", angle, roAngle, angleB, angleC, tx, ty);
//        zoomScrollView.transform = ttt0;
    }
    sender.rotation = 0;
}

- (void)setImageViewSize:(CGSize)size {
    CGFloat sw = [UIScreen mainScreen].bounds.size.width;
    CGFloat sh = [UIScreen mainScreen].bounds.size.height;
    CGRect rect = CGRectZero;
    if (size.width / size.height > sw / sh) {
        rect.origin.x = 0;
        rect.size.width = sw;
        rect.size.height = rect.size.width / size.width * size.height;
        rect.origin.y = (sh - rect.size.height) * 0.5;
    } else {
        rect.origin.y = 0;
        rect.size.height = sh;
        rect.size.width = rect.size.height / size.height * size.width;
        rect.origin.x = (sw - rect.size.width) * 0.5;
    }
    imageView.frame = rect;
    zoomScrollView.contentSize = rect.size;
}

#pragma mark- Public Methods
- (void)setModel:(NMImageCollectionViewCellModel *)model {
    _model = model;
    CGFloat sw = [UIScreen mainScreen].bounds.size.width;
    CGFloat sh = [UIScreen mainScreen].bounds.size.height;
    
    NMCancelRequest(requestID);
    BOOL needRequest = YES;
    if (model.image) {
        CGFloat scale = model.image.scale;
        CGFloat ww = model.image.size.width * scale;
        CGFloat hh = model.image.size.height * scale;
        scale = [UIScreen mainScreen].scale;
        ww /= scale;
        hh /= scale;
        BOOL flag1 = ww >= sw;
        BOOL flag2 = hh >= sh;
        if (flag1 && flag2) {
            needRequest = NO;
        }
    }
    if (needRequest) {
        CGRect rect = [UIScreen mainScreen].bounds;
        requestID = NMRequestImage(model.asset, rect.size, ^(UIImage *image, NSDictionary *info) {
            imageView.image = image;
            model.info = info;
            model.image = image;
            [self setNeedsLayout];
        });
    } else {
        imageView.image = model.image;
    }
    panGRShouldRecognize = YES;
}

- (void)showOut {
    NMImageCollectionViewCellModel *model = self.model;
    CGRect rect = [self.delegate scaleDownTargetFrameToIndexPath:self.indexPath];
    zoomScrollView.transform = [self.delegate transformWithModel:model targetFrame:rect];
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        zoomScrollView.transform = CGAffineTransformIdentity;
        [self.delegate scaleUpAnimation];
    } completion:^(BOOL finished) {
        
        zoomScrollView.minimumZoomScale = 1;
    }];
}

- (void)scaleDown {
    CGRect rect = [self.delegate scaleDownTargetFrameToIndexPath:self.indexPath];
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        NMImageCollectionViewCellModel *model = self.model;
        zoomScrollView.transform = [self.delegate transformWithModel:model targetFrame:rect];
        zoomScrollView.zoomScale = 1;
        zoomScrollView.contentOffset = CGPointZero;
        [self setImageViewSize:model.image.size];
        
        [self.delegate scaleDownAnimation];
    } completion:^(BOOL finished) {
        [self.delegate scaleDownAnimationCompletion];
    }];
}

- (void)scaleUp {
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        zoomScrollView.zoomScale = zoomScaleWhenPanGRBegin;
        zoomScrollView.contentOffset = contentOffsetWhenPanGRBegin;
        [self.delegate scaleUpAnimation];
    } completion:^(BOOL finished) {
        [self.delegate scaleUpAnimationCompletion];
        zoomScrollView.minimumZoomScale = 1;
    }];
}

- (void)setPanGREnabled:(BOOL)enabled {
    panGRShouldRecognize = enabled;
}

- (CGRect)zoomScrollViewFrame {
    return zoomScrollView.frame;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    zoomScrollView.zoomScale = 1;
    zoomScrollView.contentOffset = CGPointZero;
    if (self.model.image) {
        [self setImageViewSize:self.model.image.size];
    }
}

#pragma mark- UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(__kindof UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == panGR) {
        contentOffsetWhenPanGRBegin = zoomScrollView.contentOffset;
        zoomScaleWhenPanGRBegin = zoomScrollView.zoomScale;
        
        CGFloat verticalVelocity = [panGR velocityInView:zoomScrollView].y;
        if (verticalVelocity < 0) {//如果是向上的，则拒绝响应
            return NO;
        }
        
        if (gestureRecognizer.numberOfTouches > 1) {
            return NO;
        }
        
        CGFloat yy = zoomScrollView.contentOffset.y;
        
        CGFloat range = 3;
        /**
         上侧贴边
         */
        BOOL flag1 = ABS(yy) < range;
        /**
         下侧贴边
         */
        CGRect rrr = [zoomScrollView convertRect:imageView.frame toView:self.contentView];
        CGFloat sh = [UIScreen mainScreen].bounds.size.height;
        BOOL flag3 = ABS(CGRectGetMaxY(rrr) - sh) < range;
        UIPanGestureRecognizer *pan = gestureRecognizer;
        CGPoint translation = [pan translationInView:zoomScrollView];
        BOOL up = translation.y < 0 && ABS(translation.y) > ABS(translation.x);
        BOOL down = translation.y > 0 && ABS(translation.y) > ABS(translation.x);
        BOOL left = translation.x < 0 && ABS(translation.x) > ABS(translation.y);
        BOOL right = translation.x > 0 && ABS(translation.x) > ABS(translation.y);
        
        BOOL flag4 = (flag1 && down) || (flag3 && up);
        if (left || right) {
            return NO;
        } else {
            if (flag4) {
                BOOL flag = zoomScrollView.zoomScale == 1;
                if (!flag) {
                    [zoomScrollView setZoomScale:1 animated:NO];
                }
            } else {
                return NO;
            }
        }
        
    }
    currentNumberOfTouches = gestureRecognizer.numberOfTouches;
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark- UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return imageView;
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    return NO;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    isDoubleTapped = NO;
    isBeingPaned = NO;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if (isDoubleTapped) {
        if (!isToZoomIn) {
            [self setImageViewSize:self.model.image.size];
        }
    } else if (isBeingPaned) {
        //do nothing
    } else {
        CGRect rect = imageView.frame;
        if (rect.origin.y <= 0) {
            return;
        }
        CGPoint contentOffset = scrollView.contentOffset;
        CGFloat ww = [UIScreen mainScreen].bounds.size.width;
        CGFloat hh = [UIScreen mainScreen].bounds.size.height;
        BOOL flag1 = rect.size.width / rect.size.height > ww / hh;
        BOOL flag2 = zoomScrollView.zoomScale <= 1;
        CGFloat gap = fabs(rect.size.width / rect.size.height - ww / hh);
        if (gap < 0.03) {//接近屏幕比例
            rect.origin.x = (scrollView.frame.size.width - rect.size.width) * 0.5;
            rect.origin.y = (scrollView.frame.size.height - rect.size.height) * 0.5;
        } else if (flag1) {//宽图
            rect.origin.y = (scrollView.frame.size.height - rect.size.height) * 0.5;
            if (flag2) {
                rect.origin.x = (scrollView.frame.size.width - rect.size.width) * 0.5;
            }
        } else {//窄图
            rect.origin.x = (scrollView.frame.size.width - rect.size.width) * 0.5;
            if (flag2) {
                rect.origin.y = (scrollView.frame.size.height - rect.size.height) * 0.5;
            }
        }
        
        
        if (rect.origin.y < 0) {
            contentOffset.y = -rect.origin.y;
            rect.origin.y = 0;
        } else {
            contentOffset.y = 0;
        }
        
        imageView.frame = rect;
//        NSLog(@"scrollView.contentOffset:%@", NSStringFromCGPoint(contentOffset));
        scrollView.contentOffset = contentOffset;
    }
}

@end
