//
//  KCDriverModule.h
//  TencentMapLocusSynchroDemo
//
//  Created by mol on 2021/9/2.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TencentMapLocusSynchroSDK/TencentMapLocusSynchroSDK.h>


NS_ASSUME_NONNULL_BEGIN

@class TNKCarNaviView, TNKSearchNaviPoi, TNKCarRouteSearchOption, KCMyOrder;
@protocol QOverlay;

@interface KCDriverModule : NSObject

@property (nonatomic, weak) TNKCarNaviView *carNaviView;
// 订单状态
@property (nonatomic, assign) TLSBOrderStatus orderStatus;

- (instancetype)initWithOrder:(KCMyOrder *)order;
- (instancetype)init NS_UNAVAILABLE;

// 路径规划
- (void)searchRouteAndStartNaviWithStart:(TNKSearchNaviPoi *)startPOI
                                     end:(TNKSearchNaviPoi *)endPOI
                                  option:(TNKCarRouteSearchOption * _Nullable)option;

// 是否是我的overlay
- (BOOL)isMyOverlay:(id<QOverlay>)overlay;
// 处理overlay点击事件
- (void)handleDidTapOverlay:(id<QOverlay>)overlay;

@end

NS_ASSUME_NONNULL_END
