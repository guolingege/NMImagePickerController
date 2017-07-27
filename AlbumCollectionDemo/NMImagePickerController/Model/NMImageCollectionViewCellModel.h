//
//  NMImageCollectionViewCellModel.h
//  AlbumCollectionDemo
//
//  Created by 孙国林 on 2017/7/18.
//  Copyright © 2017年 孙国林. All rights reserved.
//

#import "NMImageModel.h"

@interface NMImageCollectionViewCellModel : NMImageModel

@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic, assign) NSUInteger number;
@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, assign) BOOL selectable;

@property (nonatomic, assign) BOOL isCurrentModel;

@property (nonatomic, strong) UIImage *image;

@end
