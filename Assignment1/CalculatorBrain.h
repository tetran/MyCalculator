//
//  CalculatorBrain.h
//  Assignment1
//
//  Created by Kaneshige Koichi on 12/04/01.
//  Copyright (c) 2012年 P&W Solutions Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject

- (void)pushOperand:(double)operand;
- (double)performOperation:(NSString *)operation;

- (void)clear;

@property (readonly) id program;

+ (double)runProgram:(id)program;
+ (NSString *)descriptionOfProgram:(id)program;

@end
