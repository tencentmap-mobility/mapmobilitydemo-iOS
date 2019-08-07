//
//  ReplaceUnicode.h
//  TNKNavigationDebugging
//
//  Created by Yuchen Wang on 2019/4/2.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface ReplaceUnicode : NSObject

// 改变unicode到中文
+ (NSString *)replaceUnicode:(NSString *)unicodeStr;

@end

