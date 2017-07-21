//
//  NMImageTableViewCell.h
//  AlbumCollectionDemo
//
//  Created by 孙国林 on 2017/7/18.
//  Copyright © 2017年 孙国林. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMImageTableViewCellModel.h"

static NSString *const NMImageTableViewCellID = @"NMImageTableViewCellID";

static const CGFloat NMImageTableViewCellHeight = 60;

@interface NMImageTableViewCell : UITableViewCell

@property (nonatomic, strong) NMImageTableViewCellModel *model;

@end
