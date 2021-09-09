//
//  JSONSerializer.m
//  TencentMapLocusSynchroDemo
//
//  Created by mol on 2021/9/8.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "JSONSerializer.h"

@implementation JSONSerializer

+ (NSData *)dataWithDictionary:(NSDictionary *)dict {
    if(!dict) {
        return nil;
    }
    
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:&error];
    if(error) {
        return nil;
    }
    
    return data;
}

+ (NSDictionary *)dictionaryWithData:(NSData *)data {
    
    if(data.length == 0) {
        return nil;
    }
    
    NSError *error;
    NSData  *utf8Data  = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic  = [NSJSONSerialization JSONObjectWithData:utf8Data
                                                        options:NSJSONReadingMutableContainers
                                                          error:&error];
    if(error) {
        return nil;
    }
    
    return dic;
}

@end
