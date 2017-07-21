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
    NSArray *imageModels;
    BOOL didLoad;
    NSMutableArray *selectedArray;
    NSMutableArray *cellsArray;
    UIButton *previewButton;
    UIButton *sendButton;
    BOOL prefersStatusBarHidden;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        if (self.title.length == 0) {
            self.title = @"所有照片";
            selectedArray = @[].mutableCopy;
            cellsArray = @[].mutableCopy;
        }
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (didLoad == NO) {
        didLoad = YES;
        self.title = self.model.assetCollection.localizedTitle;
        imageModels = self.model.imageCollectionViewCellModels;
        [self.collectionView reloadData];
        if (imageModels.count) {
            //        NSIndexPath *bottomIndexPath = [NSIndexPath indexPathForRow:imageModels.count - 1 inSection:0];
            //        [self.collectionView scrollToItemAtIndexPath:bottomIndexPath atScrollPosition:UICollectionViewScrollPositionRight|UICollectionViewScrollPositionBottom animated:NO];
            self.collectionView.contentOffset = CGPointMake(0, 99999);
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
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
//    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.bounces = YES;
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
    
    UIFont *font = [UIFont systemFontOfSize:15];
    
    previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    previewButton.frame = CGRectMake(0, yy, hh * 1.8, hh);
    [previewButton setTitle:@"预览" forState:UIControlStateNormal];
    previewButton.titleLabel.font = font;
    [previewButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [previewButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [previewButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [previewButton addTarget:self action:@selector(preview) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:previewButton];
    
    sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat hh2 = hh * 0.7;
    yy += (hh - hh2) * 0.5;
    CGFloat ww = hh2 * 1.6;
    sendButton.frame = CGRectMake(rect.size.width - ww * 1.2, yy, ww, hh2);
    [sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    sendButton.titleLabel.font = font;
    [sendButton addTarget:self action:@selector(finishSelection) forControlEvents:UIControlEventTouchUpInside];
    CGFloat red = 31/255.0, green = 190/255.0, blue = 34/255.0, scale = 0.75;
    UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:1];
    UIImage *image = NMRoundRectImage(sendButton.frame.size, color, hh * 0.15);
    [sendButton setBackgroundImage:image forState:UIControlStateNormal];
    color = [UIColor colorWithRed:red * scale green:green * scale blue:blue * scale alpha:1];
    image = NMRoundRectImage(sendButton.frame.size, color, hh * 0.15);
    [sendButton setBackgroundImage:image forState:UIControlStateHighlighted];
    image = NMRoundRectImage(sendButton.frame.size, [UIColor lightGrayColor], hh * 0.15);
    [sendButton setBackgroundImage:image forState:UIControlStateDisabled];
    [self.view addSubview:sendButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)preview {
    NMImageCollectionViewCellModel *model = imageModels.firstObject;
    [self previewFromModel:model indexPath:model.indexPath];
}

- (void)finishSelection {
    [self.delegate imageCollectionViewController:self didFinishSelectingImagesWithModels:selectedArray.copy];
}

- (void)cancel {
    [self.delegate imageCollectionViewControllerDidCancel:self];
}

- (void)previewFromModel:(NMImageCollectionViewCellModel *)model indexPath:(NSIndexPath *)indexPath {
    if (model == nil) {
        return;
    }
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    NMImageBrowseView *browseView = [NMImageBrowseView viewWithCollectionViewCellModels:imageModels fromIndexPath:indexPath collectionView:self.collectionView controllerView:self.navigationController.view delegate:self];
    [browseView showWithCompletion:^{
        prefersStatusBarHidden = YES;
        [self setNeedsStatusBarAppearanceUpdate];
    }];
}

#pragma mark- UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return imageModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NMImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NMImageCollectionViewCellID forIndexPath:indexPath];
    
    cell.model = imageModels[indexPath.row];
    cell.model.indexPath = indexPath;
    cell.delegate = self;
    
    if (![cellsArray containsObject:cell]) {
        [cellsArray addObject:cell];
    }
    
    return cell;
}

#pragma mark- UICollectionViewDelegate

#pragma mark- NMImageCollectionViewCellDelegate
- (void)imageCollectionViewCell:(NMImageCollectionViewCell *)mageCollectionViewCell didSelectAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"didSelectAtIndexPath:%zd", indexPath.row);
    NMImageCollectionViewCellModel *model = imageModels[indexPath.row];
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
        for (NMImageCollectionViewCellModel *model in imageModels) {
            if (!model.isSelected) {
                model.selectable = NO;
            }
        }
    }
}

- (void)imageCollectionViewCell:(NMImageCollectionViewCell *)mageCollectionViewCell didDeselectAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"didDeselectAtIndexPath:%zd", indexPath.row);
    NMImageCollectionViewCell *ccccell = (NMImageCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    [ccccell deselect];
    
    NSUInteger count = selectedArray.count;
    BOOL flag = count == self.maximumSelectionCount;
    
    NMImageCollectionViewCellModel *model = imageModels[indexPath.row];
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
        for (NMImageCollectionViewCellModel *model in imageModels) {
            model.selectable = YES;
        }
    }
}

- (void)imageCollectionViewCell:(NMImageCollectionViewCell *)mageCollectionViewCell didTapWithoutSelectionAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didTapWithoutSelectionAtIndexPath");
    [self previewFromModel:imageModels[indexPath.row] indexPath:indexPath];
}

#pragma mark- NMImageBrowseViewDelegate
- (void)imageBrowseViewDidTapBackButton:(NMImageBrowseView *)imageBrowseView {
    [imageBrowseView hideToCollectionView];
    prefersStatusBarHidden = NO;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)imageBrowseView:(NMImageBrowseView *)imageBrowseView didSelectModel:(NMImageCollectionViewCellModel *)model {
    [selectedArray addObject:model];
}

- (void)imageBrowseView:(NMImageBrowseView *)imageBrowseView didDeselectModel:(NMImageCollectionViewCellModel *)model {
    [selectedArray removeObject:model];
}

- (void)imageBrowseViewDidTapSendButton:(NMImageBrowseView *)imageBrowseView {
    [self.delegate imageCollectionViewController:self didFinishSelectingImagesWithModels:selectedArray.copy];
    prefersStatusBarHidden = NO;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)imageBrowseViewDidBeginHide:(NMImageBrowseView *)imageBrowseView fromCurrentIndex:(NSUInteger)index {
    prefersStatusBarHidden = NO;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)imageBrowseViewDidHide:(NMImageBrowseView *)imageBrowseView {
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)imageBrowseViewDidCancelHide:(NMImageBrowseView *)imageBrowseView {
    prefersStatusBarHidden = YES;
    [self setNeedsStatusBarAppearanceUpdate];
}

#pragma mark- UIStatusBar
- (BOOL)prefersStatusBarHidden {
    return prefersStatusBarHidden;
}

@end
