//
//  NMImageCollectionViewCell.h
//  AlbumCollectionDemo
//
//  Created by 孙国林 on 2017/7/18.
//  Copyright © 2017年 孙国林. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMImageCollectionViewCellModel.h"

static NSString *const NMImageCollectionViewCellID = @"NMImageCollectionViewCellID";

@protocol NMImageCollectionViewCellDelegate;

@interface NMImageCollectionViewCell : UICollectionViewCell

@property (nonatomic, assign) NMImageCollectionViewCellModel *model;
@property (nonatomic, weak) id <NMImageCollectionViewCellDelegate>delegate;

- (void)selectWithNumber:(NSUInteger)number;
- (void)deselect;

@property (nonatomic, assign) BOOL selectable;

@end

@protocol NMImageCollectionViewCellDelegate <NSObject>

- (void)imageCollectionViewCell:(NMImageCollectionViewCell *)mageCollectionViewCell didSelectAtIndexPath:(NSIndexPath *)indexPath;
- (void)imageCollectionViewCell:(NMImageCollectionViewCell *)mageCollectionViewCell didDeselectAtIndexPath:(NSIndexPath *)indexPath;
- (void)imageCollectionViewCell:(NMImageCollectionViewCell *)mageCollectionViewCell didTapWithoutSelectionAtIndexPath:(NSIndexPath *)indexPath;

@end
