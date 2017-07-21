//
//  NMImageCollectionViewCellModel.m
//  AlbumCollectionDemo
//
//  Created by 孙国林 on 2017/7/18.
//  Copyright © 2017年 孙国林. All rights reserved.
//

#import "NMImageCollectionViewCellModel.h"

@implementation NMImageCollectionViewCellModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.selectable = YES;
    }
    return self;
}

@end
