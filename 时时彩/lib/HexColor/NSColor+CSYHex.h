//
//  UIColor+CSYHex.h
//  Club
//
//  Created by im on 16/8/2.
//  Copyright © 2016年 camel. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSColor (CSYHex)

+ (NSColor *)colorWithHexString:(NSString *)color;

//从十六进制字符串获取颜色，
//color:支持@“#123456”、 @“0X123456”、 @“123456”三种格式
+ (NSColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;
@end
