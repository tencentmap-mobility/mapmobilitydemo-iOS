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
@property (nonatomic, strong) TLSBRoute *route;

/**
 * @brief 拉取的轨迹信息
 */
@property (nonatomic, copy) NSArray <TLSDDriverPosition *> *positions;

@end

