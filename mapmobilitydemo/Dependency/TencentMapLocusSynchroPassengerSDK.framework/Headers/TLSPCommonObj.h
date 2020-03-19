//
//  TLSPCommonObj.h
//  TencentMapLocusSynchroPassengerSDK
//
//  Created by Yuchen Wang on 2020/3/11.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <TencentMapLocusSynchroSDK/TLSBCommonObj.h>


@interface TLSPFetchedData : NSObject

// 拉取的订单信息
@property (nonatomic, strong) TLSBOrder *order;

// 拉取的路线信息
@property (nonatomic, strong) TLSBRoute *route;

// 拉取的轨迹信息
@property (nonatomic, copy) NSArray <TLSDDriverPosition *> *positions;

@end

