//
//  SewarchKeywordPOIModel.h
//  mapmobilitydemo
//
//  Created by mol on 2019/12/4.
//  Copyright © 2019 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TencentMapMobilitySearchSDK/TMMSearch.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SearchKeywordPOIModel : NSObject

@property (nonatomic, readonly) TMMSearchPOIModel *poiModel;

// cell高度
@property (nonatomic, assign, readonly) CGFloat cellHeight;

@property (nonatomic, assign, readonly) UIEdgeInsets edgeInsets;
//
@property (nonatomic, assign, readonly) CGFloat titleHeight;
// 子poi每行个数
@property (nonatomic, assign, readonly) NSUInteger subPOIButtonCol;
// 子poi按钮高度
@property (nonatomic, assign, readonly) CGFloat subPOIButtonHeight;
// 子poi间距
@property (nonatomic, assign, readonly) CGFloat subPOIButtonPadding;

- (instancetype)initWithPOIModel:(TMMSearchPOIModel *)poiModel;
+ (NSArray<SearchKeywordPOIModel *> *)modelWithArray:(NSArray<TMMSearchPOIModel *> *)poiModels;

@end

NS_ASSUME_NONNULL_END
