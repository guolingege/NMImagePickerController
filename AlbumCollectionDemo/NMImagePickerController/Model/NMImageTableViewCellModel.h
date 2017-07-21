//
//  NMImageTableViewCellModel.h
//  AlbumCollectionDemo
//
//  Created by 孙国林 on 2017/7/18.
//  Copyright © 2017年 孙国林. All rights reserved.
//

#import "NMImageCollectionViewCellModel.h"

@class PHAsset;
@class PHAssetCollection;

@interface NMImageTableViewCellModel : NSObject

@property (nonatomic, strong) NSArray <NMImageCollectionViewCellModel *>*imageCollectionViewCellModels;
@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, strong) PHAssetCollection *assetCollection;

@end
