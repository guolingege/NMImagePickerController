//
//  NMImageCollectionViewCell.m
//  AlbumCollectionDemo
//
//  Created by 孙国林 on 2017/7/18.
//  Copyright © 2017年 孙国林. All rights reserved.
//

#import "NMImageCollectionViewCell.h"
#import "NMImageCollectionImageView.h"

@implementation NMImageCollectionViewCell {
    NMImageCollectionImageView *imageView;
    int32_t requestID;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        imageView = [NMImageCollectionImageView new];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [imageView addTarget:self action:@selector(imageViewValueChanged:) forControlEvents:UIControlEventValueChanged];
        [imageView addTarget:self action:@selector(imageViewTouchedUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:imageView];
        
        self.selectable = YES;
    }
    return self;
}

- (void)setModel:(NMImageCollectionViewCellModel *)model {
    imageView.number = model.number;
    CGRect rect = CGRectZero;
    rect.size = model.itemSize;
    imageView.frame = rect;
    
    if (model != _model || imageView.image == nil) {
        if (model.image) {
            imageView.image = model.image;
        } else {
            NMCancelRequest(requestID);
            requestID = NMRequestImage(model.asset, rect.size, ^(UIImage *image, NSDictionary *info) {
                imageView.image = image;
                model.info = info;
                model.image = image;
            });
        }
    }
    
    if (model.isSelected) {
        [imageView selectWithNumber:model.number animated:NO];
    } else {
        [imageView deselect];
    }
    
    imageView.selectable = model.selectable;
    self.selectable = model.selectable;
    
    _model = model;
}

- (void)imageViewValueChanged:(NMImageCollectionImageView *)sender {
    if (!self.selectable) {
        return;
    }
    if (sender.isSelected) {
        [self.delegate imageCollectionViewCell:self didSelectAtIndexPath:self.model.indexPath];
    } else {
        [self.delegate imageCollectionViewCell:self didDeselectAtIndexPath:self.model.indexPath];
    }
}

- (void)imageViewTouchedUpInside:(NMImageCollectionImageView *)sender {
    [self.delegate imageCollectionViewCell:self didTapWithoutSelectionAtIndexPath:self.model.indexPath];
}

- (void)selectWithNumber:(NSUInteger)number {
    [imageView selectWithNumber:number animated:NO];
}

- (void)deselect {
    [imageView deselect];
}

- (void)setSelectable:(BOOL)selectable {
    _selectable = selectable;
    imageView.selectable = selectable;
}

- (void)setImageHidden:(BOOL)imageHidden {
    _imageHidden = imageHidden;
    imageView.hidden = imageHidden;
}

@end
