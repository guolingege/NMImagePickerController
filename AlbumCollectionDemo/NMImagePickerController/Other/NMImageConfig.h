//
//  NMImageConfig.h
//  AlbumCollectionDemo
//
//  Created by 孙国林 on 2017/7/18.
//  Copyright © 2017年 孙国林. All rights reserved.
//

#ifndef NMImageConfig_h
#define NMImageConfig_h

#import <UIKit/UIKit.h>


/**
 横向间隔
 */
static const CGFloat minimumInteritemSpacing = 5,
/**
 纵向间隔
 */
minimumLineSpacing = minimumInteritemSpacing,
/**
 左侧空隙
 */
leftInset = minimumInteritemSpacing,
/**
 右侧空隙
 */
rightInset = minimumInteritemSpacing * 1.6;

static const CGFloat NMImageBrowseCollectionViewCellGap = 20;

static inline NSUInteger numberOfItemsInRow() {
    CGFloat ww = [UIScreen mainScreen].bounds.size.width;
    if (ww < 376) {
        return 4;
    } else if (ww < 415) {
        return 5;
    } else {
        return 6;
    }
}

static inline CGSize itemSize() {
    CGFloat numF = numberOfItemsInRow();
    CGFloat side = ([UIScreen mainScreen].bounds.size.width - minimumInteritemSpacing * (numF -1) - leftInset - rightInset) / numF;
    return CGSizeMake(side, side);
}

static NSString *const NMPlaceHolder = @"defaultPlaceHolder";

static const CGFloat NMLoopSide = 23;
static const CGFloat NMLargeLoopSide = 29;

static inline UIColor *NMThemedColor() {
    return [UIColor colorWithRed:21/255.0 green:124/255.0 blue:229/255.0 alpha:1];
}

static inline UIColor *NMTintColor() {
    return [UIColor whiteColor];
}

static inline UIColor *NMTintLightColor() {
    return [UIColor colorWithRed:1 green:1 blue:1 alpha:0.75];
}

static inline UIColor *NMTintDarkColor() {
    return [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1];
}

static inline UIColor *NMActiveColor() {
    return [UIColor colorWithRed:31/255.0 green:190/255.0 blue:34/255.0 alpha:1];
}

static inline UIColor *NMActiveLightColor() {
    return [UIColor colorWithRed:31/255.0 green:190/255.0 blue:34/255.0 alpha:0.75];
}

static inline UIColor *NMActiveDarkColor() {
    CGFloat scale = 0.75;
    return [UIColor colorWithRed:31 * scale/255.0 green:190 * scale/255.0 blue:34 * scale/255.0 alpha:1];
}

#endif /* NMImageConfig_h */
