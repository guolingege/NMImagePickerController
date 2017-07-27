//
//  NMImageBrowseSelectButton.m
//  AlbumCollectionDemo
//
//  Created by 孙国林 on 2017/7/20.
//  Copyright © 2017年 孙国林. All rights reserved.
//

#import "NMImageBrowseSelectButton.h"
#import "NMImageConfig.h"
#import "NMImageImageMaker.h"

static const CGFloat scale = 1.2;

@implementation NMImageBrowseSelectButton {
    NSUInteger theNumber;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        UIImage *image = NMLoopPlaceHolder(44, NMLoopSide);
        [self setBackgroundImage:image forState:UIControlStateNormal];
        self.selectable = YES;
    }
    return self;
}

- (void)selectWithNumber:(NSUInteger)number animated:(BOOL)animated {
    if (self.isSelected && theNumber == number) {
        return;
    }
    self.isSelected = YES;
    UIImage *image = NMFilledLoop(number, 44, NMLoopSide);
    [self setBackgroundImage:image forState:UIControlStateNormal];
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
}

- (void)deselect {
    if (self.isSelected == NO) {
        return;
    }
    self.isSelected = NO;
    UIImage *image = NMLoopPlaceHolder(44, NMLoopSide);
    [self setBackgroundImage:image forState:UIControlStateNormal];
}

- (void)setSelectable:(BOOL)selectable {
    _selectable = selectable;
    self.hidden = !selectable;
}

#pragma mark- UIImage

@end
