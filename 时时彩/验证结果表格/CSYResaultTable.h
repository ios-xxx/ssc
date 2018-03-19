//
//  CSYResaultTable.h
//  时时彩
//
//  Created by hongchen on 2018/3/17.
//  Copyright © 2018年 hongchen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CSYResaultTable : NSTableView<NSTableViewDelegate,NSTableViewDataSource>
/** 开奖结果数据 */
@property (strong,nonatomic) NSMutableArray * dataArrs;
@end
