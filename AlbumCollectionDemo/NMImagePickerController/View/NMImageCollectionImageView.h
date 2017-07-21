//
//  NMImageCollectionImageView.h
//  AlbumCollectionDemo
//
//  Created by 孙国林 on 2017/7/19.
//  Copyright © 2017年 孙国林. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NMImageCollectionImageView : UIControl

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) NSUInteger number;

- (void)selectWithNumber:(NSUInteger)number animated:(BOOL)animated;
- (void)deselect;

@property (nonatomic, assign) BOOL selectable;

@end
