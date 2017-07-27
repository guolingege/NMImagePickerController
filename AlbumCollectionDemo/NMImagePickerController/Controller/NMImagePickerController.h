//
//  NMImagePickerController.h
//  AlbumCollectionDemo
//
//  Created by 孙国林 on 2017/7/18.
//  Copyright © 2017年 孙国林. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 UIImage
 */
extern NSString *const NMImagePickerPreferSizedImagekey;
/**
 NSData
 */
extern NSString *const NMImagePickerDatakey;
/**
 UIImage
 */
extern NSString *const NMImagePickerThumbnailkey;
/**
 NSString
 */
extern NSString *const NMImagePickerDataUTIkey;
/**
 NSNumber->UIImageOrientation
 */
extern NSString *const NMImagePickerOrientationkey;
/**
 NSDictionary
 */
extern NSString *const NMImagePickerInfokey;
/**
 NSValue->CGSize
 */
extern NSString *const NMImagePickerPixelSizekey;

typedef NS_ENUM(NSUInteger, NMImagePickerReturnType) {
    NMImagePickerReturnTypeNone = 0,
    /**
     在结果中包含图片二进制数据
     */
    NMImagePickerReturnTypeData = 1 << 1,
    /**
     在结果中包含按目标尺寸裁剪的图片
     */
    NMImagePickerReturnTypePreferSizedImage = 1 << 2,
    /**
     在结果中包含缩略图
     */
    NMImagePickerReturnTypeThumbnail = 1 << 3
};

@protocol NMImagePickerControllerDelegate;

@interface NMImagePickerController : UINavigationController

@property (nonatomic, weak) id <NMImagePickerControllerDelegate, UINavigationControllerDelegate>delegate;
/**
 数据返回类型 默认 NMImagePickerReturnTypeNone
 */
@property (nonatomic, assign) NMImagePickerReturnType imagePickerReturnType;
/**
 需要将大图加工成严格的尺寸 默认为NO 开启以后会增加内存消耗 尤其选择大图时会大量增加瞬时内存
 */
@property (nonatomic, assign) BOOL needDistinctSized;
/**
 需要将缩略图加工成严格的尺寸 默认为NO 开启以后会增加内存消耗 尤其选择大图时会大量增加瞬时内存
 */
@property (nonatomic, assign) BOOL needThumbnailDistinctSized;
/**
 目标图片尺寸 默认 (200, 200)
 */
@property (nonatomic, assign) CGSize preferredSize;
/**
 缩略图尺寸 默认 (60, 60)
 */
@property (nonatomic, assign) CGSize preferredThumbnailSize;

/**
 default 1
 */
@property (nonatomic, assign) NSUInteger maximumSelectionCount;

@end

@protocol NMImagePickerControllerDelegate <NSObject>

@optional
- (void)imagePickerControllerDidCancel:(NMImagePickerController *)controller;
- (void)imagePickerControllerDidTapSendButton:(NMImagePickerController *)controller;
/**
 从点击发送按钮到成功获取所有图片需要一点点时间

 @param informations 图片信息的数组
 */
- (void)imagePickerController:(NMImagePickerController *)controller didFinishRequestingImagesWithInformations:(NSArray <NSDictionary <NSString *, id>*>*)informations;

- (void)imagePickerControllerDidFailGettingAuthorization:(NMImagePickerController *)controller;

@end
