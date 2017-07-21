//
//  NMImageTableViewController.h
//  AlbumCollectionDemo
//
//  Created by 孙国林 on 2017/7/18.
//  Copyright © 2017年 孙国林. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMImageTableViewCellModel.h"

@protocol NMImageTableViewControllerDelegate;

@interface NMImageTableViewController : UITableViewController

@property (nonatomic, weak) id <NMImageTableViewControllerDelegate>delegate;
@property (nonatomic, strong) NSArray <NMImageTableViewCellModel *> *modelsArray;
@property (nonatomic, assign) NSUInteger maximumSelectionCount;

@end

@protocol NMImageTableViewControllerDelegate <NSObject>

- (void)imageTableViewControllerDidCancel:(NMImageTableViewController *)imageTableViewController;

@end
