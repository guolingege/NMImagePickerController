//
//  NMImageBadgeView.h
//  AlbumCollectionDemo
//
//  Created by 孙国林 on 2017/7/19.
//  Copyright © 2017年 孙国林. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NMImageBadgeView : UIImageView

@property (nonatomic, assign) BOOL isSelected;

- (void)selectWithNumber:(NSUInteger)number animated:(BOOL)animated;
- (void)deselect;

@end
