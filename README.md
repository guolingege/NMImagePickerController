# NMImagePickerController
A controller for picking photos from album

Intro:
    Optimized memory usage.</br>
    The memory usage will be increase quickly only when the properies</br>
'needDistinctSized' or 'needThumbnailDistinctSized' is YES.</br>
    You can pick image or image data or both!</br>
    The preview view supports four gesture recognizers:single tap, double tap, zoom and pinch.</br>
    The rotation is comming soon....</br>

Usage example:
    
    import "NMImagePickerController.h" first.
```HPH
    NMImagePickerController *ipc = [NMImagePickerController new];
    ipc.maximumSelectionCount = 4;
    ipc.imagePickerReturnType = NMImagePickerReturnTypeData|NMImagePickerReturnTypePreferSizedImage|NMImagePickerReturnTypeThumbnail;
    ipc.delegate = self;
    [self presentViewController:ipc animated:YES completion:nil];
```


