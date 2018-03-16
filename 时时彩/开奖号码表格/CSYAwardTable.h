//
//  CSYAwardTable.h
//  时时彩
//
//  Created by hongchen on 2018/3/16.
//  Copyright © 2018年 hongchen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CSYAwardTable : NSTableView<NSTableViewDelegate,NSTableViewDataSource>
/** 开奖数据 */
@property (strong,nonatomic) NSArray * dataArr;
@end
