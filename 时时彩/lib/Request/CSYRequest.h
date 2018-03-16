//
//  CSYRequest.h
//  cat
//
//  Created by hongchen on 2018/2/24.
//  Copyright © 2018年 hongchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSYRequest : NSObject
/**
 初始化 GET 請求
 
 @param url 请求
 @param par 参数
 @param success 请求成功
 @param err 请求出错
 */
+(void)requestGetUrl:( NSString *)url paramters:(NSDictionary *)par  cookie:(void(^)(AFHTTPSessionManager * manger))cookie success:(void(^)(NSURLSessionDataTask * _Nonnull task,NSData *data))success error:(void(^)(NSError * err))err;
/**
 初始化 POST 請求
 
 @param url 请求
 @param par 参数
 @param success 请求成功
 @param err 请求出错
 */
+(void)requestPostUrl:( NSString *)url  paramters:(NSDictionary *)par  cookie:(void(^)(AFHTTPSessionManager * manger))cookie success:(void(^)(NSURLSessionDataTask * _Nonnull task,NSData *data))success error:(void(^)(NSError * err))err;
@end
