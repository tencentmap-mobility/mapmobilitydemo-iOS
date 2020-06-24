//
//  TMMNearbyBoardingPlacesManager.h
//  TencentMapMobilityBoardingPlacesSDK
//
//  Created by mol on 2019/11/25.
//  Copyright © 2019 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMMNearbyBoardingPlacesConfig.h"
#import "TMMNearbyBoardingPlacesRequest.h"
#import "TMMNearbyBoardingPlacesResponse.h"
#import "TMMFenceModel.h"
#import <QMapKit/QMapView.h>

NS_ASSUME_NONNULL_BEGIN

@class TMMNearbyBoardingPlacesManager;

@protocol TMMNearbyBoardingPlacesManagerDelegate <NSObject>

@optional

/**
 * @brief 大头针吸附到上车点的回调
 * @param manager 推荐上车点管理类
 * @param absorbedBoardingPlaceModel 吸附的推荐上车点
 */
- (void)TMMNearbyBoardingPlaceManager:(TMMNearbyBoardingPlacesManager *)manager didAbsorbedToBoardingPlaceModel:(TMMNearbyBoardingPlaceModel *)absorbedBoardingPlaceModel;


/**
 * @brief 大头针未吸附时，逆地址请求结果回调
 * @param manager 推荐上车点管理类
 * @param locationName 逆地址请求返回的地点名
 */
- (void)TMMNearbyBoardingPlaceManager:(TMMNearbyBoardingPlacesManager *)manager didRegeocodeReceivedLocationName:(NSString *)locationName;


/**
 * @brief 推荐上车点请求成功的回调
 * @param manager 推荐上车点管理类
 * @param nearbyBoardingPlaces 推荐上车点列表
 */
- (void)TMMNearbyBoardingPlaceManager:(TMMNearbyBoardingPlacesManager *)manager didReceivedNearbyBoardingPlaces:(NSArray<TMMNearbyBoardingPlaceModel *> *)nearbyBoardingPlaces;

/**
 * @brief 推荐上车点请求失败的回调
 * @param manager 推荐上车点管理类
 * @param error 失败信息
 */
- (void)TMMNearbyBoardingPlaceManager:(TMMNearbyBoardingPlacesManager *)manager didFailReceivedNearbyBoardingPlacesWithError:(NSError *)error;


/**
 * @brief 命中围栏时的回调
 * @param manager 推荐上车点管理类
 * @param fenceModel 围栏数据
 */
- (void)TMMNearbyBoardingPlaceManager:(TMMNearbyBoardingPlacesManager *)manager didReceivedFence:(TMMFenceModel *)fenceModel;

/**
 * @brief 从围栏内移出的回调
 * @param manager 推荐上车点管理类
 */
- (void)TMMNearbyBoardingPlaceManagerDidMoveOutOfFence:(TMMNearbyBoardingPlacesManager *)manager;

@end

/**
 * @brief 推荐上车点管理类
 */
@interface TMMNearbyBoardingPlacesManager : NSObject

/**
 * @brief 是否展示推荐上车点，默认为YES
 */
@property (nonatomic, assign, getter=isNearbyBoardingPlacesEnabled) BOOL nearbyBoardingPlacesEnabled;

/**
 * @brief 推荐上车点配置
 */
@property (nonatomic, strong) TMMNearbyBoardingPlacesConfig *nearbyBoardingPlacesConfig;

/**
 * @brief 推荐上车点代理
 */
@property (nonatomic, weak, nullable) id<TMMNearbyBoardingPlacesManagerDelegate> delegate;

/**
 * @brief 获取推荐上车点
 */
- (void)getNearbyBoardingPlaces;

/**
 * @brief 删除所有推荐上车点
 */
- (void)removeAllNearbyBoardingPlaces;

/**
 * @brief 推荐上车点初始化方法
 * @param mapView 地图
 * @param delegate 推荐上车点代理
 */
- (instancetype)initWithMapView:(QMapView *)mapView delagate:(id <TMMNearbyBoardingPlacesManagerDelegate> _Nullable)delegate;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

/**
 * @brief 当前一级围栏model, nil为当前没有命中围栏
 */
@property (nonatomic, nullable, readonly) TMMFenceModel *curFenceModel;

/**
 * @brief 选择二级围栏
 */
- (void)chooseSubFence:(TMMSubFenceModel *)subFencModel;

/**
 * @brief 查询周围上车点接口，纯数据接口
 * @param request 请求
 * @param callback 结果回调
 * @return NSURLSessionTask task对象
 */
+ (NSURLSessionTask * _Nullable)queryNearbyBoardingPlacesWith:(TMMNearbyBoardingPlacesRequest *)request callback:(void(^)(TMMNearbyBoardingPlacesResponse * _Nullable response, NSError * _Nullable error))callback;

@end

NS_ASSUME_NONNULL_END
