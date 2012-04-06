//
//  CalculatorBrain.m
//  Assignment1
//
//  Created by Kaneshige Koichi on 12/04/01.
//  Copyright (c) 2012年 P&W Solutions Co., Ltd. All rights reserved.
//

#import "CalculatorBrain.h"

typedef enum {
    DOUBLE_OPERAND = 0,
    SINGLE_OPERAND = 1,
    VALUE_OR_VAR = 2
} TypeOfCurrentProgram;

@interface CalculatorBrain()
@property (nonatomic, strong) NSMutableArray *programStack;
@end

@implementation CalculatorBrain

@synthesize programStack = _programStack;

- (NSMutableArray *)programStack {
    if (!_programStack) {
        _programStack = [[NSMutableArray alloc] init];
    }
    return _programStack;
}

- (void)pushOperand:(double)operand {
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}

- (double)performOperation:(NSString *)operation {
    [self.programStack addObject:operation];
    return [CalculatorBrain runProgram:self.program];
}

- (id)program {
    return [self.programStack copy];
}

+ (TypeOfCurrentProgram) typeOfProgram:(NSString *)program {
    static NSSet *singleOperandOperations;
    if (singleOperandOperations == nil) {
        NSMutableSet *tmp = [[NSMutableSet alloc] init];
        [tmp addObject:@"sqrt"];
        [tmp addObject:@"sin"];
        [tmp addObject:@"cos"];
        singleOperandOperations = [tmp copy];
    }
    
    static NSSet *doubleOperandOperations;
    if (doubleOperandOperations == nil) {
        NSMutableSet *tmp = [[NSMutableSet alloc] init];
        [tmp addObject:@"+"];
        [tmp addObject:@"-"];
        [tmp addObject:@"*"];
        [tmp addObject:@"/"];
        doubleOperandOperations = [tmp copy];
    }
    
    if ([singleOperandOperations containsObject:program]) {
        return SINGLE_OPERAND;
    } else if ([doubleOperandOperations containsObject:program]) {
        return DOUBLE_OPERAND;
    } else {
        return VALUE_OR_VAR;
    }
}

+ (NSString *)descriptionOfTopOfStack:(id)program {
    return @"Implement this in Assignment 2";
}

+ (NSString *) descriptionOfProgram:(id)program {
    return @"Implement this in Assignment 2";
}

+ (double)popOperandOffStack:(NSMutableArray *)stack {
    double result = 0;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) {
        [stack removeLastObject];
    }
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        result = [topOfStack doubleValue];
    }
    else if ([topOfStack isKindOfClass:[NSString class]]) {
        NSString *operation = topOfStack;
        
        if ([operation isEqualToString:@"+"]) {
            result = [self popOperandOffStack:stack] + [self popOperandOffStack:stack];
        } else if ([operation isEqualToString:@"*"]) {
            result = [self popOperandOffStack:stack] * [self popOperandOffStack:stack];
        } else if ([operation isEqualToString:@"-"]) {
            double subtrahend = [self popOperandOffStack:stack];
            result = [self popOperandOffStack:stack] - subtrahend;
        } else if ([operation isEqualToString:@"/"]) {
            double divisor = [self popOperandOffStack:stack];
            if (divisor) {
                result = [self popOperandOffStack:stack] / divisor;
            }
        } else if ([operation isEqualToString:@"sin"]) {
            result = sin([self popOperandOffStack:stack]);
        } else if ([operation isEqualToString:@"cos"]) {
            result = cos([self popOperandOffStack:stack]);
        } else if ([operation isEqualToString:@"sqrt"]) {
            double number = [self popOperandOffStack:stack];
            if (0 < number) {
                result = sqrt(number);
            }
        } else if ([operation isEqualToString:@"π"]) {
            result = M_PI;
        }
    }
    
    return result;
}

+ (double)runProgram:(id)program {
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    return [self popOperandOffStack:stack];
}

+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues {
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    
    for (int i = 0; i < stack.count; i++) {
        id operand = [stack objectAtIndex:i];
        if ([operand isKindOfClass:[NSString class]]) {
            [stack replaceObjectAtIndex:i withObject:[variableValues objectForKey:operand]];
        }
    }
    
    return [self popOperandOffStack:stack];
}

+ (NSSet *)variablesUsedInProgram:(id)program {
    NSMutableSet *result;
    if ([program isKindOfClass:[NSArray class]]) {
        result = [[NSMutableSet alloc] init];
        for (id p in program) {
            if ([p isKindOfClass:[NSString class]]) {
                [result addObject:p];
            }
        }
    }
    return [result copy];
}


- (void)clear {
    self.programStack = [[NSMutableArray alloc] init];
}

@end
