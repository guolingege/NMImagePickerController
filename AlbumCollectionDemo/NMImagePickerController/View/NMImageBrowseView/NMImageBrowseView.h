//
//  NMImageBrowseView.h
//  AlbumCollectionDemo
//
//  Created by 孙国林 on 2017/7/21.
//  Copyright © 2017年 孙国林. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMImageCollectionViewCellModel.h"

@protocol NMImageBrowseViewDelegate;

@interface NMImageBrowseView : UIView

+ (instancetype)viewWithAllModels:(NSArray<NMImageCollectionViewCellModel *> *)models
                   selectedModels:(NSMutableArray<NMImageCollectionViewCellModel *> *)selectedModels
                    fromIndexPath:(NSIndexPath *)indexPath
                   collectionView:(UICollectionView *)collectionView
                   controllerView:(UIView *)controllerView
                         delegate:(id<NMImageBrowseViewDelegate>)delegate
            maximumSelectionCount:(NSUInteger)maximumSelectionCount;
- (void)showWithCompletion:(void (^)())completion;
- (void)hideToCollectionView;

@end

@protocol NMImageBrowseViewDelegate <NSObject>

- (void)imageBrowseViewDidTapBackButton:(NMImageBrowseView *)imageBrowseView;
- (void)imageBrowseViewDidTapSendButton:(NMImageBrowseView *)imageBrowseView;
- (void)imageBrowseView:(NMImageBrowseView *)imageBrowseView didSelectModel:(NMImageCollectionViewCellModel *)model;
- (void)imageBrowseView:(NMImageBrowseView *)imageBrowseView didDeselectModel:(NMImageCollectionViewCellModel *)model;
- (void)imageBrowseViewDidBeginHide:(NMImageBrowseView *)imageBrowseView
                   fromCurrentIndex:(NSUInteger)index
                 withSelectedModels:(NSMutableArray<NMImageCollectionViewCellModel *> *)selectedModels;
- (void)imageBrowseViewDidHide:(NMImageBrowseView *)imageBrowseView;
- (void)imageBrowseViewDidCancelHide:(NMImageBrowseView *)imageBrowseView;

@end
