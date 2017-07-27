//
//  NMImageCollectionImageView.m
//  AlbumCollectionDemo
//
//  Created by 孙国林 on 2017/7/19.
//  Copyright © 2017年 孙国林. All rights reserved.
//

#import "NMImageCollectionImageView.h"
#import "NMImageBadgeView.h"
#import "NMImageConfig.h"

@implementation NMImageCollectionImageView {
    BOOL isPrepatedToFinishTouch;
    UIImageView *imageView;
    CGFloat maximumRadius;
    CGPoint rightUpCorner;
    NMImageBadgeView *badgeView;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;
        imageView = [UIImageView new];
        [self addSubview:imageView];
        
        badgeView = [NMImageBadgeView new];
        [self addSubview:badgeView];
        
        self.selectable = YES;
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    NSLog(@"touchesBegan");
    isPrepatedToFinishTouch = YES;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    NSLog(@"touchesEnded");
    if (isPrepatedToFinishTouch && self.selectable) {
        
        UITouch *touch = touches.anyObject;
        CGPoint touchPoint = [touch locationInView:self];
        CGFloat radius = sqrtf(powf(touchPoint.x - rightUpCorner.x, 2) + pow(touchPoint.y - rightUpCorner.y, 2));
        if (radius <= maximumRadius) {
            self.isSelected = !self.isSelected;
            if (self.isSelected) {
                [badgeView selectWithNumber:self.number animated:YES];
            } else {
                [badgeView deselect];
            }
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        } else {
            [self sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
    }
    isPrepatedToFinishTouch = NO;
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    NSLog(@"touchesCancelled");
    isPrepatedToFinishTouch = NO;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect rect = self.frame;
    rect.origin = CGPointZero;
    imageView.frame = rect;
    rightUpCorner.x = rect.size.width;
    rightUpCorner.y = 0;
    maximumRadius = rightUpCorner.x * 0.5;
    
    CGFloat side = NMLoopSide;
    CGFloat gap = 5;
    badgeView.frame = CGRectMake(rect.size.width - side - gap, gap, side, side);
}

- (void)setContentMode:(UIViewContentMode)contentMode {
    [super setContentMode:contentMode];
    imageView.contentMode = contentMode;
}

- (void)setImage:(UIImage *)image {
    _image = image;
    imageView.image = image;
}

- (void)setClipsToBounds:(BOOL)clipsToBounds {
    [super setClipsToBounds:clipsToBounds];
    imageView.clipsToBounds = clipsToBounds;
}

- (void)selectWithNumber:(NSUInteger)number animated:(BOOL)animated {
    self.isSelected = YES;
    [badgeView selectWithNumber:number animated:animated];
}

- (void)deselect {
    self.isSelected = NO;
    [badgeView deselect];
}

- (void)setSelectable:(BOOL)selectable {
    BOOL flag = _selectable != selectable;
    _selectable = selectable;
    if (flag) {
        if (selectable) {
            [self addSubview:badgeView];
        } else {
            [badgeView removeFromSuperview];
        }
    }
}

@end
