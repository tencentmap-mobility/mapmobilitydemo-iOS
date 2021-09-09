//
//  KCPassengerModule.h
//  TencentMapLocusSynchroDemo
//
//  Created by mol on 2021/9/2.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TencentMapLocusSynchroSDK/TencentMapLocusSynchroSDK.h>

NS_ASSUME_NONNULL_BEGIN

@class QMapView, TLSPSearchDrivingRequest, KCMyOrder, TLSPFetchedData, TLSPassengerManager;
@protocol QOverlay;

@interface KCPassengerModule : NSObject

@property (nonatomic, weak) QMapView *mapView;

// 接送驾过程司机的信息
@property (nonatomic, readonly, nullable) TLSPFetchedData *curFetchedData;

// 司乘同显乘客端管理对象
@property (nonatomic, readonly) TLSPassengerManager *passengerManager;

// 订单状态
@property (nonatomic, assign) TLSBOrderStatus orderStatus;

// 自动视野还是乘客拖动了视野
@property (nonatomic, assign) BOOL autoVisibleMapRect;

- (instancetype)initWithOrder:(KCMyOrder *)order;
- (instancetype)init NS_UNAVAILABLE;

- (void)start;
- (void)stop;

// 乘客需要调用该方法上报乘客轨迹点
- (void)uploadPosition:(TLSBPosition *)position;

// 调整视野
- (void)adjestVisiableMapRectIfNeeded;

// 路径规划并且展示在地图上
- (void)calcRoutesAndShowWithRequest:(TLSPSearchDrivingRequest *)drivingRequest;

// 上报选中的送驾路线
- (void)uploadSelctedRoute;

// 是否是我的overlay
- (BOOL)isMyOverlay:(id<QOverlay>)overlay;
// 处理overlay点击事件
- (void)handleDidTapOverlay:(id<QOverlay>)overlay;

@end

NS_ASSUME_NONNULL_END
