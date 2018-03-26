//
//  CSYWKWebview.m
//  时时彩
//
//  Created by hongchen on 2018/3/19.
//  Copyright © 2018年 hongchen. All rights reserved.
//

#import "CSYWKWebview.h"

@interface CSYWKWebview()<WKUIDelegate,WKNavigationDelegate>

@end
@implementation CSYWKWebview

-(void)awakeFromNib {
    self.UIDelegate = self;
    self.navigationDelegate = self;
    [self loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://1685582.com/?1521981927196"]]];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notification:) name:@"message" object:nil];
}


/** 响应通知 */
-(void)notification:(NSNotification *)sender {
    
    NSString * number =[sender object];
    
    NSString * script = [NSString stringWithFormat:@"document.getElementsByClassName('selector-con clear')[0].children[0].value=%@;document.getElementsByClassName('btn add-btn')[0].onclick(); document.getElementsByClassName('btn deter-btn')[0].onclick();",number];
    
    
    [self evaluateJavaScript:script completionHandler:nil];
}

@end
