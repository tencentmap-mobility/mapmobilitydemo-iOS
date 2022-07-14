//
//  TLSLogger.h
//  TLSLocusSynchroDubugging
//
//  Created by 薛程 on 2018/11/2.
//  Copyright © 2018年 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 * @brief 日志管理类
 */
@interface TLSBLogger : NSObject

+ (instancetype)sharedInstance;

- (void)setDebugSwith:(BOOL)on;

@end
