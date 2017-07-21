//
//  NMImageBadgeView.m
//  AlbumCollectionDemo
//
//  Created by 孙国林 on 2017/7/19.
//  Copyright © 2017年 孙国林. All rights reserved.
//

#import "NMImageBadgeView.h"
#import "NMImageConfig.h"
#import "NMImageImageMaker.h"

static const CGFloat scale = 1.2;

@implementation NMImageBadgeView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self deselect];
    }
    return self;
}

- (void)selectWithNumber:(NSUInteger)number animated:(BOOL)animated {
    self.image = NMFilledWhiteLoop(number, NMWhiteLoopSide);
    if (animated) {
        CGRect originRect = self.frame;
        [UIView animateWithDuration:0.2 animations:^{
            CGRect largeRect = originRect;
            largeRect.origin.x -= (scale - 1) * 0.5 * originRect.size.width;
            largeRect.origin.y -= (scale - 1) * 0.5 * originRect.size.height;
            largeRect.size.width *= scale;
            largeRect.size.height *= scale;
            self.frame = largeRect;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.2 initialSpringVelocity:5 options:UIViewAnimationOptionCurveLinear animations:^{
                self.frame = originRect;
            } completion:nil];
        }];
    }
    self.isSelected = YES;
}

- (void)deselect {
    self.image = NMWhiteLoopPlaceHolder(NMWhiteLoopSide);
    self.isSelected = NO;
}

#pragma mark- UIImage


@end
