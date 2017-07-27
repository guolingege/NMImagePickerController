//
//  NMImageBrowseViewCell.m
//  AlbumCollectionDemo
//
//  Created by 孙国林 on 2017/7/20.
//  Copyright © 2017年 孙国林. All rights reserved.
//

#import "NMImageBrowseViewCell.h"
#import "NMImageConfig.h"

struct _NMImageRadiusChanges {
    CGFloat change0;
    CGFloat change1;
    CGFloat change2;
    CGFloat change3;
    int index;
    CGFloat lastRadius;
};
typedef struct _NMImageRadiusChanges NMImageRadiusChanges;

struct _NMImageLocationChanges {
    CGPoint point0;
    CGPoint point1;
    CGPoint point2;
    int index;
    BOOL panGRShouldStop;
};
typedef struct _NMImageLocationChanges NMImageLocationChanges;

struct _NMImagePanGRDistances {
    CGFloat distance0;
    CGFloat distance1;
    CGFloat distance2;
    CGFloat distance3;
    int index;
};
typedef struct _NMImagePanGRDistances NMImagePanGRDistances;

@interface NMImageBrowseViewCell ()
<UIScrollViewDelegate, UIGestureRecognizerDelegate>

@end

@implementation NMImageBrowseViewCell {
    UIScrollView *zoomScrollView;
    UIImageView *imageView;
    UIPanGestureRecognizer *panGR;
    CGFloat lastScale;
    NMImageRadiusChanges radiusChanges;
    NMImageLocationChanges locationChanges;
    CGPoint collectionViewOffset;
    PHImageRequestID requestID;
    UIRotationGestureRecognizer *roGR;
    NSUInteger currentNumberOfTouches;
    CGPoint contentOffsetWhenPanGRBegin;
    CGFloat zoomScaleWhenPanGRBegin;
    BOOL panGRShouldRecognize;
    UIPinchGestureRecognizer *pinchGR;
    UITapGestureRecognizer *singleTapGR;
    UITapGestureRecognizer *doubleTapGR;
    CGPoint panGRBeginLocationInCell;
    CGPoint panGRBeginLocationInScrollView;
    NMImagePanGRDistances panGRDistances;
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
        zoomScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        zoomScrollView.clipsToBounds = NO;
        [self.contentView addSubview:zoomScrollView];
        
        imageView = [UIImageView new];
        imageView.frame = [UIScreen mainScreen].bounds;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [zoomScrollView addSubview:imageView];
        
        panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(collectionViewPanned:)];
        panGR.delegate = self;
        [self addGestureRecognizer:panGR];
        
//        roGR = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(collectionViewRotated:)];
//        roGR.delegate = self;
//        [zoomScrollView addGestureRecognizer:roGR];
        
        singleTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewSingleTapped:)];
        singleTapGR.delegate = self;
        [zoomScrollView addGestureRecognizer:singleTapGR];
        
        doubleTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
        doubleTapGR.delegate = self;
        doubleTapGR.numberOfTapsRequired = 2;
        [singleTapGR requireGestureRecognizerToFail:doubleTapGR];
        [zoomScrollView addGestureRecognizer:doubleTapGR];
        
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

- (void)setModel:(NMImageCollectionViewCellModel *)model {
    _model = model;
    NMCancelRequest(requestID);
    BOOL needRequest = YES;
    if (model.image) {
        CGFloat scale = model.image.scale;
        CGFloat ww = model.image.size.width * scale;
        CGFloat hh = model.image.size.height * scale;
        scale = [UIScreen mainScreen].scale;
        ww /= scale;
        hh /= scale;
        BOOL flag1 = ww >= [UIScreen mainScreen].bounds.size.width;
        BOOL flag2 = hh >= [UIScreen mainScreen].bounds.size.height;
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
        });
    } else {
        imageView.image = model.image;
    }
    panGRShouldRecognize = YES;
}

- (void)scrollViewSingleTapped:(UITapGestureRecognizer *)sender {
    [self.delegate imageBrowseCollectionViewCellSingleTapped:self];
}

- (void)scrollViewDoubleTapped:(UITapGestureRecognizer *)sender {
    CGPoint location = [sender locationInView:zoomScrollView];
    // is location1 in image-rect
    CGSize size = self.model.image.size;
    CGFloat rate1 = size.height / size.width;
    CGFloat rate0 = [UIScreen mainScreen].bounds.size.height / [UIScreen mainScreen].bounds.size.width;
    /**
     YES : 图片比屏幕瘦, NO : 图片比屏幕扁
     */
    BOOL flag0 = rate1 > rate0;
    CGFloat zoomScale = zoomScrollView.zoomScale;
//    CGPoint offset = zoomScrollView.contentOffset;
    CGFloat ww = zoomScrollView.frame.size.width;
    CGFloat hh = zoomScrollView.frame.size.height;
    CGRect imageRect;
    if (flag0) {
        imageRect.origin.y = 0;
        imageRect.size.height = hh * zoomScale;
        imageRect.size.width = imageRect.size.height / rate1;
        imageRect.origin.x = (ww * zoomScale - imageRect.size.width) * 0.5;
    } else {
        imageRect.origin.x = 0;
        imageRect.size.width = ww * zoomScale;
        imageRect.size.height = imageRect.size.width * rate1;
        imageRect.origin.y = (hh * zoomScale - imageRect.size.height) * 0.5;
    }
    BOOL flag1 = CGRectContainsPoint(imageRect, location);
    if (flag1) {
        zoomScrollView.maximumZoomScale = 999;
        BOOL flag2 = zoomScale == 1;
        if (flag2) {
            CGFloat gap = 50;
            CGFloat minimumScale = 2.6;
            
            CGFloat scale;
            CGFloat xx;
            CGFloat yy;
            /**
             图片比例是否接近屏幕
             */
            BOOL flag3 = ABS(rate1 - rate0) < 0.03;
            if (flag3) {
                if (location.x < gap) {
                    location.x = 0;
                } else if (location.x > ww - gap) {
                    location.x = ww;
                }
                
                if (location.y < gap) {
                    location.y = 0;
                } else if (location.y > hh - gap) {
                    location.y = hh;
                }
                scale = minimumScale;
                xx = (scale - 1) * location.x;
                yy = (scale - 1) * location.y;
            } else {
                if (flag0) {
                    if (location.y < gap) {
                        location.y = 0;
                    } else if (location.y > hh - gap) {
                        location.y = hh;
                    }
                    scale = ww * zoomScale / imageRect.size.width;
                    if (scale < minimumScale) {
                        scale = minimumScale;
                        xx = (scale - 1) * location.x;
                        yy = (scale - 1) * location.y;
                    } else {
                        xx = (ww - imageRect.size.width / zoomScale) * 0.5 * scale;
                        yy = (scale - 1) * location.y;
                    }
                } else {
                    if (location.x < gap) {
                        location.x = 0;
                    } else if (location.x > ww - gap) {
                        location.x = ww;
                    }
                    scale = hh * zoomScale / imageRect.size.height;
                    if (scale < minimumScale) {
                        scale = minimumScale;
                        xx = (scale - 1) * location.x;
                        yy = (scale - 1) * location.y;
                    } else {
                        xx = (scale - 1) * location.x;
                        yy = (hh - imageRect.size.height / zoomScale) * 0.5 * scale;
                    }
                }
            }
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.25];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            zoomScrollView.zoomScale = scale;
            zoomScrollView.contentOffset = CGPointMake(xx, yy);
            [UIView commitAnimations];
        } else {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.25];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            zoomScrollView.zoomScale = 1;
            zoomScrollView.contentOffset = CGPointZero;
            [UIView commitAnimations];
        }
    } else {
        [self.delegate imageBrowseCollectionViewCellSingleTapped:self];
    }
}

- (void)collectionViewPanned:(UIPanGestureRecognizer *)sender {
    {
        
        switch (sender.state) {
            case UIGestureRecognizerStateBegan: {
                panGRBeginLocationInCell = [sender locationInView:self];
                panGRBeginLocationInScrollView = [sender locationInView:zoomScrollView];
                zoomScrollView.minimumZoomScale = 0;
                
                panGRDistances.distance0 = 0;
                panGRDistances.distance1 = 0;
                panGRDistances.distance2 = 0;
                panGRDistances.distance3 = 0;
                panGRDistances.index = 0;
                
                zoomScaleWhenPanGRBegin = zoomScrollView.zoomScale;
                contentOffsetWhenPanGRBegin = zoomScrollView.contentOffset;
                
                collectionViewOffset = [self.delegate contentOffsetForCollectionView:self];
                [self.delegate imageBrowseViewCellDidBeginHide:self];
            } break;
                
            case UIGestureRecognizerStateEnded:
            case UIGestureRecognizerStateCancelled:
            case UIGestureRecognizerStateFailed: {
            } break;
                
            default:
                break;
        }
        
        CGPoint location = [sender locationInView:self];
        CGPoint translation = CGPointMake(location.x - panGRBeginLocationInCell.x, location.y - panGRBeginLocationInCell.y);
        CGFloat distance = sqrtf(powf(translation.x, 2) + powf(translation.y, 2));
        CGFloat diagonal = sqrtf(powf([UIScreen mainScreen].bounds.size.width, 2) + powf([UIScreen mainScreen].bounds.size.height, 2));
        CGFloat rate = 1 - distance / diagonal;
        CGFloat zoomScale = rate;
        
        zoomScrollView.zoomScale = zoomScale;
        CGPoint locationInScrollView = panGRBeginLocationInScrollView;
        locationInScrollView.x *= zoomScale;
        locationInScrollView.y *= zoomScale;
        CGFloat xx = location.x - locationInScrollView.x;
        CGFloat yy = location.y - locationInScrollView.y;
        zoomScrollView.contentOffset = CGPointMake(-xx, -yy);
        
        CGFloat vScale = powf(rate, 4);
        [self.delegate imageBrowseViewCellDidBeDragged:self withCollectionViewContentOffset:collectionViewOffset progress:1 - vScale];
        
        switch (panGRDistances.index) {
            case 0:
                panGRDistances.distance0 = distance;
                break;
            case 1:
                panGRDistances.distance1 = distance;
                break;
            case 2:
                panGRDistances.distance2 = distance;
                break;
            case 4:
                panGRDistances.distance3 = distance;
                break;
                
            default:
                break;
        }
        
        panGRDistances.index++;
        panGRDistances.index = panGRDistances.index % 4;
        
        switch (sender.state) {
            case UIGestureRecognizerStateEnded:
            case UIGestureRecognizerStateCancelled: {
                CGFloat v0 = MAX(panGRDistances.distance0, panGRDistances.distance1);
                CGFloat v1 = MAX(panGRDistances.distance2, panGRDistances.distance3);
                BOOL flag = distance == MAX(v0, v1);
                if (flag) {
                    [self scaleDown];
                } else {
                    [self scaleUp];
                }
            } break;
                
            default:
                break;
        }
    }
    
    return;
    switch (sender.state) {
        case UIGestureRecognizerStateBegan: {
            if (!panGRShouldRecognize) {
                return;
            }
            locationChanges.index = 0;
            locationChanges.panGRShouldStop = YES;
            collectionViewOffset = [self.delegate contentOffsetForCollectionView:self];
//            zoomScrollView.minimumZoomScale = 0;
            lastScale = 1;
        } break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed: {
//            zoomScrollView.minimumZoomScale = 1;
            panGRShouldRecognize = YES;
        } break;
            
        default:
            if (!panGRShouldRecognize) {
                return;
            }
            break;
    }
    
    if (locationChanges.panGRShouldStop) {
        if (locationChanges.index > 2) {
            return;
        }
        NSUInteger ii = locationChanges.index;
        locationChanges.index++;
        CGPoint point = [sender translationInView:zoomScrollView];
        switch (ii) {
            case 0:
                locationChanges.point0 = point;
                for (UIGestureRecognizer *gr in [self.delegate gesturesInCollectionView]) {
                    if (gr != panGR) {
                        gr.enabled = YES;
                    }
                }
                return;
            case 1:
                locationChanges.point1 = point;
                return;
            case 2: {
                locationChanges.point2 = point;
                
                CGFloat sumX = ABS(locationChanges.point0.x + locationChanges.point1.x + locationChanges.point2.x) * 1.5;
                CGFloat sumY = ABS(locationChanges.point0.y + locationChanges.point1.y + locationChanges.point2.y);
                
                locationChanges.panGRShouldStop = sumX > sumY;
                if (locationChanges.panGRShouldStop) {
                    panGRShouldRecognize = NO;
                    return;
                } else {
                    [self.delegate imageBrowseViewCellDidBeginHide:self];
                }
            }
            default:
                break;
        }
    }
    
    CGAffineTransform transform;
    //移动
    {
        CGPoint point2 = [sender translationInView:zoomScrollView];
        transform = CGAffineTransformTranslate(zoomScrollView.transform, point2.x, point2.y);
    }
    
    CGFloat radius;
    //计算拖动手势位移长度
    {
        CGFloat gapXp = powf(zoomScrollView.transform.tx, 2);
        CGFloat gapYp = powf(zoomScrollView.transform.ty, 2);
        radius = sqrtf(gapXp + gapYp);
    }
    
    BOOL flag = currentNumberOfTouches == 1;
    //缩放
    if (flag) {
        zoomScrollView.zoomScale = zoomScaleWhenPanGRBegin;
        zoomScrollView.contentOffset = contentOffsetWhenPanGRBegin;
        
        CGFloat ww = [UIScreen mainScreen].bounds.size.width;
        CGFloat hh = [UIScreen mainScreen].bounds.size.height;
        CGFloat diagonal = sqrtf(ww * ww + hh * hh);
        CGFloat scale = 1 - radius / diagonal * 0.9;
        
        //        zoomScrollView.zoomScale = scale;
        CGAffineTransform t2 = CGAffineTransformScale(CGAffineTransformIdentity, scale / lastScale, scale / lastScale);
        transform = CGAffineTransformConcat(transform, t2);
        lastScale = scale;
        
        CGFloat vScale = powf(scale, 6.5);
//        NSLog(@"tx:%.9f, ty:%.9f, scale:%.9f, vScale:%.9f", zoomScrollView.transform.tx, zoomScrollView.transform.ty, scale, vScale);
        [self.delegate imageBrowseViewCellDidBeDragged:self withCollectionViewContentOffset:collectionViewOffset progress:1 - vScale];
    }
    
    //修改tranform
    {
        
//        zoomScrollView.transform = transform;
    }
    
    //计算拖动手势结束前一刻移动方向
    if (flag) {
        switch (radiusChanges.index) {
            case 0:
                radiusChanges.change0 = radius - radiusChanges.lastRadius;
                break;
            case 1:
                radiusChanges.change1 = radius - radiusChanges.lastRadius;
                break;
            case 2:
                radiusChanges.change2 = radius - radiusChanges.lastRadius;
                break;
            case 3:
                radiusChanges.change3 = radius - radiusChanges.lastRadius;
                break;
                
            default:
                break;
        }
        
        radiusChanges.index++;
        radiusChanges.index = radiusChanges.index % 4;
        CGFloat sum = radiusChanges.change0 + radiusChanges.change1 + radiusChanges.change2 + radiusChanges.change3;
        
        /**
         大于0 则的代表图片在远离中心位置 需要图片变小
         */
        BOOL flag = sum  > 0;
        
        switch (sender.state) {
            case UIGestureRecognizerStateEnded:
            case UIGestureRecognizerStateCancelled:
                if (flag) {
                    [self scaleDown];
                } else {
                    [self scaleUp];
                }
                break;
                
            default:
                break;
        }
        
        radiusChanges.lastRadius = radius;
    }
    
    [sender setTranslation:CGPointZero inView:zoomScrollView];
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

#pragma mark- Public Methods
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
    CGFloat rate0 = rect.size.height / rect.size.width;
    CGSize size = self.model.image.size;
    CGFloat rate1 = size.height / size.width;
    CGFloat ww = [UIScreen mainScreen].bounds.size.width;
    CGFloat hh = [UIScreen mainScreen].bounds.size.height;
    CGFloat rate2 = hh / ww;
    /**
     YES : 图片比容器瘦, NO : 图片比容器扁
     */
    BOOL flag = rate1 > rate0;
    CGFloat zoomScale;
    CGFloat xx, yy;
    if (flag) {
        CGFloat zoomScrollViewBeginW;
        /**
         YES : 图片比屏幕瘦, NO : 图片比屏幕扁
         */
        BOOL flag1 = rate1 > rate2;
        if (flag1) {
            CGFloat imageTargetH = rect.size.width * rate1;
            CGFloat imageTargetW = imageTargetH / rate2;
            zoomScrollViewBeginW = zoomScrollView.frame.size.height / rate1;
            xx = rect.origin.x - (imageTargetW - rect.size.width) * 0.5;
            yy = rect.origin.y - (imageTargetH - rect.size.height) * 0.5;
        } else {
            CGFloat imageTargetH = rect.size.width * rate2;
            zoomScrollViewBeginW = zoomScrollView.frame.size.width;
            xx = rect.origin.x;
            yy = rect.origin.y - (imageTargetH - rect.size.height) * 0.5;
        }
        zoomScale = rect.size.width / zoomScrollViewBeginW;
    } else {
        zoomScale = rect.size.height / (zoomScrollView.frame.size.width * rate1);
        ww = rect.size.height / rate1;
        hh = ww * rate2;
        xx = rect.origin.x - (ww - rect.size.width) * 0.5;
        yy = rect.origin.y - (hh - rect.size.height) * 0.5;
    }
    xx *= -1;
    yy *= -1;
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//        NMImageCollectionViewCellModel *model = self.model;
//        zoomScrollView.transform = [self.delegate transformWithModel:model targetFrame:rect];
        zoomScrollView.zoomScale = zoomScale;
        zoomScrollView.contentOffset = CGPointMake(xx, yy);
        
        [self.delegate scaleDownAnimation];
    } completion:^(BOOL finished) {
        [self.delegate scaleDownAnimationCompletion];
    }];
}

- (void)scaleUp {
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//        zoomScrollView.transform = CGAffineTransformIdentity;
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

#pragma mark- UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(__kindof UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == panGR) {
        contentOffsetWhenPanGRBegin = zoomScrollView.contentOffset;
        zoomScaleWhenPanGRBegin = zoomScrollView.zoomScale;
        
//        CGFloat xx = zoomScrollView.contentOffset.x;
        CGFloat yy = zoomScrollView.contentOffset.y;
        
        /**
         左侧贴边
         */
//        BOOL flag0 = xx == 0;
        /**
         上侧贴边
         */
        BOOL flag1 = yy == 0;
        /**
         右侧贴边
         */
//        BOOL flag2 = zoomScrollView.frame.size.width - xx == [UIScreen mainScreen].bounds.size.width;
        /**
         下侧贴边
         */
        BOOL flag3 = zoomScrollView.frame.size.height - yy == [UIScreen mainScreen].bounds.size.height;
        UIPanGestureRecognizer *pan = gestureRecognizer;
        CGPoint translation = [pan translationInView:zoomScrollView];
        BOOL up = translation.y < 0 && ABS(translation.y) > ABS(translation.x);
        BOOL down = translation.y > 0 && ABS(translation.y) > ABS(translation.x);
        BOOL left = translation.x < 0 && ABS(translation.x) > ABS(translation.y);
        BOOL right = translation.x > 0 && ABS(translation.x) > ABS(translation.y);
        
        if (left || right) {
            return NO;
        } else {
            return (flag1 && down) || (flag3 && up);
        }
        
    }
    currentNumberOfTouches = gestureRecognizer.numberOfTouches;
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    if (gestureRecognizer == panGR) {
//        return NO;
//    }
    return YES;
}

#pragma mark- UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return imageView;
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    return NO;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
//    NSLog(@"scrollView.contentOffset:%@, scrollView.zoomScale:%.9f", NSStringFromCGPoint(scrollView.contentOffset), scrollView.zoomScale);
}

@end
