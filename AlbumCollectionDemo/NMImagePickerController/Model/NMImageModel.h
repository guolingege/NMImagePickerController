//
//  NMImageModel.h
//  AlbumCollectionDemo
//
//  Created by 孙国林 on 2017/7/18.
//  Copyright © 2017年 孙国林. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface NMImageModel : NSObject

@property (nonatomic, assign) PHImageRequestID requestID;
@property (nonatomic, strong) NSData *imageData;
@property (nonatomic, copy) NSString *dataUTI;
@property (nonatomic, assign) UIImageOrientation orientation;
@property (nonatomic, strong) NSDictionary *info;
@property (nonatomic, assign) CGSize pixelSize;

@property (nonatomic, strong) PHAsset *asset;

PHImageRequestID NMRequestImage(PHAsset *asset, CGSize targetSize, void (^completion)(UIImage *image, NSDictionary *info));
PHImageRequestID NMRequestDistinctSizedImage(PHAsset *asset, CGSize targetSize, void (^completion)(UIImage *image, NSDictionary *info));

void NMCancelRequest(PHImageRequestID requestID);

/**
 同步获得图片, 只会返回1张图片

 @return PHImageRequestOptions
 */
+ (PHImageRequestOptions *)defaultOption;

@end

