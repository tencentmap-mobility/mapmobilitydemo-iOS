//
//  KCChooseRouteViewController.h
//  TencentMapLocusSynchroDemo
//
//  Created by mol on 2021/8/31.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TLSPFetchedData, TLSBRoute;
@protocol KCChooseRouteDelegate;

@interface KCChooseRouteViewController : UIViewController

@property (nonatomic, weak, nullable) id<KCChooseRouteDelegate> delegate;

- (instancetype)initWithFetchedData:(TLSPFetchedData *)fetchedData;

@end

@protocol KCChooseRouteDelegate <NSObject>

// 取消选路
- (void)kcChooseRouteDidCancel:(KCChooseRouteViewController *)chooseRouteViewController;

// 确认选路
- (void)kcChooseRouteDidConfirm:(KCChooseRouteViewController *)chooseRouteViewController selectedRoute:(TLSBRoute *)selectedRoute;

@end

NS_ASSUME_NONNULL_END
