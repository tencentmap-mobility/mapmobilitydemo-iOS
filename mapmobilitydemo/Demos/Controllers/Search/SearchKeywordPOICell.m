//
//  SewarchKeywordPOICell.m
//  mapmobilitydemo
//
//  Created by mol on 2019/12/4.
//  Copyright © 2019 tencent. All rights reserved.
//

#import "SearchKeywordPOICell.h"

@interface SearchKeywordPOICell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;
@property (nonatomic, strong) NSMutableArray<UIButton *> *subPOIButtons;
@property (nonatomic, strong) NSMutableArray<UIButton *> *showSubPOIButtons;

@end

@implementation SearchKeywordPOICell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self setup];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self layoutElements];
}

- (void)setup {
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:15];
    self.titleLabel.textColor = [UIColor blackColor];
    
    self.subTitleLabel = [[UILabel alloc] init];
    self.subTitleLabel.font = [UIFont systemFontOfSize:13];
    self.subTitleLabel.textColor = [UIColor lightGrayColor];
    
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.subTitleLabel];
    
    self.subPOIButtons = [NSMutableArray array];
    self.showSubPOIButtons = [NSMutableArray array];
}

#pragma mark - setter
-(void)setKeywordPOIModel:(SearchKeywordPOIModel *)keywordPOIModel {
    _keywordPOIModel = keywordPOIModel;
    
    self.titleLabel.text = keywordPOIModel.poiModel.title;
    self.subTitleLabel.text = keywordPOIModel.poiModel.address;
    

    for (UIButton *button in self.showSubPOIButtons) {
        [button removeFromSuperview];
    }
    [self.showSubPOIButtons removeAllObjects];
    
    CGFloat subPOIButtonWidth = (self.contentView.bounds.size.width - keywordPOIModel.edgeInsets.left - keywordPOIModel.edgeInsets.right - (keywordPOIModel.subPOIButtonCol - 1) * keywordPOIModel.subPOIButtonPadding) / keywordPOIModel.subPOIButtonCol;
    
    for (int i = 0; i < keywordPOIModel.poiModel.subPOIModels.count; i++) {
        
        UIButton *button;
        
        TMMSearchPOIModel *subPOIModel = keywordPOIModel.poiModel.subPOIModels[i];
        if (i >= self.subPOIButtons.count) {
            button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, subPOIButtonWidth, keywordPOIModel.subPOIButtonHeight)];
            [button addTarget:self action:@selector(subPOIDicClick:) forControlEvents:UIControlEventTouchUpInside];
            button.layer.cornerRadius = 4;
            button.layer.borderColor = [UIColor lightGrayColor].CGColor;
            button.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:13];
            
            [self.subPOIButtons addObject:button];
        }else {
            button = self.subPOIButtons[i];
        }
        
        [self.contentView addSubview:button];
        [self.showSubPOIButtons addObject:button];
        button.tag = i;

        [button setTitle:subPOIModel.title forState:UIControlStateNormal];
    }
    
    [self layoutElements];
}

#pragma mark - private
- (void)layoutElements {
    
    [self.titleLabel sizeToFit];
    [self.subTitleLabel sizeToFit];
    
    UIEdgeInsets edgeInset = self.keywordPOIModel.edgeInsets;
    
    self.titleLabel.frame = CGRectMake(edgeInset.left, edgeInset.top, MIN(self.titleLabel.bounds.size.width, self.contentView.bounds.size.width - edgeInset.left - edgeInset.right), self.titleLabel.bounds.size.height);
    
    self.subTitleLabel.frame = CGRectMake(edgeInset.left, CGRectGetMaxY(self.titleLabel.frame) + 5, MIN(self.subTitleLabel.bounds.size.width, self.contentView.bounds.size.width - edgeInset.left - edgeInset.right), self.subTitleLabel.bounds.size.height);
    
    for (int i = 0; i < self.showSubPOIButtons.count; i++) {
        UIButton *subPOIButton = self.showSubPOIButtons[i];
        NSInteger row =  i / self.keywordPOIModel.subPOIButtonCol;
        NSInteger col = i % self.keywordPOIModel.subPOIButtonCol;
        subPOIButton.frame = CGRectMake(edgeInset.left + col * (subPOIButton.bounds.size.width + self.keywordPOIModel.subPOIButtonPadding), edgeInset.top + self.keywordPOIModel.titleHeight + row * (subPOIButton.bounds.size.height + self.keywordPOIModel.subPOIButtonPadding), subPOIButton.bounds.size.width, subPOIButton.bounds.size.height);
    }
}

- (void)subPOIDicClick:(UIButton *)button {
    
    if (self.poiModelClickCallback) {
        self.poiModelClickCallback(self.keywordPOIModel.poiModel, self.keywordPOIModel.poiModel.subPOIModels[button.tag]);
    }
}
@end
