//
//  CSYAutoProperty.m
//  自动生成属性代码
//
//  Created by hong chen on 2017/9/8.
//  Copyright © 2017年 hong chen. All rights reserved.
//

#import "CSYAutoProperty.h"

@implementation CSYAutoProperty

/** 通过字典生成属性创建代码 */
+(void)DictionaryCreaterPropertyCode:(NSDictionary *)dict {
    
    //  遍历字典
    NSMutableString * propertys = [NSMutableString string];
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        NSString * propertyStr;
        if ([obj isKindOfClass:[NSString class]]) {
            
            propertyStr = [NSString stringWithFormat:@"@property (strong,nonatomic) %@ * %@;",[key classForCoder],key];
            
        }else if ([obj isKindOfClass:NSClassFromString(@"__NSCFBoolean")]) {
            
            propertyStr = [NSString stringWithFormat:@"@property (assign,nonatomic) BOOL   %@;",key];
            
        }else if ([obj isKindOfClass:[NSNumber class]]){
            
            propertyStr = [NSString stringWithFormat:@"@property (strong,nonatomic) NSNumber * %@;",key];
            
            /*
             if ([@"__NSCFBoolean" isEqualToString: (NSString *)[obj class]]) {
             
             propertyStr = [NSString stringWithFormat:@"@property (strong,nonatomic) Bool  %@;",key];
             }
             */
            
        }else if ([obj isKindOfClass:[NSArray class]]){
            
            propertyStr = [NSString stringWithFormat:@"@property (strong,nonatomic) NSArray * %@;",key];
            
        }else if ([obj isKindOfClass:[NSDictionary class]]){
            
            propertyStr = [NSString stringWithFormat:@"@property (strong,nonatomic) NSDictionary * %@;",key];
            
        }else if ([obj isKindOfClass:[NSDate class]]){
            
            propertyStr = [NSString stringWithFormat:@"@property (strong,nonatomic) NSDate * %@;",key];
        }
        NSLog(@"%@",[obj class]);
        
        //  拼接Code
        [propertys appendFormat:@"/** <#注释#> */\n%@\n\n",propertyStr];
    }];
    NSLog(@"\n\n%@",propertys);
}
@end
