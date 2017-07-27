//
//  NMImagePickerController.m
//  AlbumCollectionDemo
//
//  Created by 孙国林 on 2017/7/18.
//  Copyright © 2017年 孙国林. All rights reserved.
//

#import "NMImagePickerController.h"
#import "NMImageTableViewController.h"
#import "NMImageCollectionViewController.h"
#import "NMImageTableViewCellModel.h"
#import "NMImageCollectionViewCellModel.h"
#import "NMImageConfig.h"

NSString *const NMImagePickerPreferSizedImagekey = @"NMImagePickerPreferSizedImagekey";
NSString *const NMImagePickerDatakey = @"NMImagePickerDatakey";
NSString *const NMImagePickerThumbnailkey = @"NMImagePickerThumbnailkey";
NSString *const NMImagePickerDataUTIkey = @"NMImagePickerDataUTIkey";
NSString *const NMImagePickerOrientationkey = @"NMImagePickerOrientationkey";
NSString *const NMImagePickerInfokey = @"NMImagePickerInfokey";
NSString *const NMImagePickerPixelSizekey = @"NMImagePickerPixelSizekey";

@interface NMImagePickerController ()
<NMImageTableViewControllerDelegate, NMImageCollectionViewControllerDelegate>

@end


@implementation NMImagePickerController {
    
    NSArray *imageTableViewCellModelsArray;
}
@dynamic delegate;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.maximumSelectionCount = 1;
        NMImageTableViewController *itvc = [NMImageTableViewController new];
        itvc.maximumSelectionCount = self.maximumSelectionCount;
        itvc.delegate = self;
        NMImageCollectionViewController *icvc = [NMImageCollectionViewController new];
        icvc.maximumSelectionCount = self.maximumSelectionCount;
        icvc.delegate = self;
        self.viewControllers = @[itvc, icvc];
        self.navigationBar.tintColor = [UIColor whiteColor];
        self.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:17],
                                                   NSForegroundColorAttributeName:NMTintColor()};
        self.navigationBar.barTintColor = NMThemedColor();
        self.preferredSize = CGSizeMake(200, 200);
        self.preferredThumbnailSize = CGSizeMake(60, 60);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
        if (status == PHAuthorizationStatusAuthorized) {
            [self getImageAssetsWithCompletion:^{
                NMImageTableViewController *itvc = self.viewControllers.firstObject;
                itvc.modelsArray = imageTableViewCellModelsArray.copy;
                NMImageCollectionViewController *icvc = self.viewControllers[1];
                icvc.model = itvc.modelsArray.firstObject;
            }];
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                SEL action = @selector(imagePickerControllerDidFailGettingAuthorization:);
                if ([self.delegate respondsToSelector:action]) {
                    [self.delegate imagePickerControllerDidFailGettingAuthorization:self];
                }
            });
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setMaximumSelectionCount:(NSUInteger)maximumSelectionCount {
    _maximumSelectionCount = maximumSelectionCount;
    NMImageTableViewController *itvc = self.viewControllers.firstObject;
    itvc.maximumSelectionCount = maximumSelectionCount;
    if (self.childViewControllers.count == 2) {
        NMImageCollectionViewController *icvc = self.viewControllers[1];
        icvc.maximumSelectionCount = maximumSelectionCount;
    }
}

- (void)getImageAssetsWithCompletion:(void (^)())completion {
    NSMutableArray *mainCollectionsArray = @[].mutableCopy;
    // 遍历所有的自定义相簿
    PHFetchResult<PHAssetCollection *> *collectionsFromAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    [collectionsFromAlbum enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [mainCollectionsArray addObject:obj];
    }];
    // 获得相机胶卷
    PHFetchResult<PHAssetCollection *> *collectionsFromSmartAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    [collectionsFromSmartAlbum enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [mainCollectionsArray addObject:obj];
    }];
    
    NSMutableArray *tempModelsArray = @[].mutableCopy;
    for (PHAssetCollection *assetCollection in mainCollectionsArray) {
        NSMutableArray *mArray = @[].mutableCopy;
        //            NSLog(@"assetCollection.localizedTitle:%@", assetCollection.localizedTitle);
        // 获得某个相簿中的所有PHAsset对象
        PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
        
        NMImageTableViewCellModel *tableViewCellModel = [NMImageTableViewCellModel new];
        tableViewCellModel.assetCollection = assetCollection;
        NSUInteger row = 0;
        for (PHAsset *asset in assets) {
            NMImageCollectionViewCellModel *model = [NMImageCollectionViewCellModel new];
            [mArray addObject:model];
            model.itemSize = itemSize();
            model.pixelSize = CGSizeMake(asset.pixelWidth, asset.pixelHeight);
            model.asset = asset;
            model.indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            row++;
            if (tableViewCellModel.asset == nil) {
                tableViewCellModel.asset = asset;
            }
        }
        
        tableViewCellModel.imageCollectionViewCellModels = mArray.copy;
        [tempModelsArray addObject:tableViewCellModel];
    }
    imageTableViewCellModelsArray = [tempModelsArray sortedArrayUsingComparator:^NSComparisonResult(NMImageTableViewCellModel * obj1, NMImageTableViewCellModel * obj2) {
        NSUInteger count1 = obj1.imageCollectionViewCellModels.count;
        NSUInteger count2 = obj2.imageCollectionViewCellModels.count;
        if (count1 < count2) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
    dispatch_sync(dispatch_get_main_queue(), ^{
        completion();
    });
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        
//    });
}

#pragma mark- NMImageTableViewControllerDelegate
- (void)imageTableViewControllerDidCancel:(NMImageTableViewController *)imageTableViewController {
    [self.delegate imagePickerControllerDidCancel:self];
}

#pragma mark- NMImageCollectionViewControllerDelegate
- (void)imageCollectionViewControllerDidCancel:(NMImageCollectionViewController *)imageTableViewController {
    [self.delegate imagePickerControllerDidCancel:self];
}

- (void)imageCollectionViewController:(NMImageCollectionViewController *)controller didFinishSelectingImagesWithModels:(NSArray <NMImageCollectionViewCellModel *>*)models {
    BOOL flag = [self.delegate respondsToSelector:@selector(imagePickerControllerDidTapSendButton:)];
    if (flag) {
        [self.delegate imagePickerControllerDidTapSendButton:self];
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        BOOL flag1 = self.imagePickerReturnType & NMImagePickerReturnTypeData;
        BOOL flag2 = self.imagePickerReturnType & NMImagePickerReturnTypePreferSizedImage;
        BOOL flag3 = self.imagePickerReturnType & NMImagePickerReturnTypeThumbnail;
        NSMutableArray *mArray = @[].mutableCopy;
        dispatch_semaphore_t semaphore;
        
        if (flag2 || flag3) {
            semaphore = dispatch_semaphore_create(0);
        }
        NSUInteger ii = 0;
        for (NMImageCollectionViewCellModel *model in models) {
            NSMutableDictionary *mDic = @{}.mutableCopy;
            if (flag1) {
                mDic[NMImagePickerDatakey] = model.imageData;
            }
            if (flag2) {
                if (self.needDistinctSized) {
                    NMRequestDistinctSizedImage(model.asset, self.preferredSize, ^(UIImage *image, NSDictionary *info) {
                        mDic[NMImagePickerPreferSizedImagekey] = image;
                        dispatch_semaphore_signal(semaphore);
                    });
                } else {
                    NMRequestImage(model.asset, self.preferredSize, ^(UIImage *image, NSDictionary *info) {
                        mDic[NMImagePickerPreferSizedImagekey] = image;
                        dispatch_semaphore_signal(semaphore);
                    });
                }
            }
            if (flag3) {
                if (self.needThumbnailDistinctSized) {
                    NMRequestDistinctSizedImage(model.asset, self.preferredThumbnailSize, ^(UIImage *image, NSDictionary *info) {
                        mDic[NMImagePickerThumbnailkey] = image;
                        dispatch_semaphore_signal(semaphore);
                    });
                } else {
                    NMRequestImage(model.asset, self.preferredThumbnailSize, ^(UIImage *image, NSDictionary *info) {
                        mDic[NMImagePickerThumbnailkey] = image;
                        dispatch_semaphore_signal(semaphore);
                    });
                }
            }
            mDic[NMImagePickerDataUTIkey] = model.dataUTI;
            mDic[NMImagePickerOrientationkey] = @(model.orientation);
            mDic[NMImagePickerInfokey] = model.info;
            mDic[NMImagePickerPixelSizekey] = [NSValue valueWithCGSize:model.pixelSize];
            
            [mArray addObject:mDic];
            ii++;
        }
        for (NSUInteger ii = 0; ii < models.count; ii++) {
            if (flag2) {
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            }
            if (flag3) {
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            }
        }
        BOOL flag4 = [self.delegate respondsToSelector:@selector(imagePickerController:didFinishRequestingImagesWithInformations:)];
        if (flag4) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.delegate imagePickerController:self didFinishRequestingImagesWithInformations:mArray.copy];
            });
        }
    });
}



@end
