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

@interface NMImageBrowseView ()
<UICollectionViewDataSource, UICollectionViewDelegate, NMImageBrowseCollectionViewDelegate, NMImageBrowseViewCellDelegate>

@property (nonatomic, strong) NSArray <NMImageCollectionViewCellModel *>*collectionViewCellModels;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, weak) id <NMImageBrowseViewDelegate>privateDelegate;
@property (nonatomic, strong) NMImageBrowseCollectionView *imageBrowseCollectionView;
@property (nonatomic, strong) UICollectionView *originalCollecionView;
@property (nonatomic, strong) UIView *controllerView;

@end

@implementation NMImageBrowseView {
    UIView *topView;
    UIView *selectionView;
    UIView *bottomView;
    NMImageBrowseViewCell *currentCell;
    UIImageView *frontImageView;
}

#pragma mark- overwrite super methods
- (instancetype)init
{
    self = [super init];
    if (self) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        CGFloat ww = [UIScreen mainScreen].bounds.size.width;
        CGFloat hh = [UIScreen mainScreen].bounds.size.height;
        CGRect rect = CGRectMake(-NMImageBrowseCollectionViewCellGap * 0.5, 0, ww + NMImageBrowseCollectionViewCellGap, hh);
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
        [imageBrowseCollectionView registerClass:[NMImageBrowseViewCell class] forCellWithReuseIdentifier:NMImageBrowseViewCellID];
        [self addSubview:imageBrowseCollectionView];
        self.imageBrowseCollectionView = imageBrowseCollectionView;
        
        topView = [UIView new];
        CGSize size = [UIScreen mainScreen].bounds.size;
        rect = CGRectMake(0, 0, size.width, 44);
        topView.frame = rect;
        topView.backgroundColor = NMThemedColor();
        topView.alpha = 0;
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
        
        frontImageView = [UIImageView new];
        frontImageView.frame = [UIScreen mainScreen].bounds;
        frontImageView.contentMode = UIViewContentModeScaleAspectFit;
        frontImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:frontImageView];
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

#pragma mark- public methods
+ (instancetype)viewWithCollectionViewCellModels:(NSArray <NMImageCollectionViewCellModel *>*)models
                                   fromIndexPath:(NSIndexPath *)indexPath
                                  collectionView:(UICollectionView *)collectionView
                                  controllerView:(UIView *)controllerView
                                        delegate:(id<NMImageBrowseViewDelegate>)delegate {
    NMImageBrowseView *browseView = [NMImageBrowseView new];
    browseView.frame = [UIScreen mainScreen].bounds;
    browseView.backgroundColor = [UIColor clearColor];
    browseView.collectionViewCellModels = models;
    browseView.indexPath = indexPath;
    browseView.privateDelegate = delegate;
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
    
    NMImageCollectionViewCellModel *model = self.collectionViewCellModels[self.indexPath.row];
    CGRect rect = [self scaleDownTargetFrameToIndexPath:self.indexPath];
    frontImageView.transform = [self transformWithModel:model targetFrame:rect];
    NMRequestImage(model.asset, frontImageView.frame.size, ^(UIImage *image, NSDictionary *info) {
        frontImageView.image = image;
    });
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        frontImageView.transform = CGAffineTransformIdentity;
        self.backgroundColor = [UIColor blackColor];
        self.imageBrowseCollectionView.transform = CGAffineTransformIdentity;
        topView.alpha = 1;
        [self scaleUpAnimation];
    } completion:^(BOOL finished) {
        [frontImageView removeFromSuperview];
        self.imageBrowseCollectionView.hidden = NO;
        completion();
    }];
}

- (void)hideToCollectionView {
    [currentCell scaleDown];
}

#pragma mark- UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.collectionViewCellModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NMImageBrowseViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NMImageBrowseViewCellID forIndexPath:indexPath];
    cell.model = self.collectionViewCellModels[indexPath.row];
    cell.indexPath = indexPath;
    cell.delegate = self;
    return cell;
}

#pragma mark- UICollectionViewDelegate

#pragma mark- UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [currentCell setPanGREnabled:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
}

#pragma mark- NMImageBrowseCollectionViewDelegate
- (void)imageBrowseCollectionViewDidEndOrCancelled:(NMImageBrowseCollectionView *)iiimageBrowseCollectionView {
    [currentCell setPanGREnabled:YES];
}

#pragma mark- NMImageBrowseViewCellDelegate
- (void)imageBrowseViewCellDidbeginTouch:(NMImageBrowseViewCell *)cell {
    currentCell = cell;
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
    [self.privateDelegate imageBrowseViewDidBeginHide:self fromCurrentIndex:cell.indexPath.row];
}

- (void)imageBrowseViewCellDidBeDragged:(NMImageBrowseViewCell *)cell withCollectionViewContentOffset:(CGPoint)offset progress:(CGFloat)progress {
    self.imageBrowseCollectionView.contentOffset = offset;
    topView.alpha = 1 - progress;
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1 - progress];
}

- (CGRect)scaleDownTargetFrameToIndexPath:(NSIndexPath *)indexPath {
    CGRect rect = [self.originalCollecionView cellForItemAtIndexPath:indexPath].frame;
    rect = [self.originalCollecionView convertRect:rect toView:self.controllerView];
    return rect;
}

- (void)scaleDownAnimation {
    topView.alpha = 0;
    self.backgroundColor = [UIColor clearColor];
}

- (void)scaleDownAnimationCompletion {
    [self removeFromSuperview];
    [self.privateDelegate imageBrowseViewDidHide:self];
}

- (void)scaleUpAnimation {
    topView.alpha = 1;
    self.backgroundColor = [UIColor blackColor];
}

- (void)scaleUpAnimationCompletion {
    [self.privateDelegate imageBrowseViewDidCancelHide:self];
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
