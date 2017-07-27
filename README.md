# NMImagePickerController
A controller for picking photos from album

For example:

```HPH
    NMImagePickerController *ipc = [NMImagePickerController new];
    ipc.maximumSelectionCount = 4;
    ipc.imagePickerReturnType = NMImagePickerReturnTypeData|NMImagePickerReturnTypePreferSizedImage|NMImagePickerReturnTypeThumbnail;
    ipc.delegate = self;
    [self presentViewController:ipc animated:YES completion:nil];
```
