# 司乘同显SDK乘客端（iOS）


## 1. 初始化配置

1.1 在工程的AppDelegate.m中引入配置key


```objc

#import < QMapKit/QMapKit.h >
#import <TNKNavigationKit/TNKNaviServices.h>

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 配置地图key
    [QMapServices sharedServices].APIKey = @"您的key";
    
    return YES;
}
```

1.2 需要配置司乘同显SDK的key，乘客id

```objc
    TLSPConfig *pConfig = [[TLSPConfig alloc] init];
    pConfig.key = @"您的key";
    pConfig.passengerID = kSynchroPassenger1ID;
    
    self.passengerManager.delegate = self;
```


## 2. 开启司乘同显乘客端

2.1 司机接单后，乘客端可开启司乘同显，需要设置对应的订单号

```objc
    self.passengerManager.orderID = kSynchroDriverOrderID;
    self.passengerManager.pOrderID = kSynchroPassenger1OrderID;
    self.passengerManager.orderType = TLSBOrderTypeNormal;
    self.passengerManager.orderStatus = TLSBOrderStatusPickup;
    [self.driverManager start];
```

2.2 通过回调获取相应的司机路线，轨迹和订单信息

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

2.3 接到乘客后，将订单状态改为送驾

```objc
    self.passengerManager.orderStatus = TLSBOrderStatusTrip;
```

2.4 结束司乘同显

```objc
 	[self.passengerManager stop];
```

## 3. 司乘同显乘客端回调

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
