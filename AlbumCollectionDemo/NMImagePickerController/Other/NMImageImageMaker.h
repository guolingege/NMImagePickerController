//
//  NMImageImageMaker.h
//  AlbumCollectionDemo
//
//  Created by 孙国林 on 2017/7/20.
//  Copyright © 2017年 孙国林. All rights reserved.
//

#ifndef NMImageImageMaker_h
#define NMImageImageMaker_h

#import <UIKit/UIKit.h>

static inline UIImage *NMWhiteLoopPlaceHolder(CGFloat side) {
    static UIImage *image;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        CGSize size = CGSizeMake(side, side);
        CGFloat scale = [UIScreen mainScreen].scale;
        UIGraphicsBeginImageContextWithOptions(size, NO, scale);
        CGFloat halfLineWidth = 0.6;;
        CGRect rect = CGRectMake(halfLineWidth, halfLineWidth,
                                 size.width - halfLineWidth * 2.0,
                                 size.height - halfLineWidth * 2.0);
        UIBezierPath *bPath = [UIBezierPath bezierPathWithOvalInRect:rect];
        [[UIColor whiteColor] setStroke];
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
 @return 图片
 */
static inline UIImage *NMFilledWhiteLoop(NSUInteger number, CGFloat side) {
    CGSize size = CGSizeMake(side, side);
    CGFloat scale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    CGFloat halfLineWidth = 0.6;;
    CGRect rect = CGRectMake(halfLineWidth, halfLineWidth,
                             size.width - halfLineWidth * 2.0,
                             size.height - halfLineWidth * 2.0);
    UIBezierPath *bPath = [UIBezierPath bezierPathWithOvalInRect:rect];
    
    [NMThemedColor() setFill];
    [bPath fill];
    
    [[UIColor whiteColor] setStroke];
    bPath.lineWidth = halfLineWidth * 2.0;
    [bPath stroke];
    
    if (number > 0) {
        NSString *text = [NSString stringWithFormat:@"%zd", number];
        NSDictionary *att = @{NSFontAttributeName:[UIFont systemFontOfSize:side * 0.5],
                              NSForegroundColorAttributeName:[UIColor whiteColor]};
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
    size = CGSizeMake(size.width * scale, size.height * scale);
    radius *= scale;
    UIGraphicsBeginImageContext(size);
    
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











