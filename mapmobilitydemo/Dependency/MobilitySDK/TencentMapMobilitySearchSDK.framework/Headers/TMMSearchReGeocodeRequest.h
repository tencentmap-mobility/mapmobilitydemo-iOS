//
//  TMMSearchReGeocodeRequest.h
//  TencentMapMobilitySearchSDK
//
//  Created by mol on 2019/11/26.
//  Copyright © 2019 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TMMSearchReGeocodeRequest : NSObject

// 定位点（必传）
@property (nonatomic, assign) CLLocationCoordinate2D locationCoordinate;

@end

NS_ASSUME_NONNULL_END
