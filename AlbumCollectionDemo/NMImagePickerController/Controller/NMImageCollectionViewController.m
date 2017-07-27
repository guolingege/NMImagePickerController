//
//  NMImageCollectionViewController.m
//  AlbumCollectionDemo
//
//  Created by 孙国林 on 2017/7/18.
//  Copyright © 2017年 孙国林. All rights reserved.
//

#import "NMImageCollectionViewController.h"
#import "NMImageCollectionViewCellModel.h"
#import "NMImageCollectionViewCell.h"
#import "NMImageConfig.h"
#import "NMImageImageMaker.h"
#import "NMImageBrowseView.h"

@interface NMImageCollectionViewController ()
<UICollectionViewDataSource, UICollectionViewDelegate, NMImageCollectionViewCellDelegate, NMImageBrowseViewDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;

@end



@implementation NMImageCollectionViewController {
    NSMutableArray<NMImageCollectionViewCellModel *> *selectedArray;
    NSMutableArray<NMImageCollectionViewCell *> *cellsArray;
    UIButton *previewButton;
    UIButton *sendButton;
    BOOL prefersStatusBarHidden;
    NMImageCollectionViewCell *theHiddenCell;
    BOOL isBrowseViewHidden;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        if (self.title.length == 0) {
            self.title = @"所有照片";
            selectedArray = @[].mutableCopy;
            cellsArray = @[].mutableCopy;
            isBrowseViewHidden = YES;
        }
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CGFloat itemCount = self.model.imageCollectionViewCellModels.count;
    if (itemCount) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:itemCount - 1 inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    CGRect rect = CGRectMake(0, 0, size.width, size.height - 40);
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.itemSize = itemSize();
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = minimumLineSpacing;
    layout.minimumInteritemSpacing = minimumInteritemSpacing;
    layout.sectionInset = UIEdgeInsetsMake(0, leftInset, 0, rightInset);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.bounces = YES;
    self.collectionView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset;
    [self.view addSubview:self.collectionView];
    
    [self.collectionView registerClass:[NMImageCollectionViewCell class] forCellWithReuseIdentifier:NMImageCollectionViewCellID];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancel)];
    
    CAShapeLayer *layer = [CAShapeLayer new];
    CGFloat yy = CGRectGetMaxY(rect);
    CGFloat hh = [UIScreen mainScreen].bounds.size.height - yy;
    rect = CGRectMake(0, yy, rect.size.width, hh);
    UIBezierPath *bPath = [UIBezierPath bezierPathWithRect:rect];
    layer.path = bPath.CGPath;
    layer.fillColor = NMThemedColor().CGColor;
    [self.view.layer addSublayer:layer];
    
    UIFont *font = [UIFont systemFontOfSize:14];
    
    previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    previewButton.frame = CGRectMake(0, yy, hh * 1.8, hh);
    [previewButton setTitle:@"预览" forState:UIControlStateNormal];
    previewButton.titleLabel.font = font;
    [previewButton setTitleColor:NMTintColor() forState:UIControlStateNormal];
    [previewButton setTitleColor:NMTintLightColor() forState:UIControlStateHighlighted];
    [previewButton setTitleColor:NMTintDarkColor() forState:UIControlStateDisabled];
    [previewButton addTarget:self action:@selector(preview) forControlEvents:UIControlEventTouchUpInside];
    previewButton.enabled = NO;
    [self.view addSubview:previewButton];
    
    sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat hh2 = hh * 0.7;
    yy += (hh - hh2) * 0.5;
    CGFloat ww = hh2 * 2.2;
    sendButton.frame = CGRectMake(rect.size.width - ww - 6, yy, ww, hh2);
    [sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [sendButton setTitleColor:NMTintColor() forState:UIControlStateNormal];
    [sendButton setTitleColor:NMTintLightColor() forState:UIControlStateHighlighted];
    [sendButton setTitleColor:NMTintDarkColor() forState:UIControlStateDisabled];
    sendButton.titleLabel.font = font;
    [sendButton addTarget:self action:@selector(finishSelection) forControlEvents:UIControlEventTouchUpInside];
    UIImage *image = NMRoundRectImage(sendButton.frame.size, NMActiveColor(), hh * 0.15);
    [sendButton setBackgroundImage:image forState:UIControlStateNormal];
    image = NMRoundRectImage(sendButton.frame.size, NMActiveLightColor(), hh * 0.15);
    [sendButton setBackgroundImage:image forState:UIControlStateHighlighted];
    image = NMRoundRectImage(sendButton.frame.size, NMActiveDarkColor(), hh * 0.15);
    [sendButton setBackgroundImage:image forState:UIControlStateDisabled];
    sendButton.enabled = NO;
    [self.view addSubview:sendButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- Private Methods
- (void)setModel:(NMImageTableViewCellModel *)model {
    _model = model;
    self.title = self.model.assetCollection.localizedTitle;
    
    for (NMImageCollectionViewCellModel *blockModel in model.imageCollectionViewCellModels) {
        blockModel.selectable = YES;
        blockModel.isSelected = NO;
    }
    
    [self.collectionView reloadData];
    CGFloat itemCount = model.imageCollectionViewCellModels.count;
    if (itemCount) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:itemCount - 1 inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    }
}

- (void)preview {
    NMImageCollectionViewCellModel *model = selectedArray.firstObject;
    NSIndexPath *indexPath = model.indexPath;
    CGRect rect1 = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64 - 40);
    CGRect rect2 = [self.collectionView cellForItemAtIndexPath:indexPath].frame;
    rect2 = [self.collectionView convertRect:rect2 toView:self.view];
    BOOL flag = CGRectContainsRect(rect1, rect2);
    if (!flag) {
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self previewFromModel:model indexPath:indexPath completionHandler:nil];
        });
    } else {
        [self previewFromModel:model indexPath:indexPath completionHandler:nil];
    }
}

- (void)finishSelection {
    [self.delegate imageCollectionViewController:self didFinishSelectingImagesWithModels:selectedArray.copy];
}

- (void)cancel {
    [self.delegate imageCollectionViewControllerDidCancel:self];
}

- (void)previewFromModel:(NMImageCollectionViewCellModel *)model indexPath:(NSIndexPath *)indexPath completionHandler:(void (^)())completionHandler {
    if (model == nil) {
        return;
    }
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.navigationController.navigationBar.userInteractionEnabled = NO;
    NMImageBrowseView *browseView = [NMImageBrowseView viewWithAllModels:self.model.imageCollectionViewCellModels
                                                          selectedModels:selectedArray
                                                           fromIndexPath:indexPath
                                                          collectionView:self.collectionView
                                                          controllerView:self.navigationController.view
                                                                delegate:self
                                                   maximumSelectionCount:self.maximumSelectionCount];
    [browseView showWithCompletion:^{
        prefersStatusBarHidden = YES;
        [self setNeedsStatusBarAppearanceUpdate];
        if (completionHandler) {
            completionHandler();
        }
    }];
}

- (void)selectWithModel:(NMImageCollectionViewCellModel *)model {
    model.selectable = YES;
    model.isSelected = YES;
    [selectedArray addObject:model];
    NSUInteger ii = 1;
    NSUInteger count = selectedArray.count;
    BOOL flag = count >= self.maximumSelectionCount;
    for (NMImageCollectionViewCellModel *blockModel in selectedArray) {
        blockModel.number = ii;
        NMImageCollectionViewCell *cell = (NMImageCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:blockModel.indexPath];
        [cell selectWithNumber:ii];
        ii++;
    }
    if (self.maximumSelectionCount == 0) {
        [NSException raise:@"maximumSelectionCount 不能为0" format:@""];
    }
    if (flag) {
        for (NMImageCollectionViewCell *theCell in cellsArray) {
            if (!theCell.model.isSelected) {
                theCell.selectable = NO;
            }
        }
        for (NMImageCollectionViewCellModel *model in self.model.imageCollectionViewCellModels) {
            if (!model.isSelected) {
                model.selectable = NO;
            }
        }
    }
    
    previewButton.enabled = YES;
    NSString *title = [NSString stringWithFormat:@"发送(%zd)", count];
    [sendButton setTitle:title forState:UIControlStateNormal];
    sendButton.enabled = YES;
}

- (void)deselectWithModel:(NMImageCollectionViewCellModel *)model {
    NMImageCollectionViewCell *cell = (NMImageCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:model.indexPath];
    [cell deselect];
    NSUInteger count = selectedArray.count;
    BOOL flag = count == self.maximumSelectionCount;
    model.isSelected = NO;
    [selectedArray removeObject:model];
    NSUInteger ii = 1;
    for (NMImageCollectionViewCellModel *blockModel in selectedArray) {
        blockModel.number = ii;
        NMImageCollectionViewCell *cell = (NMImageCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:blockModel.indexPath];
        [cell selectWithNumber:ii];
        ii++;
    }
    if (self.maximumSelectionCount == 0) {
        [NSException raise:@"maximumSelectionCount 不能为0" format:@""];
    }
    if (flag) {
        for (NMImageCollectionViewCell *theCell in cellsArray) {
            theCell.selectable = YES;
        }
        for (NMImageCollectionViewCellModel *blockModel in self.model.imageCollectionViewCellModels) {
            blockModel.selectable = YES;
        }
    }
    count = selectedArray.count;
    if (count == 0) {
        previewButton.enabled = NO;
        [sendButton setTitle:@"发送" forState:UIControlStateNormal];
        sendButton.enabled = NO;
    } else {
        NSString *title = [NSString stringWithFormat:@"发送(%zd)", count];
        [sendButton setTitle:title forState:UIControlStateNormal];
    }
}

#pragma mark- UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.model.imageCollectionViewCellModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NMImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NMImageCollectionViewCellID forIndexPath:indexPath];
    
    cell.model = self.model.imageCollectionViewCellModels[indexPath.row];
    cell.delegate = self;
    
    if (![cellsArray containsObject:cell]) {
        [cellsArray addObject:cell];
    }
    
    return cell;
}

#pragma mark- UICollectionViewDelegate

#pragma mark- UIScrollViewDelegate
- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    return isBrowseViewHidden;
}

#pragma mark- NMImageCollectionViewCellDelegate
- (void)imageCollectionViewCell:(NMImageCollectionViewCell *)imageCollectionViewCell didSelectAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"didSelectAtIndexPath:%zd", indexPath.row);
    [self selectWithModel:imageCollectionViewCell.model];
}

- (void)imageCollectionViewCell:(NMImageCollectionViewCell *)imageCollectionViewCell didDeselectAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"didDeselectAtIndexPath:%zd", indexPath.row);
    [self deselectWithModel:imageCollectionViewCell.model];
}

- (void)imageCollectionViewCell:(NMImageCollectionViewCell *)imageCollectionViewCell didTapWithoutSelectionAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"didTapWithoutSelectionAtIndexPath");
    imageCollectionViewCell.imageHidden = YES;
    theHiddenCell = imageCollectionViewCell;
    [self previewFromModel:imageCollectionViewCell.model indexPath:indexPath completionHandler:^{
        theHiddenCell.imageHidden = NO;
    }];
}

#pragma mark- NMImageBrowseViewDelegate
- (void)imageBrowseViewDidTapBackButton:(NMImageBrowseView *)imageBrowseView {
    [imageBrowseView hideToCollectionView];
    prefersStatusBarHidden = NO;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)imageBrowseViewDidTapSendButton:(NMImageBrowseView *)imageBrowseView {
    [self.delegate imageCollectionViewController:self didFinishSelectingImagesWithModels:selectedArray.copy];
    prefersStatusBarHidden = NO;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)imageBrowseView:(NMImageBrowseView *)imageBrowseView didSelectModel:(NMImageCollectionViewCellModel *)model {
    [self selectWithModel:model];
}

- (void)imageBrowseView:(NMImageBrowseView *)imageBrowseView didDeselectModel:(NMImageCollectionViewCellModel *)model {
    [self deselectWithModel:model];
}

- (void)imageBrowseViewDidBeginHide:(NMImageBrowseView *)imageBrowseView
                   fromCurrentIndex:(NSUInteger)index
                 withSelectedModels:(NSMutableArray<NMImageCollectionViewCellModel *> *)selectedModels {
    prefersStatusBarHidden = NO;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    CGRect rect2 = [self.collectionView cellForItemAtIndexPath:indexPath].frame;
    rect2 = [self.collectionView convertRect:rect2 toView:self.view];
    CGRect rect1 = [UIScreen mainScreen].bounds;
    rect1.size.height -= 40 + 64;
    rect1.origin.y += 64;
    BOOL flag = CGRectContainsRect(rect1, rect2);
    if (!flag) {
        CGFloat topY1 = CGRectGetMinY(rect1);
        CGFloat topY2 = CGRectGetMinY(rect2);
        CGFloat bottomY1 = CGRectGetMaxY(rect1);
        CGFloat bottomY2 = CGRectGetMaxY(rect2);
        BOOL flag1 = topY1 > topY2;
        BOOL flag2 = bottomY1 < bottomY2;
        UICollectionViewScrollPosition position = UICollectionViewScrollPositionNone;
        if (flag1) {
            position = UICollectionViewScrollPositionTop;
        } else if (flag2) {
            position = UICollectionViewScrollPositionBottom;
        }
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:position animated:NO];
    }
    [self setNeedsStatusBarAppearanceUpdate];
    
    theHiddenCell = (NMImageCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    theHiddenCell.imageHidden = YES;
    isBrowseViewHidden = NO;
}

- (void)imageBrowseViewDidHide:(NMImageBrowseView *)imageBrowseView {
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    theHiddenCell.imageHidden = NO;
    isBrowseViewHidden = YES;
}

- (void)imageBrowseViewDidCancelHide:(NMImageBrowseView *)imageBrowseView {
    prefersStatusBarHidden = YES;
    [self setNeedsStatusBarAppearanceUpdate];
    theHiddenCell.imageHidden = NO;
}

#pragma mark- UIStatusBar
- (BOOL)prefersStatusBarHidden {
    return prefersStatusBarHidden;
}

@end
