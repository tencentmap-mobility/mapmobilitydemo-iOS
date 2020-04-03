//
//  TMMSearchPOIModel.h
//  TencentMapMobilitySearchSDK
//
//  Created by mol on 2019/11/25.
//  Copyright © 2019 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TMMSearchPOIModel : NSObject

// 兴趣点id
@property (nonatomic, copy) NSString *poiID;
// 名称
@property (nonatomic, copy) NSString *title;
// 地址
@property (nonatomic, copy) NSString *address;
// 城市编号
@property (nonatomic, copy, nullable) NSString *adcode;
// 逆地址解析返回的坐标与此poi的距离
@property (nonatomic, assign) int distance;
// 兴趣点坐标
@property (nonatomic, assign) CLLocationCoordinate2D locationCoordinate;

// 两个poi可能存在父子关系， 子poi会有parentPOIID
@property (nonatomic, copy, nullable) NSString *parentPOIID;
// 父poi可能存在多个子poi
@property (nonatomic, strong, nullable) NSArray<TMMSearchPOIModel *> *subPOIModels;

@end

NS_ASSUME_NONNULL_END
