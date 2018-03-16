//
//  ViewController.m
//  时时彩
//
//  Created by hongchen on 2018/3/13.
//  Copyright © 2018年 hongchen. All rights reserved.
//

#import "ViewController.h"
#import "CSYDataModel.h"

@interface ViewController()

/** 存放开奖数据 */
@property (strong,nonatomic) NSMutableArray * dataArrs;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSString * url = @"http://1685582.com/Result/GetLotteryResultList?gameID=40&pageSize=30&pageIndex=1&";
    int arcUri = arc4random()%199999999+1000000;
    url=[url stringByAppendingFormat:@"%d",arcUri];
    
    
    DLog(@"%@",url);
    
    [CSYRequest requestGetUrl:url paramters:nil cookie:nil success:^(NSURLSessionDataTask * _Nonnull task, NSData *data) {
        
        NSDictionary * json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        
        
        if ([CSYIsNull isNull:json[@"list"]]) return ;
        
        for (NSDictionary * obj in json[@"list"]){
            [self.dataArrs addObject:obj];
        }
        
        _dataArrs = [NSMutableArray arrayWithArray:[[_dataArrs reverseObjectEnumerator] allObjects]];
        
        
        /** 验证期数 */
        __block int count=0;
        
        /** 倒数第几期开始验证 */
        __block int count2 = 4;
        
        while (count < 3) {
            
            CSYDataModel * model = [CSYDataModel mj_objectWithKeyValues:_dataArrs[_dataArrs.count - count2]];
            
            DLog(@"number = %@",model.result);
            [self verifictionNumber:50 query:model.result count:count block:^(BOOL isOk,NSMutableArray * numArrs) {

                if (isOk) { //验证期数中有一期正确则初始化
                    
                    count = 0;
                    count2 = 4;
                    
                }else {
                    
                    count++;
                    count2--;
                }

                if (numArrs.count) {

                    DLog(@"result = %@",numArrs);
                }

            }];
        }
       

    } error:^(NSError *err) {
      
        
        DLog(@"%@",err);
    }];
//    [self arcNumber:50];
   
    // Do any additional setup after loading the view.
}

// 验证开奖号码
-(void)verifictionNumber:(int)number query:(NSString *)queryStr count:(int)count block:(void(^)(BOOL isOk,NSMutableArray * numArrs))complete {
    
    [self arcNumber:number block:^(BOOL isOk, NSMutableArray *numArrs) {
        
        NSArray * queryArr = [queryStr componentsSeparatedByString:@","];
        
        NSString * queryString = [NSString stringWithFormat:@"%@%@",queryArr[queryArr.count -2],queryArr.lastObject];
        
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS %@",queryString];
        
        NSMutableArray * deleteArrs = [NSMutableArray arrayWithArray:numArrs];
        [deleteArrs filterUsingPredicate:predicate];
        
        if (deleteArrs.count < 1){
            
//                        DLog(@"%@",deleteArrs.firstObject);
            
            complete(false,nil);
            if (count == 2) {
                [self arcNumber:number block:^(BOOL isOk, NSMutableArray *numArrs) {
                    
                    complete(false,numArrs);
                }];
                
            }
            return;
        }
        
        complete(true,nil);
        
        
        
    }];
    
}


-(void)arcNumber:(int)number block:(void(^)(BOOL isOk,NSMutableArray * numArrs))complete {
    
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        
        NSMutableArray * numArrs = [NSMutableArray new];
        
        while ([numArrs count] < number) {
            
            int num = arc4random()%99+0;
            NSString * numStr;
            
            if (num < 10) {
                numStr = [NSString stringWithFormat:@"0%d",num];
            }else {
                numStr = [NSString stringWithFormat:@"%d",num];
            }
            
            NSMutableArray * deteleArrs = [NSMutableArray arrayWithArray:numArrs];
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS %@",numStr];
            [deteleArrs filterUsingPredicate:predicate];
            //
            if ([deteleArrs count] > 0) {
                
                [numArrs removeObject:deteleArrs.firstObject];
                [deteleArrs removeAllObjects];
            }
            
            [numArrs addObject:numStr];
            
        }
        
        complete(false,numArrs);
        
    });
    
}
- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


#pragma mark - 初始化全局属性
-(NSMutableArray *)dataArrs {
    
    if (_dataArrs) return _dataArrs;
    
    return _dataArrs = [NSMutableArray new];
}


@end
