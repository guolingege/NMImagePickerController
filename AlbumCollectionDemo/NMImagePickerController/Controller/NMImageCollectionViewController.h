//
//  NMImageCollectionViewController.h
//  AlbumCollectionDemo
//
//  Created by 孙国林 on 2017/7/18.
//  Copyright © 2017年 孙国林. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMImageTableViewCellModel.h"

@protocol NMImageCollectionViewControllerDelegate;

@interface NMImageCollectionViewController : UIViewController

@property (nonatomic, strong) NMImageTableViewCellModel *model;
@property (nonatomic, assign) NSUInteger maximumSelectionCount;

@property (nonatomic, weak) id <NMImageCollectionViewControllerDelegate>delegate;

@end

@protocol NMImageCollectionViewControllerDelegate <NSObject>

- (void)imageCollectionViewControllerDidCancel:(NMImageCollectionViewController *)imageTableViewController;
- (void)imageCollectionViewController:(NMImageCollectionViewController *)controller didFinishSelectingImagesWithModels:(NSArray <NMImageCollectionViewCellModel *>*)models;

@end
