//
//  TMMSearchResponse.h
//  TencentMapMobilitySearchSDK
//
//  Created by mol on 2019/11/25.
//  Copyright © 2019 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMMSearchPOIModel.h"

NS_ASSUME_NONNULL_BEGIN
/**
 * @brief 检索response类
 */
@interface TMMSearchSuggestionResponse : NSObject

/**
 * @brief poi模型
 */
@property (nonatomic, strong) NSArray<TMMSearchPOIModel *> *poiModels;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end

NS_ASSUME_NONNULL_END
