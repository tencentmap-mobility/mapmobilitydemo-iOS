//
//  TMMSearchRequest.h
//  TencentMapMobilitySearchSDK
//
//  Created by mol on 2019/11/25.
//  Copyright © 2019 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TMMSSuggestionPolicy) {
    TMMSSuggestionPolicySource = 1,         // 起点
    TMMSSuggestionPolicyDestination = 2,    // 终点
};

@interface TMMSearchSuggestionRequest : NSObject

// 关键词（必传）
@property (nonatomic, copy) NSString *keyword;
// 城市名. 例，北京（必传）
@property (nonatomic, copy) NSString *region;
// 检索策略（必传）
@property (nonatomic, assign) TMMSSuggestionPolicy policy;

// 当前定位点. policy为TMMSSuggestionPolicySource时必传，有助于优化检索结果
@property (nonatomic, assign) CLLocationCoordinate2D locationCoordinate;
@end

NS_ASSUME_NONNULL_END
