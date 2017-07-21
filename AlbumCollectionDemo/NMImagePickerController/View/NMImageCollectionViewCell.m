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
    if (_model == model) {
        return;
    }
    _model = model;
    CGRect rect = CGRectZero;
    rect.size = model.itemSize;
    imageView.frame = rect;
    NMRequestImage(model.asset, rect.size, ^(UIImage *image, NSDictionary *info) {
        imageView.image = image;
        model.info = info;
    });
    
    if (model.isSelected) {
        [imageView selectWithNumber:model.number animated:NO];
    } else {
        [imageView deselect];
    }
    
    imageView.selectable = model.selectable;
    self.selectable = model.selectable;
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

@end
