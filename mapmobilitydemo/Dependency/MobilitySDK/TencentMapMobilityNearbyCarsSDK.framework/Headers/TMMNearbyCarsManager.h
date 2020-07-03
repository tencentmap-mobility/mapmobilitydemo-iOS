//
//  TMMNearbyCarsManager.h
//  TencentMapMobilityNearbyCarsSDK
//
//  Created by mol on 2019/11/25.
//  Copyright © 2019 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QMapKit/QMapView.h>

NS_ASSUME_NONNULL_BEGIN

@class TMMNearbyCarConfig,
TMMNearbyCarRequest,
TMMNearbyCarResponse,
TMMNearbyCarsManager;

@protocol TMMNearbyCarsManagerDelegate <NSObject>

@optional

/**
 * @brief 发起周边车辆失败的回调
 * @param manager 周边车辆管理类
 */
- (void)TMMNearbyCarsManager:(TMMNearbyCarsManager *)manager requestFailed:(NSError *)error;

@end

/**
 * @brief 周边车辆管理类
 */
@interface TMMNearbyCarsManager : NSObject

/**
 * @brief 周边车辆开关，默认开。如果关闭则不在进行请求和展示
 */
@property (nonatomic, assign, getter=isNearbyCarsEnabled)  BOOL nearbyCarsEnabled;

/**
 * @brief 周边车辆展示配置
 */
@property (nonatomic, strong) TMMNearbyCarConfig *nearbyCarConfig;

/**
 * @brief 周边车辆代理
 */
@property (nonatomic, weak, nullable) id<TMMNearbyCarsManagerDelegate> delegate;

/**
 * @brief 周边车辆初始化方法
 * @param mapView 地图视图
 * @param delegate 代理
 */
- (instancetype)initWithMapView:(QMapView *)mapView delagate:(id<TMMNearbyCarsManagerDelegate> _Nullable)delegate;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

/**
 * @brief 请求周边车辆
 */
- (void)getNearbyCars;

/**
 * @brief 删除周边所有车辆
 */
- (void)removeAllNearbyCars;

/**
 * @brief 查询周边车辆
 * @param request 请求
 * @param callback 结果回调
 * @return NSURLSessionDataTask 对象
 */
+ (NSURLSessionTask * _Nullable)queryNearbyCarsWith:(TMMNearbyCarRequest *)request callback:(void(^)(TMMNearbyCarResponse *response, NSError* error))callback;

@end

NS_ASSUME_NONNULL_END
