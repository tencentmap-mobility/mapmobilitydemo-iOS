//
//  OrderMenuViewController.h
//  TencentMapLocusSynchroDemo
//
//  Created by mol on 2021/8/13.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TencentMapLocusSynchroSDK/TLSBCommonObj.h>

NS_ASSUME_NONNULL_BEGIN

@protocol OrderMenuViewDelegate;

@interface OrderMenuViewController : UIViewController

@property (nonatomic, assign) TLSBOrderStatus orderStatus;

@property (nonatomic, weak) id<OrderMenuViewDelegate> delegate;

// 展示菜单
- (void)showMenu;

@end

@protocol OrderMenuViewDelegate <NSObject>

@required

// 切换至接驾
- (void)orderMenuViewControllerPickup:(OrderMenuViewController *)orderMenuViewController;

// 切换至送驾
- (void)orderMenuViewControllerTrip:(OrderMenuViewController *)orderMenuViewController;

// 开启导航
- (void)orderMenuViewControllerStartNavi:(OrderMenuViewController *)orderMenuViewController;

// 开启模拟导航
- (void)orderMenuViewControllerStartSimulateNavi:(OrderMenuViewController *)orderMenuViewController;

@end

NS_ASSUME_NONNULL_END
