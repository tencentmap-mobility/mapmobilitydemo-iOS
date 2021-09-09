//
//  KCOrderManager.m
//  TencentMapLocusSynchroDemo
//
//  Created by mol on 2021/9/8.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "KCOrderManager.h"
#import "JSONSerializer.h"
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCrypto.h>
#import "Constants.h"

NSString * const kOrderSyncURL = @"https://apis.map.qq.com/ws/tls/v1/order/sync";

@implementation MyPOI

@end

@implementation KCMyOrder

@end

@interface KCOrderManager ()

@property (nonatomic, strong) NSURLSession *urlSession;

@end

@implementation KCOrderManager


static id _instance;

// 单例
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}


- (instancetype)init {
    self = [super init];
    
    if (self) {
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.timeoutIntervalForRequest = 5.0f;
        config.timeoutIntervalForResource = 5.0f;
        self.urlSession = [NSURLSession sessionWithConfiguration:config];
    }
    
    return self;
}

- (void)dealloc {
    [self.urlSession finishTasksAndInvalidate];
}

/// 创建订单
/// @param order 订单对象
/// @param completion 返回结果
- (void)createOrder:(KCMyOrder *)order completion:(void(^)(BOOL success, NSError * _Nullable error))completion {
       
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    bodyDict[@"orderid"] = order.orderID;
    bodyDict[@"reqid"] = [NSUUID UUID].UUIDString;
    bodyDict[@"reqtime"] = @((long long)([[NSDate date] timeIntervalSince1970]));
    bodyDict[@"uptime"] = @((long long)([[NSDate date] timeIntervalSince1970]));
    bodyDict[@"userid"] = order.passengerID;
    bodyDict[@"userdev"] =  [[UIDevice currentDevice] identifierForVendor].UUIDString;
    bodyDict[@"user_lnglat"] = [NSString stringWithFormat:@"%.6f,%.6f", order.startPOI.coord.longitude, order.startPOI.coord.latitude];
    bodyDict[@"getin_lnglat"] = [NSString stringWithFormat:@"%.6f,%.6f", order.startPOI.coord.longitude, order.startPOI.coord.latitude];
    bodyDict[@"getin_poiname"] = order.startPOI.poiName ?: @"未知";
    
    bodyDict[@"getoff_poiid"] = order.endPOI.poiID ?: @"1";
    bodyDict[@"getoff_lnglat"] = [NSString stringWithFormat:@"%.6f,%.6f", order.endPOI.coord.longitude, order.endPOI.coord.latitude];
    bodyDict[@"getoff_poiname"] = order.endPOI.poiName ?: @"未知";

    bodyDict[@"business_type"] = @(1);
    bodyDict[@"type"] = @(1);
    
    bodyDict[@"city"] = order.adCode;
    
    // 初始状态
    bodyDict[@"status"] = @(1);
    
    bodyDict[@"key"] = kSynchroKey;
    bodyDict[@"cartype"] = (0);
    
    bodyDict[@"driverid"] = order.driverID ?: @"";
    bodyDict[@"driverdev"] = order.driverDev ?: @"";
    bodyDict[@"driver_lnglat"] = [NSString stringWithFormat:@"%.6f,%.6f", order.startPOI.coord.longitude, order.startPOI.coord.latitude];

    
    [self sendOrderSyncRequestWithParams:bodyDict completion:completion];
}


/// 创建订单后，派单给司机，状态切换至接驾
/// @param order 订单对象
/// @param driverID 司机id
/// @param driverDev 司机设备号
/// @param driverCoord 司机接单时的位置
/// @param completion 返回结果
- (void)sendOrderToDriver:(KCMyOrder *)order
                 driverID:(NSString * _Nullable)driverID
                driverDev:(NSString * _Nullable)driverDev
              driverCoord:(CLLocationCoordinate2D)driverCoord
               completion:(void(^)(BOOL success, NSError * _Nullable error))completion {
    
    order.orderStatus = TLSBOrderStatusPickup;
    order.driverID = driverID;
    order.driverDev = driverDev;

    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    bodyDict[@"orderid"] = order.orderID;
    bodyDict[@"reqid"] = [NSUUID UUID].UUIDString;
    bodyDict[@"reqtime"] = @((long long)([[NSDate date] timeIntervalSince1970]));
    bodyDict[@"uptime"] = @((long long)([[NSDate date] timeIntervalSince1970]));
    bodyDict[@"userid"] = order.passengerID;
    bodyDict[@"userdev"] =  [[UIDevice currentDevice] identifierForVendor].UUIDString;
    bodyDict[@"user_lnglat"] = [NSString stringWithFormat:@"%.6f,%.6f", order.startPOI.coord.longitude, order.startPOI.coord.latitude];
    bodyDict[@"getin_lnglat"] = [NSString stringWithFormat:@"%.6f,%.6f", order.startPOI.coord.longitude, order.startPOI.coord.latitude];
    bodyDict[@"getin_poiname"] = order.startPOI.poiName ?: @"未知";
    
    bodyDict[@"getoff_poiid"] = order.endPOI.poiID ?: @"1";
    bodyDict[@"getoff_lnglat"] = [NSString stringWithFormat:@"%.6f,%.6f", order.endPOI.coord.longitude, order.endPOI.coord.latitude];
    bodyDict[@"getoff_poiname"] = order.endPOI.poiName ?: @"未知";

    bodyDict[@"business_type"] = @(1);
    bodyDict[@"type"] = @(1);
    
    bodyDict[@"city"] = order.adCode;
    
    // 接驾状态
    bodyDict[@"status"] = @(2);
    
    bodyDict[@"key"] = kSynchroKey;
    bodyDict[@"cartype"] = (0);
    
    bodyDict[@"driverid"] = order.driverID;
    bodyDict[@"driverdev"] = order.driverDev;
    bodyDict[@"driver_lnglat"] = [NSString stringWithFormat:@"%.6f,%.6f", driverCoord.longitude, driverCoord.latitude];
    
    
    [self sendOrderSyncRequestWithParams:bodyDict completion:completion];

}


/// 流转订单状态至送驾
/// @param order 订单对象
/// @param driverCoord 司机当前位置
/// @param completion 返回结果
- (void)changeOrderStatusToTrip:(KCMyOrder *)order
                    driverCoord:(CLLocationCoordinate2D)driverCoord
                     completion:(void(^)(BOOL success, NSError * _Nullable error))completion {
    
    order.orderStatus = TLSBOrderStatusTrip;

    
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    bodyDict[@"orderid"] = order.orderID;
    bodyDict[@"reqid"] = [NSUUID UUID].UUIDString;
    bodyDict[@"reqtime"] = @((long long)([[NSDate date] timeIntervalSince1970]));
    bodyDict[@"uptime"] = @((long long)([[NSDate date] timeIntervalSince1970]));
    bodyDict[@"userid"] = order.passengerID;
    bodyDict[@"userdev"] =  [[UIDevice currentDevice] identifierForVendor].UUIDString;
    bodyDict[@"user_lnglat"] = [NSString stringWithFormat:@"%.6f,%.6f", order.startPOI.coord.longitude, order.startPOI.coord.latitude];
    bodyDict[@"getin_lnglat"] = [NSString stringWithFormat:@"%.6f,%.6f", order.startPOI.coord.longitude, order.startPOI.coord.latitude];
    bodyDict[@"getin_poiname"] = order.startPOI.poiName ?: @"未知";
    bodyDict[@"real_getin_lnglat"] = [NSString stringWithFormat:@"%.6f,%.6f", driverCoord.longitude, driverCoord.latitude];
    bodyDict[@"real_getin_time"] = @((long long)([[NSDate date] timeIntervalSince1970]));
    
    bodyDict[@"getoff_poiid"] = order.endPOI.poiID ?: @"1";
    bodyDict[@"getoff_lnglat"] = [NSString stringWithFormat:@"%.6f,%.6f", order.endPOI.coord.longitude, order.endPOI.coord.latitude];
    bodyDict[@"getoff_poiname"] = order.endPOI.poiName ?: @"未知";

    bodyDict[@"business_type"] = @(1);
    bodyDict[@"type"] = @(1);
    
    bodyDict[@"city"] = order.adCode;
    
    // 初始状态
    bodyDict[@"status"] = @(3);
    
    bodyDict[@"key"] = kSynchroKey;
    bodyDict[@"cartype"] = (0);
    
    bodyDict[@"driverid"] = order.driverID;
    bodyDict[@"driverdev"] = order.driverDev;
    bodyDict[@"driver_lnglat"] = [NSString stringWithFormat:@"%.6f,%.6f", driverCoord.longitude, driverCoord.latitude];

    [self sendOrderSyncRequestWithParams:bodyDict completion:completion];
}

- (void)sendOrderSyncRequestWithParams:(NSDictionary *)params completion:(void(^)(BOOL success, NSError * _Nullable error))completion {
    
    NSData *data = [JSONSerializer dataWithDictionary:params];
    NSURL *syncURL = [NSURL URLWithString:kOrderSyncURL];
    
    NSString *sign = [self signWithURL:syncURL originalParams:params];
    
    if (sign.length > 0) {
        syncURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?sig=%@", kOrderSyncURL, sign]];
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:syncURL];

    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:data];
    
    NSURLSessionDataTask *task = [self.urlSession dataTaskWithRequest:request
                                                    completionHandler:^(NSData * _Nullable data,
                                                                        NSURLResponse * _Nullable response,
                                                                        NSError * _Nullable error) {
                
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (error)  {
                if (completion)  {
                    completion(NO, error);
                }
            } else {
                
                NSDictionary *responseDict = [JSONSerializer dictionaryWithData:data];
                if (responseDict.count > 0 && [responseDict[@"status"] intValue] == 0) {
                    if (completion)  {
                        completion(YES, nil);
                    }
                } else {
                    
                    int status = [responseDict[@"status"] intValue];
                    NSString *msg = responseDict[@"message"] ?: @"";
                    NSError *error = [NSError errorWithDomain:@"OrderDomain" code:status userInfo:@{NSLocalizedDescriptionKey : msg}];
                    
                    if (completion)  {
                        completion(NO, error);
                    }
                }
                
            }
        });
        
    }];
    
    [task resume];
}


#pragma mark - private

- (NSString *)signWithURL:(NSURL *)url originalParams:(NSDictionary *)params {
    
    NSString *sk = kSynchroSecretKey;
    if (sk.length == 0) {
        // 不需要签名
        return nil;
    }
    
    // 需要签名
    NSString *urlPath = [url path];
    
    NSArray *sortedKeys = [params.allKeys sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:nil ascending:YES]]];
    NSMutableString *signParamsString = [NSMutableString string];
    for (int i = 0; i < sortedKeys.count; i++) {
        
        NSString *key = sortedKeys[i];
        if (i != 0) {
            [signParamsString appendString:@"&"];
        }
        
        [signParamsString appendFormat:@"%@=%@", key, params[key]];
    }
    NSString *valueString = [NSString stringWithFormat:@"%@?%@%@", urlPath, signParamsString, sk];
    NSString *sign = [self md5WithString:valueString].lowercaseString;
    
    return sign;
}

- (NSString *)md5WithString:(NSString *)text {
    // Create pointer to the string as UTF8
    const char *ptr = [text UTF8String];
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(ptr, (CC_LONG)strlen(ptr), md5Buffer);
    // Convert MD5 value in the buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    return output;
}

@end
