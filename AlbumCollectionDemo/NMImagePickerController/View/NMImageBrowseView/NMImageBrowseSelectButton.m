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

@implementation NMImageBrowseSelectButton

- (void)selectWithNumber:(NSUInteger)number animated:(BOOL)animated {
    self.isSelected = YES;
}

- (void)deselect {
    self.isSelected = NO;
}

#pragma mark- UIImage

@end
