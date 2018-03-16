//
//  CSYMsg.h
//  cat
//
//  Created by hongchen on 2018/3/5.
//  Copyright © 2018年 hongchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSYMsg : NSObject
/**
 加载定制的提示框
 
 @param view 要加载到的 View
 */
+(void)msgInView:(NSView *)view;

/** 隐藏提示 View */
+(void)hideMsgView;


@end
