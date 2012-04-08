//
//  CalculatorBrain.m
//  Assignment1
//
//  Created by Kaneshige Koichi on 12/04/01.
//  Copyright (c) 2012年 P&W Solutions Co., Ltd. All rights reserved.
//

#import "CalculatorBrain.h"

typedef enum {
    DOUBLE_OPERAND_OPERATION = 0,
    SINGLE_OPERAND_OPERATION = 1,
    VALUE = 2,
    VARIABLE
} TypeOfProgramElement;

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

- (void)pushOperation:(NSString *)operation {
    [self.programStack addObject:operation];
}

- (void)pushVariable:(NSString *)variable {
    [self.programStack addObject:variable];
}

- (id)program {
    return [self.programStack mutableCopy];
}

+ (TypeOfProgramElement) elementTypeOf:(id)programElement {
    if (programElement == nil) {
        return -1;
    }
    
    static NSSet *singleOperandOperations;
    if (singleOperandOperations == nil) {
        singleOperandOperations = [[NSMutableSet alloc] initWithObjects:@"sqrt", @"sin", @"cos", nil];
    }
    
    static NSSet *doubleOperandOperations;
    if (doubleOperandOperations == nil) {
        doubleOperandOperations = [[NSSet alloc] initWithObjects:@"+", @"-", @"*", @"/", nil];
    }
    
    if ([singleOperandOperations containsObject:programElement]) {
        return SINGLE_OPERAND_OPERATION;
    } else if ([doubleOperandOperations containsObject:programElement]) {
        return DOUBLE_OPERAND_OPERATION;
    } else if ([programElement isKindOfClass:[NSNumber class]]) {
        return VALUE;
    } else {
        return VARIABLE;
    }
}

+ (NSMutableString *)wrapByParentheses:(id)element {
    return [NSMutableString stringWithFormat:@"%@%@%@", @"(", element, @")"];
}

/*
 * 最も外側の括弧を削除することを目的としている。
 * が、現状動かない。
 */
+ (void)removeParentheses:(NSMutableString *)description {
    static NSRegularExpression *regExp;
    if (regExp == nil) {
        NSString *pattern = [NSString stringWithFormat:@"%@%@%@%@%@", @"^", [NSRegularExpression escapedPatternForString:@"("], @"(.*)", [NSRegularExpression escapedPatternForString:@")"], @"$"];
        regExp = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    }
    NSMutableString *string = [NSMutableString stringWithString:@"(hello)"];
    [regExp replaceMatchesInString:string options:0 range:NSMakeRange(0, [string length]) withTemplate:@"$0"];
    NSLog(@"%@", string);
    
    [regExp replaceMatchesInString:description options:0 range:NSMakeRange(0, [description length]) withTemplate:@"$0"];
}

+ (NSString *)descriptionOfTopOfStack:(NSMutableArray *)stack {
    id topOfStack = [stack lastObject];
    if (topOfStack) {
        [stack removeLastObject];
    }
    
    NSMutableString *result = [[NSMutableString alloc] init];
    
    TypeOfProgramElement element = [self elementTypeOf:topOfStack];
    if (element == VALUE || element == VARIABLE) {
        [result appendString:[topOfStack description]];
    } else if (element == SINGLE_OPERAND_OPERATION) {
        [result appendString:[NSString stringWithFormat:@"%@%@%@%@", topOfStack, @"(", [self descriptionOfTopOfStack:stack], @")"]];
    } else if (element == DOUBLE_OPERAND_OPERATION) {
        NSString *prev = [self descriptionOfTopOfStack:stack];
        NSString *prev2 = [self descriptionOfTopOfStack:stack];
        [result appendString:[NSString stringWithFormat:@"%@ %@ %@", prev2, topOfStack, prev]];
        result = [self wrapByParentheses:result];
    } else {
        return nil;
    }
    
    [self removeParentheses:result];
    
    return result;
}

+ (NSString *)descriptionOfProgram:(id)program {
    NSMutableArray *stack;
    NSString *result;
    if ([program isKindOfClass:[NSArray class]]) {
        NSString *aResult;
        stack = [program mutableCopy];
        while ((aResult = [self descriptionOfTopOfStack:stack])) {
            if (!result) {
                result = aResult;
            } else {
                result = [NSString stringWithFormat:@"%@%@%@", result, @", ", aResult];            
            }
        }
    }
    
    return result;
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
    NSLog(@"%@", program);
    NSLog(@"%@", [self descriptionOfProgram:program]);

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
        id programElement = [stack objectAtIndex:i];
        if ([self elementTypeOf:programElement] == VARIABLE) {
            id variableValue = [variableValues objectForKey:programElement];
            if (variableValue == nil) {
                variableValue = [NSNumber numberWithDouble:0];
            }
            [stack replaceObjectAtIndex:i withObject:variableValue];
        }
    }
    
    return [self popOperandOffStack:stack];
}

+ (NSSet *)variablesUsedInProgram:(id)program {
    NSMutableSet *result;
    if ([program isKindOfClass:[NSArray class]]) {
        result = [[NSMutableSet alloc] init];
        for (id elem in program) {
            if ([elem isKindOfClass:[NSString class]] 
                    && [self elementTypeOf:elem] == VARIABLE) {
                [result addObject:elem];
            }
        }
    }
    return [result copy];
}

- (void)undo {
    [self.programStack removeLastObject];
}

- (void)clear {
    self.programStack = [[NSMutableArray alloc] init];
}

@end
