//
//  CSYRequest.m
//  cat
//
//  Created by hongchen on 2018/2/24.
//  Copyright © 2018年 hongchen. All rights reserved.
//

#import "CSYRequest.h"

@implementation CSYRequest

/**
 初始化 GET 請求

 @param url 请求
 @param par 参数
 @param success 请求成功
 @param err 请求出错
 */
+(void)requestGetUrl:( NSString *)url paramters:(NSDictionary *)par cookie:(void(^)(AFHTTPSessionManager * manger))cookie success:(void(^)(NSURLSessionDataTask * _Nonnull task,NSData *data))success error:(void(^)(NSError * err))err {
    
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects: @"application/json", @"text/json", @"text/javascript",@"text/html",@"application/text", nil];
    
    if (cookie != nil) {
        
        cookie(manager);
    }
    
    
    [manager GET:url parameters:par progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
   
        if (success == nil) return;
        success(task,responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (err == nil) return ;
        err(error);
        
    }];
    
    
}

/**
 初始化 POST 請求
 
 @param url 请求
 @param par 参数
 @param success 请求成功
 @param err 请求出错
 */
+(void)requestPostUrl:( NSString *)url paramters:(NSDictionary *)par  cookie:(void(^)(AFHTTPSessionManager * manger))cookie success:(void(^)(NSURLSessionDataTask * _Nonnull task,NSData *data))success error:(void(^)(NSError * err))err {
    
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects: @"application/json", @"text/json", @"text/javascript",@"text/html",@"application/text", nil];
    
    if (cookie != nil) {
        
        cookie(manager);
    }
    
    [manager POST:url parameters:par progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (success == nil) return;
        success(task,responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (err == nil) return ;
        err(error);
        
    }];
    
    
}
@end
