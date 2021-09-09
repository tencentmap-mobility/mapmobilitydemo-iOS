# 司乘同显SDK司机端（iOS）


## 1.初始化配置

1.1 在工程的AppDelegate.m中引入配置key

```objc

#import < QMapKit/QMapKit.h >
#import <TNKNavigationKit/TNKNaviServices.h>

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 配置地图key
    [QMapServices sharedServices].APIKey = @"您的key";
    // 配置导航key
    [TNKNaviServices sharedServices].APIKey = @"您的key";
    
    return YES;
}
```

1.2 初始化导航地图和导航

```objc

    // 初始化导航地图
    self.carNaviView = [[TNKCarNaviView alloc] initWithFrame:self.view.bounds];
    self.carNaviView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.carNaviView];
    self.carNaviView.delegate = self;
    self.carNaviView.showUIElements = YES;
    
    // 初始化导航管理器
    self.carNaviManager = [[TNKCarNaviManager alloc] init];
    // 使用导航自带tts播报
    self.carNaviManager.enableInternalTTS = YES;
    [self.carNaviManager registerNaviDelegate:self];
    // 将导航管理器和导航地图关联
    [self.carNaviManager registerUIDelegate:self.carNaviView];

```
1.3 需要配置司乘同显SDK的key，driverID

```objc
    TLSDConfig *config = [[TLSDConfig alloc] init];
    config.key = @"您的key";
    config.driverID = kSynchroDriverAccountID;
    
	 self.driverManager = [[TLSDriverManager alloc] initWithConfig: config];
    self.driverManager.delegate = self;
    // 导航地图交给司乘同显管理
    self.driverManager.carNaviView = self.carNaviView;
    // 导航管理器交给司乘同显管理
    self.driverManager.carNaviManger = self.carNaviManager;##
```

## 2. 司机端主流程

### 2.1 听单状态

2.1.1 司机上线进入听单状态，需要开发者开启司乘同显

```objc
    
    // 订单设置为空
    self.driverManager.orderID = nil;
    // 订单状态为快车
    self.driverManager.orderType = TLSBOrderTypeNormal;
    // 订单状态为初始状态
    self.driverManager.orderStatus = TLSBOrderStatusNone;
    // 订单状态切换为听单中
    self.driverManager.driverStatus = TLSDDriverStatusListening;
    
    // 开启司乘同显
    [self.driverManager start];
```

2.1.2 司机需要上报定位点，以便接单。只有听单状态需要开发者上报，导航过程中司乘同显自动上报

```objc
	// 上报定位点方法。可以从定位SDK的连续定位回调中获取
    //[self.driverManager uploadPosition:myPosition];
```

### 2.2 接到订单，进入接驾状态
开发者服务端需要调用订单同步接口（/order/sync），将订单切换为接驾状态，将司机id也做订单同步

2.2.1 设置接到的订单

```objc
	// 订单设置为真实订单id
    self.driverManager.orderID = orderID;
    // 订单状态为快车
    self.driverManager.orderType = TLSBOrderTypeNormal;
    // 订单状态为接驾
    self.driverManager.orderStatus = TLSBOrderStatusPickup;
    // 订单状态切换为服务中
    self.driverManager.driverStatus = TLSDDriverStatusServing;
```

2.2.2 路径规划+上报路线+开启导航
    
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
        // 上报路线
        [strongself.driverManager uploadRouteWithIndex:0];
        // 开启模拟导航
        [strongself.naviManager startSimulateWithIndex:0 locationEntry:nil];
        // 开启真实导航
        //[strongself.naviManager startWithIndex:0];
       
    }];

```

2.2.3 到达接驾点
```objc
	// 停止导航
	 [self.naviManager stop];
```

### 2.3 接到乘客，进入送驾状态
开发者服务端需要调用订单同步接口（/order/sync），将订单切换为送驾状态

2.3.1 设置订单状态

```objc
    // 订单状态为送驾
    self.driverManager.orderStatus = TLSBOrderStatusTrip;
```

2.3.2 路径规划+上报路线+开启导航
    
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
        // 上报路线
        [strongself.driverManager uploadRouteWithIndex:0];
        // 开启模拟导航
        [strongself.naviManager startSimulateWithIndex:0 locationEntry:nil];
        // 开启真实导航
        //[strongself.naviManager startWithIndex:0];
       
    }];

```

2.3.3 到达送驾终点
开发者服务端需要调用订单同步接口（/order/sync），将订单切换为结束状态

```objc
		// 停止导航
	 [self.naviManager stop];
	 
	 // 订单设置为空
    self.driverManager.orderID = nil;
    // 订单状态为快车
    self.driverManager.orderType = TLSBOrderTypeNormal;
    // 订单状态为初始状态
    self.driverManager.orderStatus = TLSBOrderStatusNone;
    // 订单状态切换为听单中
    self.driverManager.driverStatus = TLSDDriverStatusListening;
	 
```


### 2.4 结束司乘同显服务

```objc
	[self.driverManger stop];

```

## 3. 接力单
3.1 如果司机送驾过程中接到了接力单，需调TLSDriverManager+Navigation.h用方法：

```objc
/**
 * @brief 设置接力单信息。只支持快车
 * @param relayOrderID 接力单订单id
 * @param relayPickupPoint 接力单接驾点
 * @param curTripPoint 当前单送驾点
 * @param option 接力单接驾路线规划策略
 * @param callback 路线返回值
 */
- (void)setupRelayOrder:(NSString *)relayOrderID
       relayPickupPoint:(TNKSearchNaviPoi *)relayPickupPoint
           curTripPoint:(TNKSearchNaviPoi *)curTripPoint
                 option:(TNKCarRouteSearchOption * _Nullable)option
             completion:(void (^)(TNKCarRouteSearchResult *result, NSError * _Nullable error))callback;
```

3.2 获得到接力路线后，将接力路线上传:

```objc
/// 上报接力单路线
/// @param routeSearchRoutePlan 路线
- (BOOL)uploadRelayRoute:(TNKCarRouteSearchRoutePlan *)routeSearchRoutePlan;
```

3.3 当前订单送驾结束后，清理接力单信息，并将接力单信息设置为当前订单

```objc
/**
 * @brief 移除接力单
 */
- (void)removeRelayOrder;
```


## 4. 乘客选路
乘客可以在送驾前和送驾中去提前选择或切换送驾路线。 司机端需开启选路功能

```objc
/**
 * @brief 是否开启乘客选路功能
 */
@property (nonatomic, assign) BOOL passengerChooseRouteEnable;
```

### 4.1 送驾前选路
那么司机端在开始送驾时，调用如下方法进行路径规划：

```objc
/**
 * @brief 快车送驾路线规划方法. since 2.2.0
 * @param start 起点信息
 * @param end 终点信息
 * @param option 路线规划策略
 * @param callback 路线返回值。chooseRouteInfo若有值，表示乘客选中了某条路线，开发者可以使用乘客选择的路线进行导航
 */
- (void)searchTripCarRoutesWithStart:(TNKSearchNaviPoi *)start
                                 end:(TNKSearchNaviPoi *)end
                              option:(TNKCarRouteSearchOption * _Nullable)option
                          completion:(void (^)(TNKCarRouteSearchResult *result,
                                               NSError * _Nullable error,
                                               TLSBChooseRouteInfo * _Nullable chooseRouteInfo))callback;
```

如果乘客进行了行前选路，chooseRouteInfo会给出乘客行前选路的路线id，司机端可以选择该路线发起送驾导航


### 4.2 送驾中选路
司乘同显自动会切换导航路线，并将信息回调给开发者

```objc
/// 乘客选路成功回调. since 2.2.0. 如果当前正在导航，则路线被自动切换。如果当前还没开启导航，需要开发者重新绘制路线然后使用routePlan中的routeID去开启导航
/// @param driverManager 司机manager
/// @param routePlan 路线数据
/// @param trafficStatus 路况数据
- (void)tlsDriverManager:(TLSDriverManager *)driverManager
 didPassengerChangeRoute:(TNKCarRouteSearchRoutePlan *)routePlan
      routeTrafficStatus:(TNKRouteTrafficStatus *)trafficStatus;

/**
 * @brief 乘客选路失败回调. since 2.2.0
 * @param driverManager 司机manager
 * @param error 错误信息
 */
- (void)tlsDriverManagerDidPassengerChangeRouteFail:(TLSDriverManager *)driverManager error:(NSError *)error;

```

## 5. 司乘同显司机端回调

```objc
/**
 * @brief 司乘同显-司机管理类代理
 */
@protocol TLSDriverManagerDelegate <NSObject>

@optional

/**
 * @brief 上报定位成功回调
 * @param driverManager 司机manager
 */
- (void)tlsDriverManagerDidUploadLocationSuccess:(TLSDriverManager *)driverManager;

/**
 * @brief 上报定位失败回调
 * @param driverManager 司机manager
 * @param error 错误信息
 */
- (void)tlsDriverManagerDidUploadLocationFail:(TLSDriverManager *)driverManager error:(NSError *)error;

/**
 * @brief 上报路线成功回调
 * @param driverManager 司机manager
 */
- (void)tlsDriverManagerDidUploadRouteSuccess:(TLSDriverManager *)driverManager;

/**
 * @brief 上报路线失败回调
 * @param driverManager 司机manager
 * @param error 错误信息
 */
- (void)tlsDriverManagerDidUploadRouteFail:(TLSDriverManager *)driverManager error:(NSError *)error;

/**
 * @brief 拉取乘客信息回调
 * @param driverManager 司机manager
 * @param fetchedData 拉取乘客的信息
 */
- (void)tlsDriverManager:(TLSDriverManager *)driverManager didFetchData:(TLSDFetchedData * _Nullable)fetchedData;

/**
 * @brief 移除途经点之后需要重新路线规划并启动导航
 * @param driverManager 司机manager
 * @param removedWayPointInfo 移除的途径点信息
 */
- (void)tlsDriverManager:(TLSDriverManager *)driverManager didRemoveWayPointInfo:(TLSDWayPointInfo *)removedWayPointInfo;


/// 乘客选路成功回调. since 2.2.0. 如果当前正在导航，则路线被自动切换。如果当前还没开启导航，需要开发者重新绘制路线然后使用routePlan中的routeID去开启导航
/// @param driverManager 司机manager
/// @param routePlan 路线数据
/// @param trafficStatus 路况数据
- (void)tlsDriverManager:(TLSDriverManager *)driverManager
 didPassengerChangeRoute:(TNKCarRouteSearchRoutePlan *)routePlan
      routeTrafficStatus:(TNKRouteTrafficStatus *)trafficStatus;

/**
 * @brief 乘客选路失败回调. since 2.2.0
 * @param driverManager 司机manager
 * @param error 错误信息
 */
- (void)tlsDriverManagerDidPassengerChangeRouteFail:(TLSDriverManager *)driverManager error:(NSError *)error;

@end

```

## 6. 关于司机端路径规划和顺风车需要使用的最优送驾顺序的方法

```objc
/// 快车和顺风车路线规划方法
/// @param start 起点信息
/// @param end 终点信息
/// @param wayPoints 途经点信息
/// @param option 路线规划策略
/// @param callback 路线返回值
- (void)searchCarRoutesWithStart:(TNKSearchNaviPoi *)start
                             end:(TNKSearchNaviPoi *)end
                       wayPoints:(NSArray<TLSDWayPointInfo *> * _Nullable)wayPoints
                          option:(TNKCarRouteSearchOption * _Nullable)option
                      completion:(void (^)(TNKCarRouteSearchResult *result, NSError * _Nullable error))callback;

/// 拼车路线规划方法
/// @param start 起点信息
/// @param wayPoints 途经点信息
/// @param option 路线规划策略
/// @param callback 路线返回值
- (void)searchRideSharingCarRoutesWithStart:(TNKSearchNaviPoi *)start
                                  wayPoints:(NSArray<TLSDWayPointInfo *> * _Nullable)wayPoints
                                     option:(TNKCarRouteSearchOption * _Nullable)option
                                 completion:(void (^)(TNKCarRouteSearchResult *result, NSError * _Nullable error))callback;


/// 上报第几条路线信息。调用时机在初始路线规划（searchCarRoutesWithStart:end:wayPoints:option:completion）之后，导航开始之前。
/// @param routeIndex 路线索引
- (BOOL)uploadRouteWithIndex:(NSInteger)routeIndex;

// 接到乘客订单ID为pOrderID的乘客
- (void)arrivedPassengerStartPoint:(NSString *)pOrderID;

// 送到乘客订单ID为pOrderID的乘客
- (void)arrivedPassengerEndPoint:(NSString *)pOrderID;

/// 获取顺风车最优送驾顺序
/// @param startPoint 起点坐标
/// @param endPoint 终点坐标
/// @param originalWayPoints 途经点坐标,个数不能超过10个！
/// @param completion 最优顺序回调
- (NSURLSessionTask *)requestBestSortedWayPointsWithStartPoint:(CLLocationCoordinate2D)startPoint
                                                      endPoint:(CLLocationCoordinate2D)endPoint
                                                     wayPoints:(NSArray<TLSDWayPointInfo *> *)originalWayPoints
                                                    completion:(void(^)(NSArray<TLSDWayPointInfo *> * _Nullable sortedWayPoints, NSError * _Nullable error))completion;
/// 获取拼车最优送驾顺序
/// @param startPoint 起点坐标
/// @param originalWayPoints 途经点坐标,个数不能超过10个！
/// @param completion 最优顺序回调
- (NSURLSessionTask *)requestRideSharingBestSortedWayPointsWithStartPoint:(CLLocationCoordinate2D)startPoint
                                                     wayPoints:(NSArray<TLSDWayPointInfo *> *)originalWayPoints
                                                    completion:(void (^)(NSArray<TLSDWayPointInfo *> * _Nullable sortedWayPoints, NSError * _Nullable error))completion;

```
