# NMImagePickerController
A controller for picking photos from album

Intro:</br>
&emsp;&emsp;&emsp;Copied Wechat's image picker controller;</br>
&emsp;&emsp;&emsp;Optimized memory usage;</br>
&emsp;&emsp;&emsp;The memory usage will be increase quickly only when the properies 'needDistinctSized' or 'needThumbnailDistinctSized' is YES;</br>
&emsp;&emsp;&emsp;You can pick image or image data or both!</br>
&emsp;&emsp;&emsp;The preview view supports four gesture recognizers:single tap, double tap, pinch and pan;</br>
&emsp;&emsp;&emsp;There is an error with the pan gesture recognizer while you use it to exit the preview view;</br>
&emsp;&emsp;&emsp;The rotation gesture recognizer is comming soon....</br>

Usage example:</br>
&emsp;&emsp;&emsp;import "NMImagePickerController.h" first.

```HPH
    NMImagePickerController *ipc = [NMImagePickerController new];
    ipc.maximumSelectionCount = 4;
    ipc.imagePickerReturnType = NMImagePickerReturnTypeData|NMImagePickerReturnTypePreferSizedImage|NMImagePickerReturnTypeThumbnail;
    ipc.delegate = self;
    [self presentViewController:ipc animated:YES completion:nil];
```


