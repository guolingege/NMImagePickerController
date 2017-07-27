//
//  NMImageBrowseView.m
//  AlbumCollectionDemo
//
//  Created by 孙国林 on 2017/7/21.
//  Copyright © 2017年 孙国林. All rights reserved.
//

#import "NMImageBrowseView.h"
#import "NMImageBrowseCollectionView.h"
#import "NMImageBrowseViewCell.h"
#import "NMImageConfig.h"
#import "NMImageBrowseSelectButton.h"
#import "NMImageBottomSelectedCell.h"
#import "NMImageImageMaker.h"

@interface NMImageBrowseView ()
<UICollectionViewDataSource, UICollectionViewDelegate, NMImageBrowseCollectionViewDelegate, NMImageBrowseViewCellDelegate>

@property (nonatomic, strong) NSArray<NMImageCollectionViewCellModel *> *allModels;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, weak) id <NMImageBrowseViewDelegate>privateDelegate;
@property (nonatomic, strong) NMImageBrowseCollectionView *imageBrowseCollectionView;
@property (nonatomic, strong) UICollectionView *originalCollecionView;
@property (nonatomic, strong) UIView *controllerView;
@property (nonatomic, assign) NSUInteger maximumSelectionCount;
@property (nonatomic, strong) NSMutableArray<NMImageCollectionViewCellModel *> *selectedArray;

@end

@implementation NMImageBrowseView {
    UIView *topView;
    UIView *selectionView;
    UIView *bottomView;
    NMImageBrowseViewCell *currentCell;
    UIImageView *frontImageView;
    NMImageBrowseSelectButton *selectButton;
    NMImageCollectionViewCellModel *currentModel;
    NSInteger collectionViewW;
    UICollectionView *selectedCollectionView;
    UIButton *sendButton;
    BOOL subControlsHidden;
}

#pragma mark- overwrite super methods
- (instancetype)init {
    self = [super init];
    if (self) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        CGFloat ww = [UIScreen mainScreen].bounds.size.width;
        CGFloat hh = [UIScreen mainScreen].bounds.size.height;
        CGRect rect = CGRectMake(-NMImageBrowseCollectionViewCellGap * 0.5, 0, ww + NMImageBrowseCollectionViewCellGap, hh);
        collectionViewW = rect.size.width;
        layout.itemSize = rect.size;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        NMImageBrowseCollectionView *imageBrowseCollectionView = [[NMImageBrowseCollectionView alloc] initWithFrame:rect collectionViewLayout:layout];
        imageBrowseCollectionView.backgroundColor = [UIColor clearColor];
        imageBrowseCollectionView.hidden = YES;
        imageBrowseCollectionView.delegate = self;
        imageBrowseCollectionView.dataSource = self;
        imageBrowseCollectionView.pagingEnabled = YES;
        imageBrowseCollectionView.touchDelegate = self;
        imageBrowseCollectionView.showsHorizontalScrollIndicator = NO;
        [imageBrowseCollectionView registerClass:[NMImageBrowseViewCell class] forCellWithReuseIdentifier:NMImageBrowseViewCellID];
        [self addSubview:imageBrowseCollectionView];
        self.imageBrowseCollectionView = imageBrowseCollectionView;
        
        frontImageView = [UIImageView new];
        frontImageView.frame = [UIScreen mainScreen].bounds;
        frontImageView.contentMode = UIViewContentModeScaleAspectFit;
        frontImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:frontImageView];
        
        topView = [UIView new];
        rect = CGRectMake(0, 0, ww, 44);
        topView.frame = rect;
        topView.backgroundColor = NMThemedColor();
        topView.alpha = 0;
        bottomView.alpha = 0;
        [self addSubview:topView];
        
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
        backButton.frame = CGRectMake(0, 0, 44, 44);
        
        [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        UIImage *image = [UIImage imageNamed:@"back"];
        CGSize innerSize = CGSizeMake(13, 21);
        image = [self zoomImage:image innerSize:innerSize outerSize:backButton.frame.size];
        image = NMColorImage(image, [UIColor whiteColor]);
        [backButton setBackgroundImage:image forState:UIControlStateNormal];
        [topView addSubview:backButton];
        
        selectButton = [NMImageBrowseSelectButton new];
        selectButton.frame = CGRectMake(ww - 44, 0, 44, 44);
        [selectButton addTarget:self action:@selector(selectButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [topView addSubview:selectButton];
        
        bottomView = [UIView new];
        bottomView.frame = CGRectMake(0, hh - 64, ww, 64);
        bottomView.backgroundColor = topView.backgroundColor;
        [self addSubview:bottomView];
        
        layout = [UICollectionViewFlowLayout new];
        layout.itemSize = CGSizeMake(50, 50);
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 6;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        CGFloat sendButtonH = 44 * 0.7, sendButtonW = sendButtonH * 2.0, rightMargin = 6;
        rect = CGRectMake(6, 0, ww - 6 - sendButtonW - rightMargin * 2, 64);
        selectedCollectionView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:layout];
        selectedCollectionView.backgroundColor = [UIColor clearColor];
        selectedCollectionView.delegate = self;
        selectedCollectionView.dataSource = self;
        selectedCollectionView.showsHorizontalScrollIndicator = NO;
        [bottomView addSubview:selectedCollectionView];
        
        [selectedCollectionView registerClass:NMImageBottomSelectedCell.class forCellWithReuseIdentifier:NMImageBottomSelectedCellID];
        
        sendButton = [UIButton new];
        CGFloat bx = CGRectGetMaxX(rect) + rightMargin;
        CGFloat by = (bottomView.frame.size.height - sendButtonH) * 0.5;
        sendButton.frame = CGRectMake(bx, by, sendButtonW, sendButtonH);
        [sendButton setTitleColor:NMTintColor() forState:UIControlStateNormal];
        [sendButton setTitleColor:NMTintLightColor() forState:UIControlStateHighlighted];
        [sendButton setTitleColor:NMTintDarkColor() forState:UIControlStateDisabled];
        sendButton.titleLabel.font = [UIFont systemFontOfSize:14];
        image = NMRoundRectImage(sendButton.frame.size, NMActiveColor(), sendButtonH * 0.15);
        [sendButton setBackgroundImage:image forState:UIControlStateNormal];
        image = NMRoundRectImage(sendButton.frame.size, NMActiveLightColor(), sendButtonH * 0.15);
        [sendButton setBackgroundImage:image forState:UIControlStateHighlighted];
        image = NMRoundRectImage(sendButton.frame.size, NMActiveDarkColor(), sendButtonH * 0.15);
        [sendButton setBackgroundImage:image forState:UIControlStateDisabled];
        [sendButton addTarget:self action:@selector(sendButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:sendButton];
    }
    return self;
}

#pragma mark- private methods
- (void)back {
    [self.privateDelegate imageBrowseViewDidTapBackButton:self];
    NSArray *array = [self.imageBrowseCollectionView indexPathsForVisibleItems];
    for (NSIndexPath *indexPath in array) {
        NMImageBrowseViewCell *cell = (NMImageBrowseViewCell *)[self.imageBrowseCollectionView cellForItemAtIndexPath:indexPath];
        CGRect rect = cell.frame;
        rect = [self.imageBrowseCollectionView convertRect:rect toView:self];
        if (rect.size.width > [UIScreen mainScreen].bounds.size.width * 0.5) {
            [cell scaleDown];
        }
    }
}

- (void)selectButtonTapped {
    currentModel.isSelected = !selectButton.isSelected;
    if (selectButton.isSelected) {
        [selectButton deselect];
        NSUInteger index = [self.selectedArray indexOfObject:currentModel];
        [self.privateDelegate imageBrowseView:self didDeselectModel:currentModel];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [selectedCollectionView deleteItemsAtIndexPaths:@[indexPath]];
    } else {
        //先通过代理修改currentModel的number
        [self.privateDelegate imageBrowseView:self didSelectModel:currentModel];
        //再d修改UI
        [selectButton selectWithNumber:currentModel.number animated:YES];
        NSUInteger index = self.selectedArray.count - 1;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [selectedCollectionView insertItemsAtIndexPaths:@[indexPath]];
        [selectedCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    }
    sendButton.enabled = self.selectedArray.count != 0;
    [sendButton setTitle:self.sendButtonTitle forState:UIControlStateNormal];
}

- (void)sendButtonTapped {
    [self.privateDelegate imageBrowseViewDidTapSendButton:self];
}

- (void)updateWithScrollView:(UIScrollView *)scrollView {
    NSInteger xx = scrollView.contentOffset.x + collectionViewW * 0.5;
    NSUInteger row = ceilf(xx / collectionViewW * 1.0);
    
    NSInteger index = -1;
    NMImageCollectionViewCellModel *previousModel;
    for (NMImageCollectionViewCellModel *model in self.selectedArray) {
        if (model.isCurrentModel) {
            index = [self.selectedArray indexOfObject:model];
            previousModel = model;
            model.isCurrentModel = NO;
        }
    }
    
    currentModel = self.allModels[row];
    currentModel.isCurrentModel = YES;
    
    if (previousModel) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        NMImageBottomSelectedCell *previousCell = (NMImageBottomSelectedCell *)[selectedCollectionView cellForItemAtIndexPath:indexPath];
        previousCell.model = previousModel;
    }
    if ([self.selectedArray containsObject:currentModel]) {
        index = [self.selectedArray indexOfObject:currentModel];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        NMImageBottomSelectedCell *currentSelectedCell = (NMImageBottomSelectedCell *)[selectedCollectionView cellForItemAtIndexPath:indexPath];
        currentSelectedCell.model = currentModel;
        NSArray *visibleArray = selectedCollectionView.indexPathsForVisibleItems;
        BOOL flag = [visibleArray containsObject:indexPath];
        [selectedCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:flag];
    }
    
    if (currentModel.isSelected) {
        [selectButton selectWithNumber:currentModel.number animated:NO];
    } else {
        [selectButton deselect];
    }
    selectButton.selectable = currentModel.selectable;
}

#pragma mark- public methods
+ (instancetype)viewWithAllModels:(NSArray<NMImageCollectionViewCellModel *> *)models
                   selectedModels:(NSMutableArray<NMImageCollectionViewCellModel *> *)selectedModels
                    fromIndexPath:(NSIndexPath *)indexPath
                   collectionView:(UICollectionView *)collectionView
                   controllerView:(UIView *)controllerView
                         delegate:(id<NMImageBrowseViewDelegate>)delegate
            maximumSelectionCount:(NSUInteger)maximumSelectionCount {
    NMImageBrowseView *browseView = [NMImageBrowseView new];
    browseView.frame = [UIScreen mainScreen].bounds;
    browseView.backgroundColor = [UIColor clearColor];
    browseView.allModels = models;
    browseView.selectedArray = selectedModels;
    browseView.indexPath = indexPath;
    browseView.privateDelegate = delegate;
    browseView.maximumSelectionCount = maximumSelectionCount;
    [collectionView addSubview:browseView];
    
    [browseView.imageBrowseCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    browseView.originalCollecionView = collectionView;
    browseView.controllerView = controllerView;
    
    [controllerView addSubview:browseView];
    browseView.hidden = YES;
    
    return browseView;
}

- (void)showWithCompletion:(void (^)())completion {
    
    self.hidden = NO;
    
    NMImageCollectionViewCellModel *model = self.allModels[self.indexPath.row];
    CGRect rect = [self scaleDownTargetFrameToIndexPath:self.indexPath];
    frontImageView.transform = [self transformWithModel:model targetFrame:rect];
    NMRequestImage(model.asset, frontImageView.frame.size, ^(UIImage *image, NSDictionary *info) {
        frontImageView.image = image;
    });
    for (NMImageCollectionViewCellModel *model in self.selectedArray) {
        model.isCurrentModel = NO;
    }
    currentModel = self.allModels[self.indexPath.row];
    currentModel.isCurrentModel = YES;
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        frontImageView.transform = CGAffineTransformIdentity;
        self.backgroundColor = [UIColor blackColor];
        self.imageBrowseCollectionView.transform = CGAffineTransformIdentity;
        topView.alpha = 1;
        bottomView.alpha = 1;
        [self scaleUpAnimation];
    } completion:^(BOOL finished) {
        [frontImageView removeFromSuperview];
        self.imageBrowseCollectionView.hidden = NO;
        completion();
    }];
    
    sendButton.enabled = self.selectedArray.count != 0;
    [sendButton setTitle:self.sendButtonTitle forState:UIControlStateNormal];
}

- (NSString *)sendButtonTitle {
    NSUInteger count = self.selectedArray.count;
    if (count == 0) {
        return @"发送";
    } else {
        return [NSString stringWithFormat:@"发送(%zd)", count];
    }
}

- (void)hideToCollectionView {
    [currentCell scaleDown];
}

#pragma mark- UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == self.imageBrowseCollectionView) {
        return self.allModels.count;
    } else {
        return self.selectedArray.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.imageBrowseCollectionView) {
        NMImageBrowseViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NMImageBrowseViewCellID forIndexPath:indexPath];
        cell.model = self.allModels[indexPath.row];
        cell.indexPath = indexPath;
        cell.delegate = self;
        return cell;
    } else {
        NMImageBottomSelectedCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NMImageBottomSelectedCellID forIndexPath:indexPath];
        cell.model = self.selectedArray[indexPath.row];
        return cell;
    }
}

#pragma mark- UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == selectedCollectionView) {
        NMImageCollectionViewCellModel *model = self.selectedArray[indexPath.row];
        [self.imageBrowseCollectionView scrollToItemAtIndexPath:model.indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    }
}

#pragma mark- UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView == self.imageBrowseCollectionView) {
        [currentCell setPanGREnabled:YES];
        if (decelerate) {
            [self updateWithScrollView:scrollView];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.imageBrowseCollectionView) {
        if (scrollView.isDragging) {
            [self updateWithScrollView:scrollView];
        }
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (scrollView == self.imageBrowseCollectionView) {
        [self updateWithScrollView:scrollView];
    }
}

#pragma mark- NMImageBrowseCollectionViewDelegate
- (void)imageBrowseCollectionViewDidEndOrCancelled:(NMImageBrowseCollectionView *)iiimageBrowseCollectionView {
    [currentCell setPanGREnabled:YES];
    iiimageBrowseCollectionView.scrollEnabled = YES;
}

#pragma mark- NMImageBrowseViewCellDelegate
- (void)imageBrowseCollectionViewCell:(NMImageBrowseViewCell *)cell didBeginTouchWithTouchCount:(NSUInteger)count {
    currentCell = cell;
    if (count >= 2) {
        self.imageBrowseCollectionView.scrollEnabled = NO;
        NSLog(@"count >= 2");
    }
}

- (CGAffineTransform)transformWithModel:(NMImageCollectionViewCellModel *)model targetFrame:(CGRect)targetFrame {
    CGFloat sw = [UIScreen mainScreen].bounds.size.width;
    CGFloat sh = [UIScreen mainScreen].bounds.size.height;
    
    CGFloat scale;
    CGFloat imageW = model.pixelSize.width;
    CGFloat imageH = model.pixelSize.height;
    if (imageW < imageH) {
        scale = targetFrame.size.width / sw;
    } else {
        scale = targetFrame.size.width / sw * (imageW / imageH);
    }
    
    CGAffineTransform tranform0 = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
    CGFloat xx = sw * (1 - scale) * 0.5;
    CGFloat yy = sh * (1 - scale) * 0.5;
    CGFloat tx = targetFrame.origin.x - xx - (sw * scale - targetFrame.size.width) * 0.5;
    CGFloat ty = targetFrame.origin.y - yy - (sh * scale - targetFrame.size.height) * 0.5;
    CGAffineTransform transform1 = CGAffineTransformMakeTranslation(tx, ty);
    return CGAffineTransformConcat(tranform0, transform1);
}

- (NSArray *)gesturesInCollectionView {
    return self.imageBrowseCollectionView.gestureRecognizers;
}

- (CGPoint)contentOffsetForCollectionView:(NMImageBrowseViewCell *)cell {
    return self.imageBrowseCollectionView.contentOffset;
}

- (void)imageBrowseViewCellDidBeginHide:(NMImageBrowseViewCell *)cell {
    [self.privateDelegate imageBrowseViewDidBeginHide:self fromCurrentIndex:cell.indexPath.row withSelectedModels:self.selectedArray];
}

- (void)imageBrowseViewCellDidBeDragged:(NMImageBrowseViewCell *)cell withCollectionViewContentOffset:(CGPoint)offset progress:(CGFloat)progress {
    self.imageBrowseCollectionView.contentOffset = offset;
    topView.alpha = 1 - progress;
    bottomView.alpha = 1 - progress;
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1 - progress];
}

- (CGRect)scaleDownTargetFrameToIndexPath:(NSIndexPath *)indexPath {
    CGRect rect = [self.originalCollecionView cellForItemAtIndexPath:indexPath].frame;
    rect = [self.originalCollecionView convertRect:rect toView:self.controllerView];
    return rect;
}

- (void)scaleDownAnimation {
    topView.alpha = 0;
    bottomView.alpha = 0;
    self.backgroundColor = [UIColor clearColor];
}

- (void)scaleDownAnimationCompletion {
    [self removeFromSuperview];
    [self.privateDelegate imageBrowseViewDidHide:self];
}

- (void)scaleUpAnimation {
    topView.alpha = 1;
    bottomView.alpha = 1;
    self.backgroundColor = [UIColor blackColor];
}

- (void)scaleUpAnimationCompletion {
    [self.privateDelegate imageBrowseViewDidCancelHide:self];
}

- (void)imageBrowseCollectionViewCellSingleTapped:(NMImageBrowseViewCell *)cell {
    subControlsHidden = !subControlsHidden;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.35];
    topView.alpha = !subControlsHidden;
    bottomView.alpha = !subControlsHidden;
    [UIView commitAnimations];
}

#pragma mark- UIImage
- (UIImage *)zoomImage:(UIImage *)image innerSize:(CGSize)innerSize outerSize:(CGSize)outerSize {
    if (image) {
        UIGraphicsBeginImageContextWithOptions(outerSize, NO, [UIScreen mainScreen].scale);
        
        CGRect rect = CGRectMake((outerSize.width - innerSize.width) * 0.5,
                                 (outerSize.height - innerSize.height) * 0.5,
                                 innerSize.width,
                                 innerSize.height);
        [image drawInRect:rect];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    } else {
        return nil;
    }
}

UIImage *NMColorImage(UIImage *image, UIColor *color) {
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    CGContextClipToMask(context, rect, image.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage*newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


@end
