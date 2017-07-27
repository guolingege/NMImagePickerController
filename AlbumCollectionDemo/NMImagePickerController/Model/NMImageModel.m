//
//  NMImageModel.m
//  AlbumCollectionDemo
//
//  Created by 孙国林 on 2017/7/18.
//  Copyright © 2017年 孙国林. All rights reserved.
//

#import "NMImageModel.h"

@implementation NMImageModel

+ (PHImageRequestOptions *)defaultOption {
    static PHImageRequestOptions *option;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        option = [PHImageRequestOptions new];
        option.synchronous = YES;
    });
    return option;
}

void NMCancelRequest(PHImageRequestID requestID) {
    PHImageManager *manager = [PHImageManager defaultManager];
    [manager cancelImageRequest:requestID];
}

PHImageRequestID NMRequestImage(PHAsset *asset, CGSize targetSize, void (^completion)(UIImage *image, NSDictionary *info)) {
    PHImageManager *manager = [PHImageManager defaultManager];
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize size = targetSize;
    size.width *= scale,
    size.height *= scale;
    return [manager requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:[NMImageModel defaultOption] resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        completion(result, info);
    }];
}

PHImageRequestID NMRequestDistinctSizedImage(PHAsset *asset, CGSize targetSize, void (^completion)(UIImage *image, NSDictionary *info)) {
    PHImageManager *manager = [PHImageManager defaultManager];
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize size = targetSize;
    size.width *= scale,
    size.height *= scale;
    return [manager requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:[NMImageModel defaultOption] resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        completion(NMScaleImageToTargetSize(result, targetSize), info);
    }];
}

UIImage *NMScaleImageToTargetSize(UIImage *image, CGSize targetSize) {
    CGFloat ww = image.size.width;
    CGFloat hh = image.size.height;
    
    BOOL flag1 = ww <= targetSize.width;
    BOOL flag2 = hh <= targetSize.height;
    if (flag1 || flag2) {
        return image;
    }
    
    CGFloat scale = 0;
    scale = MAX(targetSize.width/ww, targetSize.height/hh);
    ww *= scale;
    hh *= scale;
    CGRect rect = CGRectMake(0, 0, ww, hh);
    scale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(ww, hh), NO, scale);
    [image drawInRect:rect];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
