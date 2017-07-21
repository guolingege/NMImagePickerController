//
//  NMImageBrowseCollectionView.h
//  AlbumCollectionDemo
//
//  Created by 孙国林 on 2017/7/20.
//  Copyright © 2017年 孙国林. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NMImageBrowseCollectionViewDelegate;

@interface NMImageBrowseCollectionView : UICollectionView

@property (nonatomic, weak) id <NMImageBrowseCollectionViewDelegate>touchDelegate;

@end

@protocol NMImageBrowseCollectionViewDelegate <NSObject>

- (void)imageBrowseCollectionViewDidEndOrCancelled:(NMImageBrowseCollectionView *)imageBrowseCollectionView;

@end
