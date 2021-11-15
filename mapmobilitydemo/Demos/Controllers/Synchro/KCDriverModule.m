//
//  KCDriverModule.m
//  TencentMapLocusSynchroDemo
//
//  Created by mol on 2021/9/2.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "KCDriverModule.h"
#import <TencentMapLocusSynchroDriverSDK/TencentMapLocusSynchroDriverSDK.h>
#import "Constants.h"
#import "TLSRoutePolyline.h"
#import "MathTool.h"
#import "CarRoutePolyline.h"
#import "KCOrderManager.h"
#import "SVProgressHUD.h"

@interface KCDriverModule () <TLSDriverManagerDelegate>

// 司乘同显乘客端管理对象
@property (nonatomic, strong) TLSDriverManager *driverManager;
@property (nonatomic, strong) TNKCarNaviManager *carNaviManger;

// 路径规划路线
@property (nonatomic, copy, nullable) TNKCarRouteSearchResult *searchResult;

// 当前选中路线index
@property (nonatomic, assign) int curRouteIndex;

// 路线polyline
@property (nonatomic, strong, nullable) CarRoutePolyline *routePolyline;

@property (nonatomic, strong) KCMyOrder *order;

@end

@implementation KCDriverModule

#pragma mark  - lifecycle

#pragma mark  - lifecycle

- (instancetype)initWithOrder:(KCMyOrder *)order {
    self = [super init];
    if (self) {
        
        self.order = order;
        [self setupDriverManager];

    }
    
    return self;
}


#pragma mark - setup

// 初始化司乘同显
- (void)setupDriverManager {
    
    TLSDConfig *dConfig = [[TLSDConfig alloc] init];
    // 乘客id
    dConfig.driverID = self.order.driverID;
    dConfig.key = kSynchroKey;
    dConfig.secretKey = kSynchroSecretKey;

    self.driverManager = [[TLSDriverManager alloc] initWithConfig:dConfig];
    self.driverManager.delegate = self;
    // 设置订单id
    self.driverManager.orderID =  self.order.orderID;
    // 快车订单
    self.driverManager.orderType = TLSBOrderTypeNormal;
    // 订单状态为初始状态
    self.driverManager.orderStatus = self.order.orderStatus;
    
    self.carNaviManger = [[TNKCarNaviManager alloc] init];
    self.driverManager.carNaviManger = self.carNaviManger;
}

#pragma mark - public

- (void)setOrderStatus:(TLSBOrderStatus)orderStatus {
    _orderStatus = orderStatus;
    
    self.driverManager.orderStatus = orderStatus;
}

// 路径规划
- (void)searchRouteAndStartNaviWithStart:(TNKSearchNaviPoi *)startPOI
                                     end:(TNKSearchNaviPoi *)endPOI
                                  option:(TNKCarRouteSearchOption * _Nullable)option {
    
    __weak typeof(self) weakself = self;
    
    // 移除当前路线
    [self.carNaviView.naviMapView removeOverlay:self.routePolyline];

    // 司乘同显路径规划接口，内部调用了导航SDK的路径规划服务
    [self.driverManager searchTripCarRoutesWithStart:startPOI
                                                 end:endPOI
                                           wayPoints:nil
                                              option:option
                                          completion:^(TNKCarRouteSearchResult * _Nonnull result, NSError * _Nullable error, TLSBChooseRouteInfo * _Nullable chooseRouteInfo) {
       
        __strong KCDriverModule *strongself = weakself;
        if (!strongself) {
            return ;
        }
        
        if (error) {
            // 处理错误
            return;
        }
        
        TNKCarRouteSearchRoutePlan *routePlan;
        if (chooseRouteInfo) {
            if (chooseRouteInfo.chooseRouteStatus == TLSBChooseRouteStatusMatchedSuccess) {
                // 行前乘客指路信息，chooseRouteInfo.selectedRouteID为乘客选择的路线
                routePlan = [result.routes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"routeID=%@", chooseRouteInfo.selectedRouteID]].firstObject;
                [SVProgressHUD showSuccessWithStatus:@"匹配乘客行前选路路线！"];
            } else if (chooseRouteInfo.chooseRouteStatus == TLSBChooseRouteStatusMatchedFail) {
                [SVProgressHUD showErrorWithStatus:@"没能匹配乘客行前选路路线！"];
            }
            
        }
        
        if (!routePlan) {
            // 无乘客行前选路信息，选择第一条路
            routePlan = result.routes.firstObject;
        }
        
        strongself.curRouteIndex = (int)[strongself.searchResult.routes indexOfObject:routePlan];
        
        [strongself showTipRoute:routePlan];
    }];
}

- (void)setCarNaviView:(TNKCarNaviView *)carNaviView {
    _carNaviView = carNaviView;
    
    self.driverManager.carNaviView = carNaviView;
    [self.driverManager.carNaviManger registerUIDelegate:carNaviView];
}

- (BOOL)isMyOverlay:(id<QOverlay>)overlay {
    return self.routePolyline == overlay;
}

- (void)handleDidTapOverlay:(id<QOverlay>)overlay {
   
    
}

#pragma mark -
- (void)showTipRoute:(TNKCarRouteSearchRoutePlan *)routePlan {
    
    CarRoutePolyline *polyLine = [[CarRoutePolyline alloc] initWithRoute:routePlan];
    [self.carNaviView.naviMapView addOverlay:polyLine];
    self.routePolyline = polyLine;
    
    [self adjestVisiableMapRectIfNeeded];
}

- (void)adjestVisiableMapRectIfNeeded {
  
    // 更新视野
    QMapRect mapRect = [MathTool mapRectFitsPoints:self.routePolyline.routePlan.line.coordinatePoints];
    [self.carNaviView.naviMapView setVisibleMapRect:mapRect
                                        edgePadding:UIEdgeInsetsMake(50, 50, 20, 50)
                                           animated:YES];
}

@end
