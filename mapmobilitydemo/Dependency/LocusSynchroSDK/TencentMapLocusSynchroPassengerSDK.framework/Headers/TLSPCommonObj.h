//
//  TLSPCommonObj.h
//  TencentMapLocusSynchroPassengerSDK
//
//  Created by ikaros on 2020/3/11.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <TencentMapLocusSynchroSDK/TLSBCommonObj.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief 乘客拉取司机的信息
 */
@interface TLSPFetchedData : NSObject

/**
 * @brief 是否已经到达
 */
@property (nonatomic, assign) BOOL hasArrived;

/**
 * @brief 拉取的订单信息
 */
@property (nonatomic, strong) TLSBOrder *order;

/**
 * @brief 拉取的路线信息
 */
@property (nonatomic, strong, nullable) TLSBRoute *route;

/**
 * @brief 接力单路线信息. since 2.2.0
 */
@property (nonatomic, strong, nullable) TLSBRoute *relayRoute;

/**
 * @brief 拉取的轨迹信息
 */
@property (nonatomic, copy) NSArray <TLSDDriverPosition *> *positions;

// 备选路线数据. since 2.2.0
@property (nonatomic, copy, nullable) NSArray<TLSBRoute *> *backupRoutes;

@end


/**
 * @brief POI类。算路起终点. since 2.2.0
 */
@interface TLSBNaviPOI : NSObject

/**
 * @brief  POI ID
 */
@property (nonatomic, copy, nullable) NSString *poiID;

/**
 * @brief 坐标（必传）
 */
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@end

/**
 * @brief 驾车请求. since 2.2.0
 */
@interface TLSPSearchDrivingRequest : NSObject

/**
 * @brief 驾车规划的起点
 */
@property (nonatomic, strong) TLSBNaviPOI *start;

/**
 * @brief 驾车规划的终点
 */
@property (nonatomic, strong) TLSBNaviPOI *destination;

/**
 * @brief 驾车规划的途径点.最多支持16个
 */
@property (nonatomic, copy, nullable) NSArray<TLSBNaviPOI *> *waypoints;

@end


/**
 * @brief 驾车路线response类. since 2.2.0
 */
@interface TLSPSearchDrivingResponse : NSObject

/**
 * @brief 请求id，有问题可提供requestID方便排查
 */
@property (nonatomic, readonly) NSString *requestID;

/**
 * @brief status为0时请求成功
 */
@property (nonatomic, readonly) NSInteger status;

/**
 * @brief 导航路线信息
 */
@property (nonatomic, readonly, nullable) NSArray<TLSBRoute *> *routes;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end


NS_ASSUME_NONNULL_END
