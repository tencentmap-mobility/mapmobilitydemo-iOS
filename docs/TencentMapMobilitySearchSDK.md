# 出行检索SDK接入文档（iOS）

## 概述

出行检索SDK提供逆地址解析和关键词检索服务，并针对出行场景进行了优化。

## 接入方法

## 使用方法

### 逆地址解析
```objc
// 创建逆地址解析请求对象
TMMSearchReGeocodeRequest *request = [[TMMSearchReGeocodeRequest alloc] init];
// 必传参数为定位点
request.locationCoordinate = CLLocationCoordinate2DMake(40.040414993, 116.273511063);

// 发起逆地址解析请求
[TMMSearchManager queryReGeocodeWithRequest:request
						completion:^(TMMSearchReGeocodeResponse * _Nullable response,
 												        NSError * _Nullable error) {

 }];
```

### 关键词检索

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
				    completion:^(TMMSearchSuggestionResponse * _Nullable response,
 												     NSError * _Nullable error) {

 }];
```