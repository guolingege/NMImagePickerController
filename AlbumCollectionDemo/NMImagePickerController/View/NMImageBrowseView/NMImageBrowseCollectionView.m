//
//  NMImageBrowseCollectionView.m
//  AlbumCollectionDemo
//
//  Created by 孙国林 on 2017/7/20.
//  Copyright © 2017年 孙国林. All rights reserved.
//

#import "NMImageBrowseCollectionView.h"

@interface NMImageBrowseCollectionView ()

@end

struct NMLastScales {
    CGFloat scale0, scale1, scale2, scale3;
};

@implementation NMImageBrowseCollectionView

#pragma mark- overwrite super methods
- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        
    }
    return self;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [self.touchDelegate imageBrowseCollectionViewDidEndOrCancelled:self];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    [self.touchDelegate imageBrowseCollectionViewDidEndOrCancelled:self];
}

@end
