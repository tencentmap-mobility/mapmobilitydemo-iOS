//
//  RouteLocation.h
//  TLSLocusSynchroDubugging
//
//  Created by 薛程 on 2018/11/14.
//  Copyright © 2018年 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QMapSDKUtils/QMUMapUtils.h>

@interface RouteLocation : NSObject <QMULocation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@end
