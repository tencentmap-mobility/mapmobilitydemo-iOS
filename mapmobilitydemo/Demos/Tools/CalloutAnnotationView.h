//
//  calloutAnnotationView.h
//  TencentMapLocusSynchroDemo
//
//  Created by Yuchen Wang on 2020/3/23.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <QMapKit/QMapKit.h>
#import <QMapKit/QAnnotationView.h>
NS_ASSUME_NONNULL_BEGIN

@interface CalloutAnnotationView : QAnnotationView

@property (nonatomic, strong) NSString *callloutText;

@end

NS_ASSUME_NONNULL_END
