//
//  CSYMsg.m
//  cat
//
//  Created by hongchen on 2018/3/5.
//  Copyright © 2018年 hongchen. All rights reserved.
//

#import "CSYMsg.h"
#import "CSYMessageView.h"

static   CSYMessageView * msgView;
@interface CSYMsg() {
    
    
    
}

@end

@implementation CSYMsg

/**
 加载定制的提示框

 @param view 要加载到的 View
 */
+(void)msgInView:(NSView *)view {
    
    msgView = [CSYMessageView new];
    msgView.wantsLayer = true;
    msgView.layer.backgroundColor = [NSColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor;
    [msgView.layer setCornerRadius:4];
    [msgView.layer setMasksToBounds:true];
    [view addSubview:msgView];
    
    [msgView makeConstraints:^(MASConstraintMaker *make) {
       
        make.center.equalTo(view);
        make.size.equalTo(CGSizeMake(200, 150));
    }];
}

/** 隐藏提示 View */
+(void)hideMsgView {
    
    [msgView removeFromSuperview];
}


@end
