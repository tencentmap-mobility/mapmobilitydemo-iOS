//
//  TMMSearchManager.h
//  TencentMapMobilitySearchSDK
//
//  Created by mol on 2019/11/25.
//  Copyright © 2019 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class
TMMSearchSuggestionRequest,
TMMSearchSuggestionResponse,
TMMSearchReGeocodeRequest,
TMMSearchReGeocodeResponse,
TMMSearchDrivingRequest,
TMMSearchDrivingResponse,
TMMSearchWalkingRequest,
TMMSearchWalkingResponse;

/**
 * @brief 搜索管理类
 */
@interface TMMSearchManager : NSObject

/**
 * @brief 关键词搜索
 * @param request 请求参数
 * @param completion 请求结果
 * @return 请求Task
 */
+ (NSURLSessionTask * _Nullable)querySuggestionWithRequest:(TMMSearchSuggestionRequest *)request completion:(void(^)(TMMSearchSuggestionResponse * _Nullable response, NSError * _Nullable error))completion;

/**
 * @brief 逆地址解析
 * @param request 请求参数
 * @param completion 请求结果
 * @return 请求Task
 */
+ (NSURLSessionTask * _Nullable)queryReGeocodeWithRequest:(TMMSearchReGeocodeRequest *)request completion:(void(^)(TMMSearchReGeocodeResponse * _Nullable response, NSError * _Nullable error))completion;

/**
 * @brief 驾车路线规划
 * @param request 驾车请求参数
 * @param completion 驾车请求结果
 * @return 请求Task
 */
+ (NSURLSessionTask * _Nullable)queryDrivingWithRequest:(TMMSearchDrivingRequest *)request completion:(void(^)(TMMSearchDrivingResponse * _Nullable response, NSError * _Nullable error))completion;

/**
 * @brief 步行路线规划
 * @param request 步行请求参数
 * @param completion 步行请求结果
 * @return 请求Task
*/
+ (NSURLSessionTask * _Nullable)queryWalkingWithRequest:(TMMSearchWalkingRequest *)request completion:(void(^)(TMMSearchWalkingResponse * _Nullable response, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
