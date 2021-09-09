//
//  TLSDCommonObj.h
//  TencentMapLocusSynchroDriverSDK
//
//  Created by mol on 2020/3/10.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import <TencentMapLocusSynchroSDK/TLSBCommonObj.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief 司乘同显司机配置信息
 */
@interface TLSDConfig: NSObject

/**
 * @brief  司乘同显的Key。注意：司机端与乘客端需要使用相同的key
 */
@property (nonatomic, copy) NSString *key;

/**
 * @brief  司乘同显的secretKey， 如果鉴权方式不是签名校验则无需填写。在https://lbs.qq.com/的控制台->应用管理->我的应用中查看
 */
@property (nonatomic, copy, nullable) NSString *secretKey;

/**
 * @brief 司机id
 */
@property (nonatomic, copy) NSString *driverID;

/**
 * @brief deviceID 设备标识，默认取自idfv。排查问题时需提供此identifier。注意，卸载重装时deviceID可能发生变化。
 * 如果希望使用自己业务上的设备标识来排查问题，可以将deviceID修改为自己业务上的设备标识。
 */
@property (nonatomic, copy) NSString *deviceID;

@end

/**
 * @brief 顺风车业务使用。路线规划时需要设置的途经点信息。顺风车业务使用
 */
@interface TLSDWayPointInfo : NSObject

/**
 * @brief 乘客订单号，必填
 */
@property (nonatomic, copy) NSString *pOrderID;

/**
 * @brief 途经点类型
 */
@property (nonatomic, assign) TLSBWayPointType wayPointType;

/**
 * @brief 途经点POI ID
 */
@property (nonatomic, copy, nullable) NSString *poiID;

/**
 * @brief 途经点位置坐标
 */
@property (nonatomic, assign) CLLocationCoordinate2D position;

/**
 * @brief 途经点展示图片，不设置就不展示
 */
@property (nonatomic, strong, nullable) UIImage *image;

@end

/**
 * @brief 司机拉取乘客的信息
 */
@interface TLSDFetchedData : NSObject

/**
 * @brief 服务端的订单信息
 */
@property (nonatomic, readonly) TLSBOrder *order;

/**
 * @brief 乘客的轨迹信息
 */
@property (nonatomic, readonly, nullable) NSArray<TLSBPosition *> *positions;

@end


typedef NS_ENUM(NSInteger, TLSBChooseRouteStatus) {
    TLSBChooseRouteStatusNone,              // 乘客没有进行选路
    TLSBChooseRouteStatusMatchedFail,       // 乘客行前选路，但是导航没有匹配出路线
    TLSBChooseRouteStatusMatchedSuccess,    // 乘客行前选路，导航匹配成功
};

/**
 * @brief 乘客选路指令信息
 */
@interface TLSBChooseRouteInfo : NSObject

//乘客选路指令信息状态。当为TLSBChooseRouteStatusMatchedSuccess时，selectedRouteID有值
@property (nonatomic, assign) TLSBChooseRouteStatus chooseRouteStatus;

/**
 * @brief 选中路线的路线id
 */
@property (nonatomic, copy, nullable) NSString *selectedRouteID;

@end

NS_ASSUME_NONNULL_END
