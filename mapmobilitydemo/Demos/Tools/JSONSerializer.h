//
//  JSONSerializer.h
//  TencentMapLocusSynchroDemo
//
//  Created by mol on 2021/9/8.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JSONSerializer : NSObject

+ (NSData *)dataWithDictionary:(NSDictionary *)dict;

+ (NSDictionary *)dictionaryWithData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
