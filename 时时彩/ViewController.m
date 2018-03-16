//
//  ViewController.m
//  时时彩
//
//  Created by hongchen on 2018/3/13.
//  Copyright © 2018年 hongchen. All rights reserved.
//

#import "ViewController.h"
#import "CSYAwardTable.h"
#import "CSYResaultTable.h"
#import "CSYDataModel.h"

@interface ViewController()
{
    /** 每次验证 */
    __block int evertTime;
}

/** 验证期数 */
@property (weak) IBOutlet NSTextField *VerificationTxt;
/** 校验期数 */
@property (weak) IBOutlet NSTextField *checkTxt;
/** 随机注数 */
@property (weak) IBOutlet NSTextField *arcNumberTxt;

/** 连对单选框 */
@property (weak) IBOutlet NSButton *coreectRadio;
 /** 连错单选框 */
@property (weak) IBOutlet NSButton *errorRadio;
/** 当前验证状态（true(连对)/(false(连错)） */
@property (assign,nonatomic) BOOL selectVerification;

/** 开奖表格 */
@property (weak) IBOutlet CSYAwardTable *dataTable;
/** 验证结果表格 */
@property (weak) IBOutlet CSYResaultTable *resaultTable;

/** 存放开奖数据 */
@property (strong,nonatomic) NSMutableArray * dataArrs;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /** 初始化请求 */
    [self initWithRequest];

}


#pragma mark - 初始化请求
/** 初始化请求 */
-(void)initWithRequest {
    
    NSString * url = @"http://1685582.com/Result/GetLotteryResultList?gameID=40&pageSize=30&pageIndex=1&";
    int arcUri = arc4random()%199999999+1000000;
    url=[url stringByAppendingFormat:@"%d",arcUri];
    
    
    //    DLog(@"%@",url);
    
    [CSYRequest requestGetUrl:url paramters:nil cookie:nil success:^(NSURLSessionDataTask * _Nonnull task, NSData *data) {
        
        NSDictionary * json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        
        
        if ([CSYIsNull isNull:json[@"list"]]) return ;
        
        for (NSDictionary * obj in json[@"list"]){
            [self.dataArrs addObject:obj];
        }
        
        _dataArrs = [NSMutableArray arrayWithArray:[[_dataArrs reverseObjectEnumerator] allObjects]];
        
        _dataTable.dataArr = [NSArray arrayWithArray:_dataArrs];
        [_dataTable reloadData];
        [_dataTable scrollRowToVisible:[_dataArrs count]];
        
    } error:^(NSError *err) {
        
        
        DLog(@"%@",err);
    }];
    
    
}


/** 响应开始验证 */
- (IBAction)startVerification:(id)sender {
    
    /** 倒数第几期开始验证 */
    int verificationNumber = [_VerificationTxt.stringValue intValue];
    verificationNumber == 0 ? verificationNumber = 1 : verificationNumber;
    
    /** 每次验证期数 */
    evertTime = [_checkTxt.stringValue intValue];
    evertTime == 0 ? evertTime = 3 : evertTime;
    
    while (verificationNumber > 0) {
        
        [self verificationverificationNumber:verificationNumber evertNumber:evertTime complete:^(BOOL isCoreer) {
            
        }];
        
    }
    
}


/** 响应连错被选中 */
- (IBAction)error:(id)sender {
    
    [sender setState:1];
    [_coreectRadio setState:0];
    _selectVerification = false;
    
}

/** 响应连对被选中 */
- (IBAction)coreect:(id)sender {
    
    [sender setState:0];
    [_errorRadio setState:1];
    _selectVerification = true;
    
}




#pragma mark - 兑奖号码生成
/**
 验证开奖结果

 @param verificationNumber 倒数第几期开始验证
 @param evertNumber 每次验证的期数
 @param complete 返回结果
 */
-(void)verificationverificationNumber:(int)verificationNumber  evertNumber:(int)evertNumber complete:(void(^)(BOOL isCoreer))complete{
    
    
    /** 当前验证次数 */
    __block int  currentCount=0;
    
    /** 倒数第几期开始验证 */
    __block int count2 = verificationNumber;
    count2 == 0 ? count2 = 1 : count2;
    
    /** 初始化中奖结果数组 */
    NSMutableArray * resaultNumberArrs = [NSMutableArray new];
    
    while (currentCount < evertNumber) {
        
        CSYDataModel * model = [CSYDataModel mj_objectWithKeyValues:_dataArrs[_dataArrs.count - count2]];
        
        DLog(@"number = %@",model.result);
        
        /** 每次随机的注数 */
        int arcNumber = [_arcNumberTxt.stringValue intValue];
        arcNumber == 0 ? arcNumber = 50 : arcNumber;
        
        [self verifictionNumber:50 query:model.result count:currentCount block:^(BOOL isOk,NSMutableArray * numArrs) {
            
            if (isOk) { //验证期数中有一期符合查询条件，则初始化
                
                currentCount = 0;
                count2 = 4;
                
            }else {
                
                currentCount++;
                count2--;
            }
            
            if (numArrs.count) {
                
                DLog(@"result = %@",numArrs);
               BOOL isCorrect =  [self queryWinningNumber:model.result queryArr:numArrs];
                
                if (isCorrect) { // 当中奖结果存在
                    
                    [resaultNumberArrs addObject:@{@"resault":@"中"}];
                } else {
                    
                    [resaultNumberArrs addObject:@{@"resault":@"没中"}];
                }
                
                _resaultTable.dataArr = [NSArray arrayWithArray:resaultNumberArrs];
                [_resaultTable reloadData];
                
            }
        }];
    }
}

/**
 验证开奖号码

 @param number 还要查询次数
 @param queryStr 要查询的开奖号
 @param count 已经查询次数
 @param complete 返回结果
 */
-(void)verifictionNumber:(int)number query:(NSString *)queryStr count:(int)count block:(void(^)(BOOL isOk,NSMutableArray * numArrs))complete {
    
    [self arcNumber:number block:^(BOOL isOk, NSMutableArray *numArrs) {
        
        BOOL isCorrect = [self queryWinningNumber:queryStr queryArr:numArrs];
        
        if (_selectVerification) { // 如果选择连对方法验证
            
            if (isCorrect){ // 如果中奖号再这个数组中
                
                //                        DLog(@"%@",deleteArrs.firstObject);
                
                complete(true,nil);
                if (count == evertTime-1) {
                    [self arcNumber:number block:^(BOOL isOk, NSMutableArray *numArrs) {
                        
                        complete(true,numArrs);
                    }];
                    
                }
                return;
            }
            
            
        } else { // 否则先把连错
            
            if (!isCorrect){  // 如果中奖号不在这个数组中
                
                //                        DLog(@"%@",deleteArrs.firstObject);
                
                complete(true,nil);
                if (count == evertTime-1) {
                    [self arcNumber:number block:^(BOOL isOk, NSMutableArray *numArrs) {
                        
                        complete(true,numArrs);
                    }];
                    
                }
                return;
            }
            
        }
        
        complete(false,nil);
        
    }];
    
}



/**
  查询中奖号码

 @param queryString 要查询的奖号
 @param toArray 被查询的数组
 resault bool 返回结果
 */
-(BOOL)queryWinningNumber:(NSString *)queryString  queryArr:(NSArray *)toArray{
    
    NSArray * queryArr = [queryString componentsSeparatedByString:@","];
    
    queryString = [NSString stringWithFormat:@"%@%@",queryArr[queryArr.count -2],queryArr.lastObject];
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS %@",queryString];
    
    NSMutableArray * deleteArrs = [NSMutableArray arrayWithArray:toArray];
    [deleteArrs filterUsingPredicate:predicate];
    
    if ([deleteArrs count] > 0) {
        
        return true;
    }else {
        
        return false;
    }
    
}

/**
 随机生成 N 注开奖号

 @param number 已经验证过开奖号的次数
 @param complete 返回随机出来的开奖号
 */
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
