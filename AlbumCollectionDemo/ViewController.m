//
//  ViewController.m
//  AlbumCollectionDemo
//
//  Created by 孙国林 on 2017/7/18.
//  Copyright © 2017年 孙国林. All rights reserved.
//

#import "ViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "NMImagePickerController.h"

@interface ViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, NMImagePickerControllerDelegate>

@end

@implementation ViewController {
    UIImageView *imageView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    imageView = [UIImageView new];
    imageView.frame = self.view.frame;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Debug" style:UIBarButtonItemStyleDone target:self action:@selector(showDebug)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"相册" style:UIBarButtonItemStyleDone target:self action:@selector(show)];
}

- (void)show {
    {
        NMImagePickerController *ipc = [NMImagePickerController new];
        ipc.maximumSelectionCount = 4;
        ipc.imagePickerReturnType = NMImagePickerReturnTypeData|NMImagePickerReturnTypePreferSizedImage|NMImagePickerReturnTypeThumbnail;
        ipc.delegate = self;
        [self presentViewController:ipc animated:YES completion:nil];
    }
    
#if 0
    
    UIImagePickerController *ipc = [UIImagePickerController new];
    ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    NSString *str = (__bridge NSString *)kUTTypeImage;
    ipc.mediaTypes = @[str];
    ipc.delegate = self;
    ipc.allowsEditing = YES;
    [self presentViewController:ipc animated:YES completion:^{
        
    }];
#endif
}

- (void)showDebug {
#if 0
    Class overlayClass = NSClassFromString(@"UIDebuggingInformationOverlay");
    
    SEL selector = NSSelectorFromString(@"prepareDebuggingOverlay");
    IMP imp = [overlayClass methodForSelector:selector];
    void (*func)(Class, SEL) = (void *)imp;
    func(overlayClass, selector);
    
    selector = NSSelectorFromString(@"overlay");
    imp = [overlayClass methodForSelector:selector];
    id (*func2)(Class, SEL) = (void *)imp;
    id overlay = func2(overlayClass, selector);
    
    selector = NSSelectorFromString(@"toggleVisibility");
    imp = [overlay methodForSelector:selector];
    void (*func3)(id, SEL) = (void *)imp;
    func3(overlay, selector);
#endif
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#if 0
#pragma mark- UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [self dismissViewControllerAnimated:YES completion:nil];
    // 选择的图片信息存储于info字典中
    NSLog(@"%@", info);
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    imageView.image = image;
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}
#endif

#pragma mark- NMImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(NMImagePickerController *)controller {
    NSLog(@"imagePickerControllerDidCancel");
    [controller dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)imagePickerControllerDidTapSendButton:(NMImagePickerController *)controller {
    [controller dismissViewControllerAnimated:YES completion:^{
        NSLog(@"imagePickerControllerDidTapSendButton");
    }];
}

- (void)imagePickerController:(NMImagePickerController *)controller didFinishRequestingImagesWithInformations:(NSArray<NSDictionary<NSString *, id> *> *)informations {
    NSLog(@"didFinishRequestingImagesWithInformations:%@", informations);
}

- (void)imagePickerControllerDidFailGettingAuthorization:(NMImagePickerController *)controller {
    [controller dismissViewControllerAnimated:YES completion:^{
        NSLog(@"imagePickerControllerDidFailGettingAuthorization");
    }];
}

#pragma mark- UINavigationControllerDelegate

@end
