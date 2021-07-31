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


## 2. 听单状态

2.1 司机上线进入听单状态，需要开发者开启司乘同显

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

2.2 司机需要上报定位点，以便接单。只有听单状态需要开发者上报，导航过程中司乘同显自动上报

```objc
	// 上报定位点方法。可以从定位SDK的连续定位回调中获取
    //[self.driverManager uploadPosition:myPosition];
```

## 3. 接到订单，进入接驾状态
开发者服务端需要调用订单同步接口（/order/sync），将订单切换为接驾状态，将司机id也做订单同步

3.1 设置接到的订单

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

3.2 路径规划+上报路线+开启导航
    
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

3.3 到达接驾点
```objc
	// 停止导航
	 [self.naviManager stop];
```

## 4. 接到乘客，进入送驾状态
开发者服务端需要调用订单同步接口（/order/sync），将订单切换为送驾状态

4.1 设置订单状态

```objc
    // 订单状态为送驾
    self.driverManager.orderStatus = TLSBOrderStatusTrip;
```

4.2 路径规划+上报路线+开启导航
    
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

4.3 到达送驾终点
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


## 5. 结束司乘同显服务

```objc
	[self.driverManger stop];

```


## 6、司乘同显司机端回调

```objc
// 上报定位成功回调
- (void)tlsDriverManagerDidUploadLocationSuccess:(TLSDriverManager *)driverManager;
// 上报定位失败回调
- (void)tlsDriverManagerDidUploadLocationFail:(TLSDriverManager *)driverManager error:(NSError *)error;

// 上报路线成功回调
- (void)tlsDriverManagerDidUploadRouteSuccess:(TLSDriverManager *)driverManager;
// 上报路线失败回调
- (void)tlsDriverManagerDidUploadRouteFail:(TLSDriverManager *)driverManager error:(NSError *)error;

// 拉取乘客信息回调
- (void)tlsDriverManager:(TLSDriverManager *)driverManager didFetchData:(TLSDFetchedData *)fetchedData;

// 移除途经点之后需要重新路线规划并启动导航
- (void)tlsDriverManager:(TLSDriverManager *)driverManager didRemoveWayPointInfo:(TLSDWayPointInfo *)removedWayPointInfo;
```
关于司机端路径规划和顺风车需要使用的最优送驾顺序的方法

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
