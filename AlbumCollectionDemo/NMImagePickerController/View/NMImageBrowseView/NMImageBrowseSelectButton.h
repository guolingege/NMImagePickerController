//
//  NMImageBrowseSelectButton.h
//  AlbumCollectionDemo
//
//  Created by 孙国林 on 2017/7/20.
//  Copyright © 2017年 孙国林. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NMImageBrowseSelectButton : UIButton

@property (nonatomic, assign) BOOL isSelected;

- (void)selectWithNumber:(NSUInteger)number animated:(BOOL)animated;
- (void)deselect;

@property (nonatomic, assign) BOOL selectable;

@end
