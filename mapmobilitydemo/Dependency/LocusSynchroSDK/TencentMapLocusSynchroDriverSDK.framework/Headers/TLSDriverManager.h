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


@protocol TLSDriverManagerDelegate <NSObject>

@optional

// 上报定位成功回调
- (void)tlsDriverManagerDidUploadLocationSuccess:(TLSDriverManager *)driverManager;
// 上报定位失败回调
- (void)tlsDriverManagerDidUploadLocationFail:(TLSDriverManager *)driverManager error:(NSError *)error;

// 上报路线成功回调
- (void)tlsDriverManagerDidUploadRouteSuccess:(TLSDriverManager *)driverManager;
// 上报路线失败回调
- (void)tlsDriverManagerDidUploadRouteFail:(TLSDriverManager *)driverManager error:(NSError *)error;

// 拉去乘客信息回调
- (void)tlsDriverManager:(TLSDriverManager *)driverManager didFetchData:(TLSDFetchedData *)fetchedData;

// 移除途经点之后需要重新路线规划并启动导航
- (void)tlsDriverManager:(TLSDriverManager *)driverManager didRemoveWayPointInfo:(TLSDWayPointInfo *)removedWayPointInfo;
//
@end


// 司乘同显-司机管理类
@interface TLSDriverManager : NSObject

@property (nonatomic, weak) id<TLSDriverManagerDelegate> delegate;

// 订单id
@property (nonatomic, copy, nullable) NSString *orderID;

// 订单类型
@property (nonatomic, assign) TLSBOrderType orderType;

// 订单状态。如果是顺风车订单，开始服务时请切换至TLSDOrderStatusTrip状态
@property (nonatomic, assign) TLSBOrderStatus orderStatus;

// 司机状态
@property (nonatomic, assign) TLSDDriverStatus driverStatus;

// 当前所在城市的编码
@property (nonatomic, copy, nullable) NSString *cityCode;

// 司乘同显服务是否开启
@property (nonatomic, readonly) BOOL isRunning;

// 同步乘客数据的时间间隔. 默认时间间隔为5秒.
@property (nonatomic, assign) NSTimeInterval syncTimeInterval;

// 是否开启拉去乘客定位信息，默认为NO
@property (nonatomic, assign) BOOL fetchPassengerPositionsEnabled;

// 初始化司机管理类
- (instancetype)initWithConfig:(TLSDConfig *)config;

/// 上传路线信息。在初始路径规划、偏航重算、切换路线时，要调用该方法
/// 注意：当给driverManager设置了TLSDriverManager+Navigation.h中的carNaviManager之后，开发者无需主动调用该方法。
/// @param route 路线信息
- (void)uploadRoute:(TLSBRoute *)route;

/// 司机在听单、接送驾过程中，需要调用该方法上报司机轨迹点。
/// 注意：当给driverManager设置了TLSDriverManager+Navigation.h中的carNaviManager之后，开发者在导航过程中无需主动调用该方法。
/// @param position 司机的定位信息
- (void)uploadPosition:(TLSDDriverPosition *)position;

// 立即上报当前数据
- (void)uploadPositionsImmediately;

// 清除订单信息。当订单结束时调用该方法，使得orderID = nil; orderStatus = TLSDOrderStatusNone;
- (void)resetOrderInfo;

// 开启服务
- (void)start;

// 结束服务
- (void)stop;

@end

NS_ASSUME_NONNULL_END
