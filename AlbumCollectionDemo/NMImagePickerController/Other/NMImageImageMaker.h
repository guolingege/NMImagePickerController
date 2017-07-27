//
//  NMImageImageMaker.h
//  AlbumCollectionDemo
//
//  Created by 孙国林 on 2017/7/20.
//  Copyright © 2017年 孙国林. All rights reserved.
//

#ifndef NMImageImageMaker_h
#define NMImageImageMaker_h

#import "NMImageConfig.h"

static inline UIImage *NMLoopPlaceHolder(CGFloat side, CGFloat diameter) {
    static UIImage *image;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        CGSize size = CGSizeMake(side, side);
        CGFloat scale = [UIScreen mainScreen].scale;
        UIGraphicsBeginImageContextWithOptions(size, NO, scale);
        CGFloat margin = (side - diameter) * 0.5;
        CGFloat halfLineWidth = 0.6;;
        CGRect rect = CGRectMake(margin + halfLineWidth,
                                 margin + halfLineWidth,
                                 diameter - halfLineWidth * 2.0,
                                 diameter - halfLineWidth * 2.0);
        UIBezierPath *bPath = [UIBezierPath bezierPathWithOvalInRect:rect];
        [NMTintColor() setStroke];
        bPath.lineWidth = halfLineWidth * 2.0;
        [bPath stroke];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    return image;
}

/**
 绘制带有圆边的徽章

 @param number 大于0才绘制
 @param side 图片边长
 @param diameter 圆的外直径
 @return 图片
 */
static inline UIImage *NMFilledLoop(NSUInteger number, CGFloat side, CGFloat diameter) {
    CGSize size = CGSizeMake(side, side);
    CGFloat scale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    CGFloat margin = (side - diameter) * 0.5;
    CGFloat halfLineWidth = 0.6;
    CGRect rect = CGRectMake(margin + halfLineWidth,
                             margin + halfLineWidth,
                             diameter - halfLineWidth * 2.0,
                             diameter - halfLineWidth * 2.0);
    UIBezierPath *bPath = [UIBezierPath bezierPathWithOvalInRect:rect];
    
    [NMActiveColor() setFill];
    [bPath fill];
    
    [NMTintColor() setStroke];
    bPath.lineWidth = halfLineWidth * 2.0;
    [bPath stroke];
    
    if (number > 0) {
        NSString *text = [NSString stringWithFormat:@"%zd", number];
        NSDictionary *att = @{NSFontAttributeName:[UIFont systemFontOfSize:diameter * 0.5],
                              NSForegroundColorAttributeName:NMTintColor()};
        CGSize textSize = [text sizeWithAttributes:att];
        CGRect textRect = CGRectZero;
        textRect.size = textSize;
        textRect.origin.x = (size.width - textSize.width) * 0.5;
        textRect.origin.y = (size.height - textSize.height) * 0.5;
        [text drawInRect:textRect withAttributes:att];
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

static inline UIImage *NMRoundRectImage(CGSize size, UIColor *fillColor, CGFloat radius) {
    CGFloat scale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    
    UIBezierPath *bPath = [UIBezierPath bezierPath];
    [bPath moveToPoint:CGPointMake(radius, 0)];
    [bPath addLineToPoint:CGPointMake(size.width - radius, 0)];
    [bPath addArcWithCenter:CGPointMake(size.width - radius, radius)
                     radius:radius startAngle:M_PI * 1.5
                   endAngle:M_PI * 2.0 clockwise:YES];
    [bPath addLineToPoint:CGPointMake(size.width, size.height - radius)];
    [bPath addArcWithCenter:CGPointMake(size.width - radius, size.height - radius)
                     radius:radius startAngle:0
                   endAngle:M_PI * 0.5 clockwise:YES];
    [bPath addLineToPoint:CGPointMake(radius, size.height)];
    [bPath addArcWithCenter:CGPointMake(radius, size.height - radius)
                     radius:radius startAngle:M_PI * 0.5
                   endAngle:M_PI clockwise:YES];
    [bPath addLineToPoint:CGPointMake(0, radius)];
    [bPath addArcWithCenter:CGPointMake(radius, radius)
                     radius:radius startAngle:M_PI
                   endAngle:M_PI * 1.5 clockwise:YES];
    [fillColor setFill];
    [bPath fill];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#endif /* NMImageImageMaker_h */











