# 出行检索SDK接入文档（iOS）

## 概述

出行检索SDK提供逆地址解析和关键词检索服务驾车路线规划检索，步行路线规划，并针对出行场景进行了优化。

## 准备工作

一、申请开发密钥

出行SDK使用前需要先配置APIKey进行鉴权，因为出行SDK中会引用地图SDK和WebServiceAPI，因此可以同时配置地图SDK和webServiceAPI为统一的Key，可前往[http://lbs.qq.com/console/mykey.html](http://lbs.qq.com/console/mykey.html)点击“创建新密钥”进行配置

![](../Picture1.png)

创建成功后，根据项目需求对key进行设置

![](../Picture2.png)

获取Bundle Identifier 方法：打开Xcode，点击工程，如图

![](../Picture3.png)


注：

1.地图SDK功能需要设置相应的Bundle Identifier，使用时key和Bundle Identifier需要保持一致

2.对于WebServiceAPI的key申请配置，只能使用第一种“域名白名单”（不需要在SDK中额外设置）或者第三种“签名校验”（需在SDK中配置secretKey）

## 工程配置

一、配置地图SDK   
推荐上车点SDK需要依赖3D地图SDK（4.1.1以上版本），可在官网进行3D地图SDK的下载和工程配置（地图工程配置指引:[https://lbs.qq.com/ios_v1/guide-project-setup.html](https://lbs.qq.com/ios_v1/guide-project-setup.html)）
注：4.1.1以上版本的地图SDK和5.0.0版本以上的导航SDK均已支持libc++.tbd


## 快速接入

一、配置key

在工程的“AppDelegate.m”中引入“#import < QMapKit/QMapKit.h >” 和“#import < TencentMapMobilitySDK/TMMServices.h >”

```objc

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [QMapServices sharedServices].APIKey = @"您的key";
    [TMMServices sharedServices].apiKey = @"您的key";
    return YES;
}
```

因检索SDK需要使用定位SDK，所以需要在使用时配置定位SDK的key

```objc
    [self.locationManager setApiKey:@"您的key"];
```
二、创建manager

创建检索需要使用的manager

```objc
@property(nonatomic, strong) TMMSearchManager searchManager;
```

三、设置地图

```objc

- (void)setupMapView
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.mapView = [[QMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.autoresizingMask  = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.showsUserLocation = NO;
    self.mapView.delegate = self;
    self.mapView.zoomLevel = 12.5;
    self.mapView.centerCoordinate = CLLocationCoordinate2DMake(39.931625, 116.352976);
    [self.view addSubview:self.mapView];
}
```

四、检索SDK能力

4.1 逆地址解析
```objc
// 创建逆地址解析请求对象
TMMSearchReGeocodeRequest *request = [[TMMSearchReGeocodeRequest alloc] init];
// 必传参数为定位点
request.locationCoordinate = CLLocationCoordinate2DMake(40.040414993, 116.273511063);

// 发起逆地址解析请求
[TMMSearchManager queryReGeocodeWithRequest:request 
completion:^(TMMSearchReGeocodeResponse *response, NSError *error) {

 }];
```

4.2 关键词检索

```objc
// 创建检索请求对象
TMMSearchSuggestionRequest *request = [[TMMSearchSuggestionRequest alloc] init];
// 关键词
request.keyword = @"天安门";
// 所属城市
request.region = @"北京";
// 检索的地点为出发点
request.policy = TMMSSuggestionPolicySource;
// 用户位置坐标
request.locationCoordinate = CLLocationCoordinate2DMake(40.040414993, 116.273511063);

// 发起检索请求
[TMMSearchManager querySuggestionWithRequest:request
completion:^(TMMSearchSuggestionResponse *response, NSError *error) {

 }];
```

4.3 驾车路线规划

```objc
 TMMSearchDrivingRequest *drivingRequest = [[TMMSearchDrivingRequest alloc] init];
 drivingRequest.start = [[TMMNaviPOI alloc] init];
 drivingRequest.destination = [[TMMNaviPOI alloc] init];

 drivingRequest.start.coordinate = 起点坐标;
 drivingRequest.destination.coordinate = 终点坐标;
 
 // 发起驾车路线规划请求   
[TMMSearchManager queryDrivingWithRequest:drivingRequest completion:^(TMMSearchDrivingResponse * _Nullable response, NSError * _Nullable error) {
   //画路线
}];

```
4.4 步行路线规划


```objc
TMMSearchWalkingRequest *walkingRequest = [[TMMSearchWalkingRequest alloc] init];
walkingRequest.startCoordinate = 起点坐标;
walkingRequest.destinationCoordinate = 终点坐标;

 
 // 发起步行路线规划请求   
[TMMSearchManager queryWalkingWithRequest:walkingRequest completion:^(TMMSearchWalkingResponse * _Nullable response, NSError * _Nullable error) {
  // 画路线
}];

```
