//
//  NMImageTableViewCell.m
//  AlbumCollectionDemo
//
//  Created by 孙国林 on 2017/7/18.
//  Copyright © 2017年 孙国林. All rights reserved.
//

#import "NMImageTableViewCell.h"
#import <Photos/Photos.h>
#import "NMImageConfig.h"

@implementation NMImageTableViewCell {
    UIImageView *headView;
    UILabel *titleLabel, *countLabel;
    CGFloat scale;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        headView = [UIImageView new];
        headView.contentMode = UIViewContentModeScaleAspectFill;
        headView.clipsToBounds = YES;
        [self.contentView addSubview:headView];
        
        titleLabel = [UILabel new];
        [self.contentView addSubview:titleLabel];
        
        countLabel = [UILabel new];
        countLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:countLabel];
        
        scale = 1.0;
        
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

- (void)setModel:(NMImageTableViewCellModel *)model {
    _model = model;
    if (model.asset) {
        CGSize size = CGSizeMake(NMImageTableViewCellHeight * scale, NMImageTableViewCellHeight);
        NMRequestImage(model.asset, size, ^(UIImage *image, NSDictionary *info) {
            headView.image = image;
        });
    } else {
        headView.image = [UIImage imageNamed:NMPlaceHolder];
    }
    
    titleLabel.text = model.assetCollection.localizedTitle;
    [titleLabel sizeToFit];
    
    countLabel.text = [NSString stringWithFormat:@"（%zd）", self.model.imageCollectionViewCellModels.count];
    [countLabel sizeToFit];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat hh = self.frame.size.height;
    headView.frame = CGRectMake(0, 0, NMImageTableViewCellHeight * scale, NMImageTableViewCellHeight);
    
    CGFloat ww = titleLabel.frame.size.width;
    CGFloat xx = CGRectGetMaxX(headView.frame) + 10;
    CGFloat tail = 40;
    CGFloat cww = countLabel.frame.size.width;
    
    CGFloat max = [UIScreen mainScreen].bounds.size.width - xx - tail - cww;
    if (ww > max) {
        ww = max;
    }
    CGFloat hh2 = titleLabel.frame.size.height;
    CGFloat yy = (hh - hh2) * 0.5;
    titleLabel.frame = CGRectMake(xx, yy, ww, hh2);
    
    xx = CGRectGetMaxX(titleLabel.frame);
    ww = countLabel.frame.size.width;
    hh2 = countLabel.frame.size.height;
    yy = (hh - hh2) * 0.5;
    countLabel.frame = CGRectMake(xx, yy, ww, hh2);
}

@end
