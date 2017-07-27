//
//  NMImageBottomSelectedCell.m
//  AlbumCollectionDemo
//
//  Created by 孙国林 on 2017/7/25.
//  Copyright © 2017年 孙国林. All rights reserved.
//

#import "NMImageBottomSelectedCell.h"
#import "NMImageConfig.h"

@implementation NMImageBottomSelectedCell {
    UIImageView *imageView;
    PHImageRequestID requestID;
    CGFloat halfLineW;
    CAShapeLayer *borderlayer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        halfLineW = 1.5;
        imageView = [UIImageView new];
        imageView.frame = CGRectMake(halfLineW * 2.0, halfLineW * 2.0, 50 - halfLineW * 4.0, 50 - halfLineW * 4.0);
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [self.contentView addSubview:imageView];
        
        borderlayer = [CAShapeLayer new];
        CGFloat ww = 50, hh = ww;
        UIBezierPath *bPath = [UIBezierPath new];
        [bPath moveToPoint:CGPointMake(0, halfLineW)];
        [bPath addLineToPoint:CGPointMake(ww - halfLineW , halfLineW)];
        [bPath addLineToPoint:CGPointMake(ww - halfLineW, hh - halfLineW)];
        [bPath addLineToPoint:CGPointMake(halfLineW, hh - halfLineW)];
        [bPath addLineToPoint:CGPointMake(halfLineW, 0)];
        
        borderlayer.path = bPath.CGPath;
        borderlayer.strokeColor = NMActiveColor().CGColor;
        borderlayer.fillColor = [UIColor clearColor].CGColor;
        borderlayer.lineWidth = halfLineW * 2.0;
        [self.contentView.layer addSublayer:borderlayer];
    }
    return self;
}

- (void)setModel:(NMImageCollectionViewCellModel *)model {
    if (_model != model) {
        _model = model;
        imageView.image = model.image;
    }
    borderlayer.hidden = !model.isCurrentModel;
}

@end
