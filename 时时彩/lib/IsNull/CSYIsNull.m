//
//  CSYIsNull.m
//  clubSchool
//
//  Created by hongchen on 2017/12/22.
//  Copyright © 2017年 Camel. All rights reserved.
//

#import "CSYIsNull.h"

@implementation CSYIsNull

/** 判断是否为空 */
+(BOOL)isNull:(id)object {
    
    
    if ([object isKindOfClass:[NSArray class]]) {
        
       NSArray * tmpArr = [NSArray arrayWithArray:object];
        if (tmpArr.count < 1) return true;
        else return false;
        
    }else if ([object isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary * tmpDict = [NSDictionary dictionaryWithDictionary:object];
        if (tmpDict.count < 1) return true;
        else return false;
        
    }
    
    if ([object isEqual:[NSNull new]] || object == nil) {
        return true;
    }
    return false;
}

@end
