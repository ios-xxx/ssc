//
//  CSYPopViewController.m
//  财猫
//
//  Created by hongchen on 2018/3/24.
//  Copyright © 2018年 hongchen. All rights reserved.
//

#import "CSYPopViewController.h"

@interface CSYPopViewController ()

@end

@implementation CSYPopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

-(void)awakeFromNib {
    [self.view setWantsLayer:true];
    [self.view.layer setBackgroundColor:[NSColor colorWithRed:0 green:0 blue:0 alpha:0].CGColor];
    
   
}

@end
