//
//  SearchKeywordHeaderView.m
//  mapmobilitydemo
//
//  Created by mol on 2019/12/4.
//  Copyright © 2019 tencent. All rights reserved.
//

#import "SearchKeywordHeaderView.h"

@interface SearchKeywordHeaderView ()<UITextFieldDelegate>

@property (nonatomic, strong) UILabel *cityLabel;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *cancelButton;

@end

@implementation SearchKeywordHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setup];
    }
    
    return self;
}

- (void)setup {
    
    self.backgroundColor = [UIColor whiteColor];
    self.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 2);
    self.layer.shadowRadius = 2.0;
    self.layer.shadowOpacity = 0.25;
    
    _cancelButton = [[UIButton alloc] init];
    [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    _cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_cancelButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    [_cancelButton sizeToFit];
    [self addSubview:_cancelButton];
    
    _cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 24)];
    _cityLabel.font = [UIFont systemFontOfSize:16];
    _cityLabel.backgroundColor = [UIColor clearColor];
    _cityLabel.textColor = [UIColor lightGrayColor];
    _cityLabel.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:_cityLabel];
    
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 25)];
    _textField.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    [_textField addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
    _textField.delegate = self;
    [self addSubview:_textField];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _cancelButton.frame = CGRectMake(self.bounds.size.width - _cancelButton.bounds.size.width - 10, self.bounds.size.height - _cancelButton.bounds.size.height / 2 - 30, _cancelButton.bounds.size.width, _cancelButton.bounds.size.height);
    
    _cityLabel.frame = CGRectMake(10, CGRectGetMidY(_cancelButton.frame) - _cityLabel.bounds.size.height / 2.0, _cityLabel.bounds.size.width, _cityLabel.bounds.size.height);
    
    _textField.frame = CGRectMake(CGRectGetMaxX(_cityLabel.frame) + 10, CGRectGetMidY(_cancelButton.frame) - _textField.bounds.size.height / 2.0, _cancelButton.frame.origin.x - CGRectGetMaxX(_cityLabel.frame) - 30, _textField.bounds.size.height);
}

#pragma mark - public
- (void)textFieldBecomeFirstResponder {
    [self.textField becomeFirstResponder];
    
}

- (void)textFieldResignFirstResponder {
    [self.textField resignFirstResponder];
}

- (void)setCity:(NSString *)city {
    _city = city;
    
    self.cityLabel.text = city;
}

#pragma mark - action
- (void)cancel:(UIButton *)button {
    
    if ([self.delegate respondsToSelector:@selector(searchKeywordHeaderViewDidCancel:)]) {
        [self.delegate searchKeywordHeaderViewDidCancel:self];
    }
}

- (void)textFieldDidChange:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(searchKeywordHeaderView:keywordDidChange:)]) {
        [self.delegate searchKeywordHeaderView:self keywordDidChange:textField.text];
    }
}

@end
