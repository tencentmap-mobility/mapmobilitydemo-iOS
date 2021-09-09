//
//  TLSDriverManager.h
//  TencentMapLocusSynchroDriverSDK
//
//  Created by mol on 2020/3/10.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TencentMapLocusSynchroDriverSDK/TLSDCommonObj.h>
#import <TNKNavigationKit/TNKNavigationKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TLSDConfig, TLSDriverManager, TLSDWayPointInfo;

/**
 * @brief 司乘同显-司机管理类代理
 */
@protocol TLSDriverManagerDelegate <NSObject>

@optional

/**
 * @brief 上报定位成功回调
 * @param driverManager 司机manager
 */
- (void)tlsDriverManagerDidUploadLocationSuccess:(TLSDriverManager *)driverManager;

/**
 * @brief 上报定位失败回调
 * @param driverManager 司机manager
 * @param error 错误信息
 */
- (void)tlsDriverManagerDidUploadLocationFail:(TLSDriverManager *)driverManager error:(NSError *)error;

/**
 * @brief 上报路线成功回调
 * @param driverManager 司机manager
 */
- (void)tlsDriverManagerDidUploadRouteSuccess:(TLSDriverManager *)driverManager;

/**
 * @brief 上报路线失败回调
 * @param driverManager 司机manager
 * @param error 错误信息
 */
- (void)tlsDriverManagerDidUploadRouteFail:(TLSDriverManager *)driverManager error:(NSError *)error;

/**
 * @brief 拉取乘客信息回调
 * @param driverManager 司机manager
 * @param fetchedData 拉取乘客的信息
 */
- (void)tlsDriverManager:(TLSDriverManager *)driverManager didFetchData:(TLSDFetchedData * _Nullable)fetchedData;

/**
 * @brief 移除途经点之后需要重新路线规划并启动导航
 * @param driverManager 司机manager
 * @param removedWayPointInfo 移除的途径点信息
 */
- (void)tlsDriverManager:(TLSDriverManager *)driverManager didRemoveWayPointInfo:(TLSDWayPointInfo *)removedWayPointInfo;


/// 乘客选路成功回调. since 2.2.0. 如果当前正在导航，则路线被自动切换。如果当前还没开启导航，需要开发者重新绘制路线然后使用routePlan中的routeID去开启导航
/// @param driverManager 司机manager
/// @param routePlan 路线数据
/// @param trafficStatus 路况数据
- (void)tlsDriverManager:(TLSDriverManager *)driverManager
 didPassengerChangeRoute:(TNKCarRouteSearchRoutePlan *)routePlan
      routeTrafficStatus:(TNKRouteTrafficStatus *)trafficStatus;

/**
 * @brief 乘客选路失败回调. since 2.2.0
 * @param driverManager 司机manager
 * @param error 错误信息
 */
- (void)tlsDriverManagerDidPassengerChangeRouteFail:(TLSDriverManager *)driverManager error:(NSError *)error;

@end

/**
 * @brief 司乘同显-司机管理类
 */
@interface TLSDriverManager : NSObject

/**
 * @brief 司乘同显-司机管理类代理
 */
@property (nonatomic, weak) id<TLSDriverManagerDelegate> delegate;

/**
 * @brief 订单id
 */
@property (nonatomic, copy, nullable) NSString *orderID;

/**
 * @brief 订单类型
 */
@property (nonatomic, assign) TLSBOrderType orderType;

/**
 * @brief 订单状态。如果是顺风车订单，开始服务时请切换至TLSDOrderStatusTrip状态
 */
@property (nonatomic, assign) TLSBOrderStatus orderStatus;

/**
 * @brief 司机状态
 */
@property (nonatomic, assign) TLSDDriverStatus driverStatus;

/**
 * @brief 当前所在城市的编码
 */
@property (nonatomic, copy, nullable) NSString *cityCode;

/**
 * @brief 司乘同显服务是否开启
 */
@property (nonatomic, readonly) BOOL isRunning;

/**
 * @brief 同步乘客数据的时间间隔. 默认时间间隔为5秒.
 */
@property (nonatomic, assign) NSTimeInterval syncTimeInterval;

/**
 * @brief 是否开启拉去乘客定位信息，默认为NO
 */
@property (nonatomic, assign) BOOL fetchPassengerPositionsEnabled;

/**
 * @brief 初始化司机管理类
 */
- (instancetype)initWithConfig:(TLSDConfig *)config;

/**
 * @brief 上传路线信息。在初始路径规划、偏航重算、切换路线时，要调用该方法
 * 注意：当给driverManager设置了TLSDriverManager+Navigation.h中的carNaviManager之后，开发者无需主动调用该方法。
 * @param route 路线信息
 */
- (void)uploadRoute:(TLSBRoute *)route;

/**
 * @brief 上传路线信息。在初始路径规划、偏航重算、切换路线时，要调用该方法
 * 注意：当给driverManager设置了TLSDriverManager+Navigation.h中的carNaviManager之后，开发者无需主动调用该方法。
 * @param route 路线信息
 * @param backupRoutes 备选路线列表
 */
- (void)uploadRoute:(TLSBRoute *)route backupRoutes:(NSArray<TLSBRoute *> * _Nullable)backupRoutes;

/**
 * @brief 司机在听单、接送驾过程中，需要调用该方法上报司机轨迹点。
 * 注意：当给driverManager设置了TLSDriverManager+Navigation.h中的carNaviManager之后，开发者在导航过程中无需主动调用该方法。
 * @param position 司机的定位信息
 */
- (void)uploadPosition:(TLSDDriverPosition *)position;

/**
 * @brief 立即上报当前数据
 */
- (void)uploadPositionsImmediately;

/**
 * @brief 清除订单信息。当订单结束时调用该方法，使得orderID = nil; orderStatus = TLSDOrderStatusNone;
 */
- (void)resetOrderInfo;

/**
 * @brief 开启服务
 */
- (void)start;

/**
 * @brief 结束服务
 */
- (void)stop;

@end

NS_ASSUME_NONNULL_END
