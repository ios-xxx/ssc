//
//  NSTextFieldCellCenter.m
//  cat
//
//  Created by hongchen on 2018/2/24.
//  Copyright © 2018年 hongchen. All rights reserved.
//

#import "NSTextFieldCellCenter.h"

@implementation NSTextFieldCellCenter

-(instancetype)initWithCoder:(NSCoder *)coder {
    
    if ([super initWithCoder:coder]) {
        
        _cFlags.vCentered = 1;
//        _cFlags.hCentered = 1;
    }
    
    return self;
}

-(instancetype)init {
    
    if ([super init]) {
        
        _cFlags.vCentered = 1;
//        _cFlags.hCentered = 1;
    }
    return self;
}

@end
