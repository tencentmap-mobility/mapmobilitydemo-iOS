//
//  KCOrderSyncViewController.m
//  TencentMapLocusSynchroDemo
//
//  Created by mol on 2021/9/9.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "KCOrderSyncViewController.h"
#import "KCOrderManager.h"
#import "Constants.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface KCOrderSyncViewController ()

@property (nonatomic, strong) UITextField *orderIDField;
@property (nonatomic, strong) KCMyOrder *order;

@end

@implementation KCOrderSyncViewController


#pragma mark - life cycle


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupToolbar];
 
    [self setupViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:NO animated:animated];
}

- (void)dealloc {

}


#pragma mark - private

- (void)setupToolbar {
    
    UIBarButtonItem *flexble = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *createButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"1.创建订单" style:UIBarButtonItemStyleDone target:self action:@selector(createOrder:)];
    UIBarButtonItem *pickupButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"2.至接驾状态" style:UIBarButtonItemStyleDone target:self action:@selector(changeOrderToPickup:)];
    
    UIBarButtonItem *tripButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"3.至送驾状态" style:UIBarButtonItemStyleDone target:self action:@selector(changeOrderToTrip:)];
    
    self.toolbarItems = @[flexble,
                          createButtonItem,
                          flexble,
                          pickupButtonItem,
                          flexble,
                          tripButtonItem,
                          flexble,
    ];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)createOrder:(UIBarButtonItem *)buttonItem {
    
    self.order.orderID = self.orderIDField.text;
    
    [[KCOrderManager sharedInstance] createOrder:self.order completion:^(BOOL success, NSError * _Nullable error) {
       
        if (error) {
            NSString *errorDesc = [NSString stringWithFormat:@"创建失败:%@", error];
            [SVProgressHUD showErrorWithStatus:errorDesc];
        } else {
            [SVProgressHUD showSuccessWithStatus:@"创建订单成功！"];
        }
    }];
}

- (void)changeOrderToPickup:(UIBarButtonItem *)buttonItem {
    
    self.order.orderID = self.orderIDField.text;
    
    [[KCOrderManager sharedInstance] sendOrderToDriver:self.order driverID:self.order.driverID driverDev:self.order.driverDev driverCoord:self.order.startPOI.coord completion:^(BOOL success, NSError * _Nullable error) {
        
        if (error) {
            NSString *errorDesc = [NSString stringWithFormat:@"接驾状态流转失败:%@", error];
            [SVProgressHUD showErrorWithStatus:errorDesc];
        } else {
            [SVProgressHUD showSuccessWithStatus:@"接驾状态流转成功！"];
        }
    }];
}

- (void)changeOrderToTrip:(UIBarButtonItem *)buttonItem {
    
    self.order.orderID = self.orderIDField.text;
    
    [[KCOrderManager sharedInstance] changeOrderStatusToTrip:self.order driverCoord:self.order.startPOI.coord completion:^(BOOL success, NSError * _Nullable error) {
        
        if (error) {
            NSString *errorDesc = [NSString stringWithFormat:@"送驾状态流转失败:%@", error];
            [SVProgressHUD showErrorWithStatus:errorDesc];
        } else {
            [SVProgressHUD showSuccessWithStatus:@"送驾状态流转成功！"];
        }
    }];

}


- (void)setupViews {

    NSString *uuid = [NSUUID UUID].UUIDString;
    
    KCMyOrder *order = [[KCMyOrder alloc] init];
    // 订单id，这里随机生成
    order.orderID = uuid;

    // 乘客id
    order.passengerID = kSynchroKCPassenger1AccountID;
    order.passengerDev = [[UIDevice currentDevice] identifierForVendor].UUIDString;
    order.driverID = kSynchroKCDriverAccountID;
    order.driverDev = [[UIDevice currentDevice] identifierForVendor].UUIDString;

    //接驾点
    MyPOI *startPOI = [[MyPOI alloc] init];
    startPOI.coord =kSynchroKCPassenger1Start;
    startPOI.poiName = @"中国化工大厦-西门";
    order.startPOI = startPOI;

    // 送驾点
    MyPOI *endPOI = [[MyPOI alloc] init];
    endPOI.coord = kSynchroKCPassenger1End;
    endPOI.poiName = @"仓上小区[公交站]";
    order.endPOI = endPOI;

    // 北京
    order.adCode = @"110000";
    self.order = order;
    
    CGFloat leftPadding = 10.0f;
    CGFloat nextTop = 50.0f;
    
    UILabel *orderTitleLabel = [[UILabel alloc] init];
    orderTitleLabel.text = @"订单:";
    orderTitleLabel.font = [UIFont systemFontOfSize:13];
    [orderTitleLabel sizeToFit];
    orderTitleLabel.frame = CGRectMake(leftPadding, nextTop, orderTitleLabel.bounds.size.width, orderTitleLabel.bounds.size.height);
    [self.view addSubview:orderTitleLabel];
    
    nextTop = CGRectGetMaxY(orderTitleLabel.frame) + 20;
    
    self.orderIDField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(orderTitleLabel.frame) + 2, CGRectGetMidY(orderTitleLabel.frame) - 15, 280, 30)];
    self.orderIDField.layer.borderColor = [UIColor grayColor].CGColor;
    self.orderIDField.layer.borderWidth = 1;
    self.orderIDField.text = uuid;
    self.orderIDField.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:self.orderIDField];
    
    
    UILabel *driverTitleLabel = [[UILabel alloc] init];
    driverTitleLabel.text = [NSString stringWithFormat:@"司机ID:%@", order.driverID];
    driverTitleLabel.font = [UIFont systemFontOfSize:13];
    [driverTitleLabel sizeToFit];
    driverTitleLabel.frame = CGRectMake(leftPadding, nextTop, driverTitleLabel.bounds.size.width, driverTitleLabel.bounds.size.height);
    [self.view addSubview:driverTitleLabel];
    nextTop = CGRectGetMaxY(driverTitleLabel.frame) + 20;

    UILabel *passengerTitleLabel = [[UILabel alloc] init];
    passengerTitleLabel.text = [NSString stringWithFormat:@"乘客ID:%@", order.passengerID];
    passengerTitleLabel.font = [UIFont systemFontOfSize:13];
    [passengerTitleLabel sizeToFit];
    passengerTitleLabel.frame = CGRectMake(leftPadding, nextTop, passengerTitleLabel.bounds.size.width, passengerTitleLabel.bounds.size.height);
    [self.view addSubview:passengerTitleLabel];
    nextTop = CGRectGetMaxY(passengerTitleLabel.frame) + 20;
    
    UILabel *pickupTitleLabel = [[UILabel alloc] init];
    pickupTitleLabel.text = [NSString stringWithFormat:@"上车点坐标:%.6f,%.6f", order.startPOI.coord.latitude, order.startPOI.coord.longitude];
    pickupTitleLabel.font = [UIFont systemFontOfSize:13];
    [pickupTitleLabel sizeToFit];
    pickupTitleLabel.frame = CGRectMake(leftPadding, nextTop, pickupTitleLabel.bounds.size.width, pickupTitleLabel.bounds.size.height);
    [self.view addSubview:pickupTitleLabel];
    nextTop = CGRectGetMaxY(pickupTitleLabel.frame) + 20;
    
    UILabel *tripTitleLabel = [[UILabel alloc] init];
    tripTitleLabel.text = [NSString stringWithFormat:@"下车点坐标:%.6f,%.6f", order.endPOI.coord.latitude, order.endPOI.coord.longitude];
    tripTitleLabel.font = [UIFont systemFontOfSize:13];
    [tripTitleLabel sizeToFit];
    tripTitleLabel.frame = CGRectMake(leftPadding, nextTop, tripTitleLabel.bounds.size.width, tripTitleLabel.bounds.size.height);
    [self.view addSubview:tripTitleLabel];
    nextTop = CGRectGetMaxY(tripTitleLabel.frame) + 20;
    
}

@end
