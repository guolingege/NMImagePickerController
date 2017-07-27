//
//  NMImageBrowseViewCell.h
//  AlbumCollectionDemo
//
//  Created by 孙国林 on 2017/7/20.
//  Copyright © 2017年 孙国林. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMImageCollectionViewCellModel.h"

static NSString *const NMImageBrowseViewCellID = @"NMImageBrowseViewCellID";

@protocol NMImageBrowseViewCellDelegate;

@interface NMImageBrowseViewCell : UICollectionViewCell

@property (nonatomic, strong) NMImageCollectionViewCellModel *model;
@property (nonatomic, weak) id <NMImageBrowseViewCellDelegate>delegate;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, assign, readonly) CGRect zoomScrollViewFrame;

- (void)showOut;
- (void)scaleDown;
- (void)scaleUp;
- (void)setPanGREnabled:(BOOL)enabled;

@end

@protocol NMImageBrowseViewCellDelegate <NSObject>

- (void)imageBrowseCollectionViewCell:(NMImageBrowseViewCell *)cell didBeginTouchWithTouchCount:(NSUInteger)count;
- (CGPoint)contentOffsetForCollectionView:(NMImageBrowseViewCell *)cell;
- (NSArray *)gesturesInCollectionView;
- (void)imageBrowseViewCellDidBeginHide:(NMImageBrowseViewCell *)cell;
- (void)imageBrowseViewCellDidBeDragged:(NMImageBrowseViewCell *)cell withCollectionViewContentOffset:(CGPoint)offset progress:(CGFloat)progress;
- (CGRect)scaleDownTargetFrameToIndexPath:(NSIndexPath *)indexPath;
- (void)scaleDownAnimation;
- (void)scaleDownAnimationCompletion;
- (void)scaleUpAnimation;
- (void)scaleUpAnimationCompletion;
- (CGAffineTransform)transformWithModel:(NMImageCollectionViewCellModel *)model targetFrame:(CGRect)targetFrame;
- (void)imageBrowseCollectionViewCellSingleTapped:(NMImageBrowseViewCell *)cell;

@end
