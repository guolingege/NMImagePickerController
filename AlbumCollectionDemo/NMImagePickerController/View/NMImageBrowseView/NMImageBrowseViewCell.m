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
    int count;
    CGFloat lastRadius;
};
typedef struct _NMImageRadiusChanges NMImageRadiusChanges;

struct _NMImageLocationChanges {
    CGPoint point0;
    CGPoint point1;
    CGPoint point2;
    int count;
    BOOL shouldStop;
};
typedef struct _NMImageLocationChanges NMImageLocationChanges;

@interface NMImageBrowseViewCell ()
<UIGestureRecognizerDelegate>

@end

@implementation NMImageBrowseViewCell {
    UIImageView *imageView;
    UIPanGestureRecognizer *panGR;
    CGFloat lastScale;
    NMImageRadiusChanges radiusChanges;
    NMImageLocationChanges locationChanges;
    CGPoint collectionViewOffset;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        imageView = [UIImageView new];
        CGFloat ww = [UIScreen mainScreen].bounds.size.width;
        CGFloat hh = [UIScreen mainScreen].bounds.size.height;
        imageView.frame = CGRectMake(NMImageBrowseCollectionViewCellGap * 0.5, 0, ww, hh);
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:imageView];
        
        panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(collectionViewPanned:)];
        panGR.delegate = self;
        [self addGestureRecognizer:panGR];
        
        lastScale = 1;
    }
    return self;
}

- (void)setModel:(NMImageCollectionViewCellModel *)model {
    _model = model;
    CGRect rect = [UIScreen mainScreen].bounds;
    NMRequestImage(model.asset, rect.size, ^(UIImage *image, NSDictionary *info) {
        imageView.image = image;
        model.info = info;
    });
}

- (void)collectionViewPanned:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        lastScale = 1;
        locationChanges.count = 0;
        locationChanges.shouldStop = YES;
        
        collectionViewOffset = [self.delegate contentOffsetForCollectionView];
    }
    CGPoint point = [sender translationInView:self];
    
    if (locationChanges.shouldStop) {
        BOOL shouldReturn = YES;
        switch (locationChanges.count) {
            case 0:
                locationChanges.point0 = point;
                break;
            case 1:
                locationChanges.point1 = point;
                break;
            case 2: {
                locationChanges.point2 = point;
                
                CGFloat sumX = ABS(locationChanges.point0.x + locationChanges.point1.x + locationChanges.point2.x) * 1.5;
                CGFloat sumY = ABS(locationChanges.point0.y + locationChanges.point1.y + locationChanges.point2.y);
                
                NSLog(@"sumX:%.3f, sumY:%.3f", sumX, sumY);
                
                locationChanges.shouldStop = sumX > sumY;
                if (locationChanges.shouldStop) {
                    panGR.enabled = NO;
                } else {
                    shouldReturn = NO;
                    [self.delegate imageBrowseViewCellDidBeginHide:self];
                }
            } break;
                
            default:
                break;
        }
        
        locationChanges.count++;
        locationChanges.count = locationChanges.count % 3;
        
        if (shouldReturn) {
            for (UIGestureRecognizer *gr in [self.delegate gesturesInCollectionView]) {
                if (gr != panGR) {
                    gr.enabled = YES;
                }
            }
            return;
        }
    }
    
    CGAffineTransform transform1 = CGAffineTransformTranslate(self.transform, point.x, point.y);
    CGFloat ww = [UIScreen mainScreen].bounds.size.width;
    CGFloat hh = [UIScreen mainScreen].bounds.size.height;
    CGFloat vScale = self.transform.a;
    CGFloat gapXp = powf(self.transform.tx, 2);
    CGFloat gapYp = powf(self.transform.ty, 2);
    CGFloat radius = sqrtf(gapXp + gapYp);
    CGFloat diagonal = sqrtf(ww * ww + hh * hh);
    CGFloat scale = 1 - radius / diagonal * 0.9;
    CGAffineTransform transform2 = CGAffineTransformScale(CGAffineTransformIdentity, scale / lastScale, scale / lastScale);
    
    self.transform = CGAffineTransformConcat(transform1, transform2);
    
    vScale = powf(vScale, 6.5);
    [sender setTranslation:CGPointZero inView:self];
    
    [self.delegate imageBrowseViewCellDidBeDragged:self withCollectionViewContentOffset:collectionViewOffset progress:1 - vScale];
    
    switch (radiusChanges.count) {
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
    
    radiusChanges.count++;
    radiusChanges.count = radiusChanges.count % 4;
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
    
    lastScale = scale;
    radiusChanges.lastRadius = radius;
}

- (CGAffineTransform)transformWithModel:(NMImageCollectionViewCellModel *)model targetFrame:(CGRect)targetFrame {
    CGFloat sw = [UIScreen mainScreen].bounds.size.width;
    CGFloat sh = [UIScreen mainScreen].bounds.size.height;
    
    CGFloat scale;
    CGFloat imageW = model.pixelSize.width;
    CGFloat imageH = model.pixelSize.height;
    if (imageW < imageH) {
        scale = targetFrame.size.width / sw;
    } else {
        scale = targetFrame.size.width / sw * (imageW / imageH);
    }
    
    CGAffineTransform tranform0 = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
    CGFloat xx = sw * (1 - scale) * 0.5;
    CGFloat yy = sh * (1 - scale) * 0.5;
    CGFloat tx = targetFrame.origin.x - xx - (sw * scale - targetFrame.size.width) * 0.5;
    CGFloat ty = targetFrame.origin.y - yy - (sh * scale - targetFrame.size.height) * 0.5;
    CGAffineTransform transform1 = CGAffineTransformMakeTranslation(tx, ty);
    return CGAffineTransformConcat(tranform0, transform1);
}

#pragma mark- Public Methods
- (void)showOut {
    NMImageCollectionViewCellModel *model = self.model;
    CGRect rect = [self.delegate scaleDownTargetFrameToIndexPath:self.indexPath];
    self.transform = [self transformWithModel:model targetFrame:rect];
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.transform = CGAffineTransformIdentity;
        [self.delegate scaleUpAnimation];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)scaleDown {
    CGRect rect = [self.delegate scaleDownTargetFrameToIndexPath:self.indexPath];
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        NMImageCollectionViewCellModel *model = self.model;
        self.transform = [self transformWithModel:model targetFrame:rect];
        
        [self.delegate scaleDownAnimation];
    } completion:^(BOOL finished) {
        [self.delegate scaleDownAnimationCompletion];
    }];
}

- (void)scaleUp {
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.transform = CGAffineTransformIdentity;
        [self.delegate scaleUpAnimation];
    } completion:^(BOOL finished) {
        [self.delegate scaleUpAnimationCompletion];
    }];
}

- (void)setPanGREnabled:(BOOL)enabled {
    panGR.enabled = enabled;
}

@end
