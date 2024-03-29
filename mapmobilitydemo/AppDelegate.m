//
//  AppDelegate.m
//  mapmobilitydemo
//
//  Created by mol on 2019/8/3.
//  Copyright © 2019 tencent. All rights reserved.
//

#import "AppDelegate.h"
#import "EntryViewController.h"

#import <TNKNavigationKit/TNKNaviServices.h>
#import <QMapKit/QMapServices.h>
#import "Constants.h"
#import <TencentMapMobilitySDK/TencentMapMobilitySDK.h>
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // 设置地图Key
    [QMapServices sharedServices].APIKey = kMapKey;
    // 用户同意隐私接口，不设置为YES则不能正常使用地图。 隐私政策官网: https://lbs.qq.com/userAgreements/agreements/privacy
    [[QMapServices sharedServices] setPrivacyAgreement:YES];
    
    // 设置导航Key
    [TNKNaviServices sharedServices].APIKey = kMapKey;
    // 用户同意隐私接口，不设置为YES则不能正常使用地图。 隐私政策官网: https://lbs.qq.com/userAgreements/agreements/privacy
    [[TNKNaviServices sharedServices] setPrivacyAgreement:YES];
    
    [TMMServices sharedServices].apiKey = kMobilityKey;
    // 如果配置了secretKey需要设置secretKey
    [TMMServices sharedServices].secretKey = kMobilitySecretKey;
    EntryViewController *entry = [[EntryViewController alloc] init];
    
    NSString *idfv = [UIDevice currentDevice].identifierForVendor.UUIDString;
    NSLog(@"idfv=%@",idfv);
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:entry];
    self.window.rootViewController = navigationController;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
