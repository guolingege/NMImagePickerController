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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.delegate imageBrowseViewCellDidbeginTouch:self];
}

- (void)setModel:(NMImageCollectionViewCellModel *)model {
    _model = model;
    CGRect rect = [UIScreen mainScreen].bounds;
    NMRequestImage(model.asset, rect.size, ^(UIImage *image, NSDictionary *info) {
        imageView.image = image;
        model.info = info;
    });
    panGR.enabled = YES;
}

- (void)collectionViewPanned:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        lastScale = 1;
        locationChanges.index = 0;
        locationChanges.panGRShouldStop = YES;
        collectionViewOffset = [self.delegate contentOffsetForCollectionView:self];
    }
    
    if (locationChanges.panGRShouldStop) {
        if (locationChanges.index > 2) {
            return;
        }
        NSUInteger ii = locationChanges.index;
        locationChanges.index++;
        CGPoint point = [sender translationInView:self];
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
                    panGR.enabled = NO;
                    return;
                } else {
                    [self.delegate imageBrowseViewCellDidBeginHide:self];
                }
            }
            default:
                break;
        }
    }
    
    CGPoint point2 = [sender translationInView:self];
    CGAffineTransform transform1 = CGAffineTransformTranslate(self.transform, point2.x, point2.y);
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
    
    lastScale = scale;
    radiusChanges.lastRadius = radius;
}

#pragma mark- Public Methods
- (void)showOut {
    NMImageCollectionViewCellModel *model = self.model;
    CGRect rect = [self.delegate scaleDownTargetFrameToIndexPath:self.indexPath];
    self.transform = [self.delegate transformWithModel:model targetFrame:rect];
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
        self.transform = [self.delegate transformWithModel:model targetFrame:rect];
        
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

#pragma mark- UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
