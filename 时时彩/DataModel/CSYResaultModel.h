//
//  CSYResaultModel.h
//  时时彩
//
//  Created by hongchen on 2018/3/17.
//  Copyright © 2018年 hongchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSYResaultModel : NSObject
/** 中奖结果 */
@property (strong,nonatomic) NSString * resault;
/** 本期赢利 */
@property (strong,nonatomic) NSString * profit;
/** 总赢利 */
@property (strong,nonatomic) NSString * totalProfit;
@end
