# 司乘同显SDK接入文档（iOS）

## 概述

司乘同显SDK是在网约车接驾送驾场景中，帮助司机和乘客两端实时了解行程信息，主要可以同步展示司机端的路线、路况、剩余里程和剩余时间以及双方的实时位置和行驶轨迹。
   
乘客端使用司乘同显SDK时，需要依赖地图SDK，使用地图SDK中的路线绘制、添加覆盖物等功能。

使用司乘同显SDK时首先需要通过订单同步接口创建订单，并且需配置订单ID、司机ID和乘客ID来建立三者的关联关系。另外，订单有三个属性，分别是订单ID，订单类型和订单状态，订单类型包括快车和顺风车，订单状态包括未派单、已派单、计费中；

用户可使用Demo查看司乘同显SDK的使用效果。准备两个手机，一个打开司机端，另一个打开乘客端。测试时，司机端已开启同步功能并且已经进入导航界面，乘客端点击“启动同步”按钮，可看到司机端当前路线和小车的平滑移动。

## 准备工作

申请开发密钥

司乘同显SDK使用前需要先配置APIKey进行鉴权，具体可联系对应的商务同学来开通。

## 工程配置

一、配置地图SDK （必须）  
司乘同显SDK（司机端&乘客端）需要依赖3D地图SDK（4.1.1以上版本），可在官网进行3D地图SDK的下载和工程配置（地图工程配置指引:[https://lbs.qq.com/ios_v1/guide-project-setup.html](https://lbs.qq.com/ios_v1/guide-project-setup.html)）
注：4.1.1以上版本的地图SDK和5.0.0版本以上的导航SDK均已支持libc++.tbd

二、配置导航SDK （必须）

同时司乘同显SDK（司机端）需使用导航SDK，具体可联系对应的商务同学来开通。

三、配置定位SDK（非必须）    
同时司乘同显demo（司机端&乘客端）使用定位SDK（TencentLBS.framework）
使用方法可以具体参考官网：[https://lbs.qq.com/iosgeo/guide-project-setup.html](https://lbs.qq.com/iosgeo/guide-project-setup.html)

四、小车平滑移动SDK（非必须） 

同时司乘同显demo（乘客端）需使用小车平滑移动SDK（QMapSDKUtils.framework），具体可联系对应的商务同学来开通。


注：   
1.配置完成后， 检查"Build Phases"->"Link Binary With Libraries"，如下图（Xcode9 以上）   
![](../Picture6.png)   

2.要将地图SDK的“QMapKit.framework”和定位SDK的“TencentLBS.framework”以及司乘同显SDK的“TencentMapLocusSynchroSDK.framework”，“TencentMapLocusSynchroDriverSDK.framework”, "TencentMapLocusSynchroPassengerSDK.framework"加入到自己的工程中。   
添加方法：在工程界面右键弹出菜单中选择"Add Files To..."，注意添加时在弹出窗口中勾选"Copy items if needed" 。   
![](../Picture7.png) 

## 快速接入

一、初始化配置

在工程的“AppDelegate.m”中引入“#import < QMapKit/QMapKit.h >” , "#import <TNKNavigationKit/TNKNaviServices.h>"

```objc

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [QMapServices sharedServices].APIKey = @"您的key";
    [TNKNaviServices sharedServices].APIKey = @"您的key";
    return YES;
}
```

1 司机侧

* 需要配置司乘同显SDK的key，driverID和orderID及其他相应的配置信息

```objc
    TLSDConfig *config = [[TLSDConfig alloc] init];
    config.key = @"您的key";
    config.driverID = kSynchroDriverAccountID;
    
	 self.driverManager = [[TLSDriverManager alloc] initWithConfig: config];
    self.driverManager.delegate = self;
    self.driverManager.carNaviView = self.carNaviView;
    self.driverManager.carNaviManger = self.carNaviManager;
    self.driverManager.orderID = kSynchroDriverOrderID;
    self.driverManager.orderType = TLSBOrderTypeHitchRide;
    self.driverManager.orderStatus = TLSBOrderStatusTrip;
    self.driverManager.driverStatus = TLSDDriverStatusServing;
```

* 初始化导航地图和导航

```objc

    // 初始化导航地图
    self.carNaviView = [[TNKCarNaviView alloc] initWithFrame:self.view.bounds];
    self.carNaviView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.carNaviView];
    self.carNaviView.delegate = self;
    self.carNaviView.showUIElements = YES;
    
    // 初始化导航管理器
    self.carNaviManager = [[TNKCarNaviManager alloc] init];
    [self.carNaviManager registerNaviDelegate:self];
    [self.carNaviManager registerUIDelegate:self.carNaviView];

```


2 乘客端

* 需要配置司乘同显SDK的key，passengerID,orderID, 和pOrderID及其他相应的配置信息

```objc
    TLSPConfig *pConfig = [[TLSPConfig alloc] init];
    pConfig.key = @"您的key";
    pConfig.passengerID = kSynchroPassenger1ID;
    
    self.passengerManager.delegate = self;
    self.passengerManager.orderID = kSynchroDriverOrderID;
    self.passengerManager.pOrderID = kSynchroPassenger1OrderID;
    self.passengerManager.orderType = TLSBOrderTypeHitchRide;
    self.passengerManager.orderStatus = TLSBOrderStatusTrip;
```


二、开启司乘同显司机端

*  司机上线时，可使用该代码启动司乘同显 

```objc
    [self.driverManager start];
```
* 设置起终点和途径点开启导航

```objc
	 // 导航起终点
    TNKSearchNaviPoi *startPOI = [[TNKSearchNaviPoi alloc] init];
    startPOI.coordinate = CLLocationCoordinate2DMake(39.938962,116.375685);
    TNKSearchNaviPoi *endPOI = [[TNKSearchNaviPoi alloc] init];
    endPOI.coordinate = CLLocationCoordinate2DMake(39.911975,116.351395);
    
    // 顺风车需要途径点，快车不需要途径点
    TLSDSortRequestWayPoint *order1WayPoint = [[TLSDSortRequestWayPoint alloc] init];
    order1WayPoint.pOrderID = kSynchroPassenger1OrderID;
    order1WayPoint.startPoint = kSynchroPassenger1Start;
    order1WayPoint.endPoint = kSynchroPassenger1End;

    TLSDSortRequestWayPoint *order2WayPoint = [[TLSDSortRequestWayPoint alloc] init];
    order2WayPoint.pOrderID = kSynchroPassenger2OrderID;
    order2WayPoint.startPoint = kSynchroPassenger2Start;
    order2WayPoint.endPoint = kSynchroPassenger2End;

    
    __weak typeof(self) weakself = self;

    [self.driverManager searchCarRoutesWithStart:startPOI end:endPOI wayPoints:@[order1WayPoint, order2WayPoint] option:nil completion:^(TNKCarRouteSearchResult * _Nonnull result, NSError * _Nullable error) {
        
        __strong DriverSynchroViewController *strongself = weakself;
        if (!strongself) {
            return ;
        }
        
        if (error) {
            // 处理错误
            return;
        }
        strongself.naviView.showUIElements = YES;
        [strongself.driverManager uploadRouteWithIndex:0];
        [strongself.naviManager startSimulateWithIndex:0 locationEntry:nil];
    }];

```


注意：因为司乘同显司机端manager会持有导航的manager和地图的manager，用户可以直接进行对于导航和地图的操作

* 上报司机轨迹点信息

现在司机在非导航过程中，需要上报轨迹点信息，可以通过从定位SDK拿的点进行上报; 导航中的轨迹点上报，司乘同显会自己进行处理

```objc
- (void)tencentLBSLocationManager:(TencentLBSLocationManager *)manager
                didUpdateLocation:(TencentLBSLocation *)location {
    //定位结果
    NSLog(@"location:%@", location.location);
    
    self.cityCode = location.code;
    
    self.driverManager.cityCode = location.code;
    
    if (self.naviManager.isStoped) {
        NSTimeInterval timestamp = [location.location.timestamp timeIntervalSince1970];

        if(timestamp == self.lastLocationTimestamp)
        {
            return;
        }
        
        TLSDDriverPosition *position = [[TLSDDriverPosition alloc] init];
        position.location = location.location;
        [self.driverManager uploadPosition:position];
    }
}

```
* 上报司机路线信息

在初始算路和重新进行路线规划的时候需要

```objc
// 初始算路
- (void)searchRouteAndStartNaviWithStart:(TNKSearchNaviPoi *)startPOI
                                     end:(TNKSearchNaviPoi *)endPOI
                               wayPoints:(NSArray<TLSDWayPointInfo *> * _Nullable)wayPoints {
    
    __weak typeof(self) weakself = self;

    [self.driverManager searchCarRoutesWithStart:startPOI end:endPOI wayPoints:wayPoints option:nil completion:^(TNKCarRouteSearchResult * _Nonnull result, NSError * _Nullable error) {
       
        __strong DriverSynchroViewController *strongself = weakself;
        if (!strongself) {
            return ;
        }
        
        if (error) {
            // 处理错误
            return;
        }
        
        [strongself.driverManager uploadRouteWithIndex:0];
        [strongself.carNaviManager startSimulateWithIndex:0 locationEntry:nil];
    }];
}


// 重新进行路线规划
- (void)tlsDriverManager:(TLSDriverManager *)driverManager didRemoveWayPointInfo:(TLSDWayPointInfo *)removedWayPointInfo {
    
    TNKSearchNaviPoi *startPOI = [[TNKSearchNaviPoi alloc] init];
    startPOI.coordinate = self.currentCoord;

    // 重新路线规划
    __weak typeof(self) weakself = self;
    [driverManager searchCarRoutesWithStart:startPOI end:driverManager.endPOI wayPoints:driverManager.remainingWayPointInfoArray option:driverManager.searchOption completion:^(TNKCarRouteSearchResult * _Nonnull result, NSError * _Nullable error) {
       
        __strong DriverSynchroViewController *strongself = weakself;
        if (!strongself) {
            return ;
        }
        
        if (error) {
            // 处理错误
            return;
        }
    
        if (![strongself.carNaviManager isStoped]) {
            [strongself.carNaviManager stop];
        }
        
        [strongself.driverManager uploadRouteWithIndex:0];
        [strongself.carNaviManager startSimulateWithIndex:0 locationEntry:nil];
    }];
}

```

* 结束司乘同显服务

```objc
	[self.driverManger stop];

```

三、开启司乘同显乘客端

*  乘客上线时，可使用该代码启动司乘同显 

```objc
    [self.passengerManager start];
```

* 通过回调获取相应的司机路线，轨迹和订单信息

```objc
- (void)tlsPassengerManager:(TLSPassengerManager *)passengerManager didFetchedData:(TLSPFetchedData *)fetchedData
{
    
    // 更新路线需重新绘制.
    if (![self.currentRouteID isEqualToString:fetchedData.route.routeID]) {
        
        // 重新绘制路线.
        [self updateRoute:fetchedData.route];
    }
    // 相同路线更新路况.
    else
    {
        if(fetchedData.route.trafficItems != nil)
        {
            [self updateRouteTraffic:fetchedData.route.trafficItems];
        }
    }
    
    
    // 更新位置.
    [self updateLocation:fetchedData.positions];
      
}

```

* 结束时，可使用该代码结束司乘同显

```objc
 	[self.passengerManager stop];
```

三、定位SDK配置

```objc

- (void)configLocationManager
{
    self.locationManager = [[TencentLBSLocationManager alloc] init];
    
    [self.locationManager setDelegate:self];
    
    [self.locationManager setApiKey:kSynchroKey];
    
    [self.locationManager setPausesLocationUpdatesAutomatically:NO];
    
    // 需要后台定位的话，可以设置此属性为YES。
    [self.locationManager setAllowsBackgroundLocationUpdates:YES];
    
    // 如果需要POI信息的话，根据所需要的级别来设定，定位结果将会根据设定的POI级别来返回，如：
    [self.locationManager setRequestLevel:TencentLBSRequestLevelAdminName];
    
    // 申请的定位权限，得和在info.list申请的权限对应才有效
    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
    if (authorizationStatus == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
    }
}

// 连续定位
- (void)startSerialLocation {
    //开始定位
    [self.locationManager startUpdatingLocation];
}

- (void)stopSerialLocation {
    //停止定位
    [self.locationManager stopUpdatingLocation];
}

- (void)tencentLBSLocationManager:(TencentLBSLocationManager *)manager
                 didFailWithError:(NSError *)error {
    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
    if (authorizationStatus == kCLAuthorizationStatusDenied ||
        authorizationStatus == kCLAuthorizationStatusRestricted) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                       message:@"定位权限未开启，是否开启？"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"是"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    if( [[UIApplication sharedApplication]canOpenURL:
                                                         [NSURL URLWithString:UIApplicationOpenSettingsURLString]] ) {
                                                        [[UIApplication sharedApplication] openURL:
                                                         [NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                                    }
                                                }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"否"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                }]];
        
        
    }
}


- (void)tencentLBSLocationManager:(TencentLBSLocationManager *)manager
                didUpdateLocation:(TencentLBSLocation *)location {
    //定位结果
    NSLog(@"location:%@", location.location);
    
    self.cityCode = location.code;
    
    self.driverManager.cityCode = location.code;
    
    if (self.naviManager.isStoped) {
        NSTimeInterval timestamp = [location.location.timestamp timeIntervalSince1970];

        if(timestamp == self.lastLocationTimestamp)
        {
            return;
        }
        
        TLSDDriverPosition *position = [[TLSDDriverPosition alloc] init];
        position.location = location.location;
        [self.driverManager uploadPosition:position];
    }
}


```

四、司乘同显司机端回调

```objc
// 上报定位成功回调
- (void)tlsDriverManagerDidUploadLocationSuccess:(TLSDriverManager *)driverManager;
// 上报定位失败回调
- (void)tlsDriverManagerDidUploadLocationFail:(TLSDriverManager *)driverManager error:(NSError *)error;

// 上报路线成功回调
- (void)tlsDriverManagerDidUploadRouteSuccess:(TLSDriverManager *)driverManager;
// 上报路线失败回调
- (void)tlsDriverManagerDidUploadRouteFail:(TLSDriverManager *)driverManager error:(NSError *)error;

// 拉去乘客信息回调
- (void)tlsDriverManager:(TLSDriverManager *)driverManager didFetchData:(TLSDFetchedData *)fetchedData;

// 移除途经点之后需要重新路线规划并启动导航
- (void)tlsDriverManager:(TLSDriverManager *)driverManager didRemoveWayPointInfo:(TLSDWayPointInfo *)removedWayPointInfo;
```
五、司乘同显乘客端回调

```objc
// 上报定位成功回调
- (void)tlsPassengerManagerDidUploadLocationSuccess:(TLSPassengerManager *)passengerManager;
// 上报定位失败回调
- (void)tlsPassengerManagerDidUploadLocationFail:(TLSPassengerManager *)passengerManager error:(NSError *)error;
// 拉取司机信息成功回调
- (void)tlsPassengerManager:(TLSPassengerManager *)passengerManager didFetchedData:(TLSPFetchedData*)fetchedData;
// 拉取司机信息失败回调
- (void)tlsPassengerManager:(TLSPassengerManager *)passengerManager didFailWithError:(NSError *)error;
```
