//
//  SearchKeywordHeaderView.h
//  mapmobilitydemo
//
//  Created by mol on 2019/12/4.
//  Copyright © 2019 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SearchKeywordHeaderViewDelegate;

@interface SearchKeywordHeaderView : UIView

@property (nonatomic, weak) id<SearchKeywordHeaderViewDelegate> delegate;
@property (nonatomic, copy) NSString *city;

- (void)textFieldBecomeFirstResponder;
- (void)textFieldResignFirstResponder;
@end


@protocol SearchKeywordHeaderViewDelegate <NSObject>

- (void)searchKeywordHeaderViewDidCancel:(SearchKeywordHeaderView *)headerView;
- (void)searchKeywordHeaderView:(SearchKeywordHeaderView *)headerView keywordDidChange:(NSString *)keyword;
- (void)searchKeywordHeaderView:(SearchKeywordHeaderView *)headerView cityDidChange:(NSString *)city;

@end

NS_ASSUME_NONNULL_END
