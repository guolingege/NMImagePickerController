//
//  NMImageBottomSelectedCell.h
//  AlbumCollectionDemo
//
//  Created by 孙国林 on 2017/7/25.
//  Copyright © 2017年 孙国林. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMImageCollectionViewCellModel.h"

static NSString *const NMImageBottomSelectedCellID = @"NMImageBottomSelectedCellID";

@interface NMImageBottomSelectedCell : UICollectionViewCell

@property (nonatomic, strong) NMImageCollectionViewCellModel *model;

@end
