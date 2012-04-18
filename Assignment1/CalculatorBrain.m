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
    DIGIT = 2,
    VARIABLE = 3,
    NO_OPERAND_OPERATION = 4
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
    
    static NSSet *specialVariables;
    if (specialVariables == nil) {
        specialVariables = [[NSSet alloc] initWithObjects:@"π", nil];
    }
    
    if ([singleOperandOperations containsObject:programElement]) {
        return SINGLE_OPERAND_OPERATION;
    } else if ([doubleOperandOperations containsObject:programElement]) {
        return DOUBLE_OPERAND_OPERATION;
    } else if ([specialVariables containsObject:programElement]) {
        return NO_OPERAND_OPERATION;
    } else if ([programElement isKindOfClass:[NSNumber class]]) {
        return DIGIT;
    } else {
        return VARIABLE;
    }
}

+ (NSMutableString *)wrapByParentheses:(id)element {
    return [NSMutableString stringWithFormat:@"%@%@%@", @"(", element, @")"];
}

/*
 * 最も外側の括弧を削除する
 */
+ (NSString *)removeOutmostParenthesesFromText:(NSString *)text {
    if ([text characterAtIndex:0] == '(' &&
        [text characterAtIndex:text.length - 1] == ')') {
        return [text substringWithRange:NSMakeRange(1, text.length - 2)];
    } else {
        return text;
    }
    
    /*
    static NSRegularExpression *regExp;
    if (regExp == nil) {
        NSString *pattern = [NSString stringWithFormat:@"%@%@%@%@%@", @"^", [NSRegularExpression escapedPatternForString:@"("], @"(.*)", [NSRegularExpression escapedPatternForString:@")"], @"$"];
        regExp = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    }
    
    NSTextCheckingResult *match = [regExp firstMatchInString:text options:0 range:NSMakeRange(0, text.length)];
    if (match.numberOfRanges) {
        return [text substringWithRange:[match rangeAtIndex:1]];
    } else {
        return text;
    }
     */
}

+ (NSString *)descriptionOfTopOfStack:(NSMutableArray *)stack {
    id topOfStack = [stack lastObject];
    if (topOfStack) {
        [stack removeLastObject];
    }
    
    NSMutableString *result = [[NSMutableString alloc] init];
    
    TypeOfProgramElement element = [self elementTypeOf:topOfStack];
    
    if (element == DIGIT || element == VARIABLE || element == NO_OPERAND_OPERATION) {
        [result appendString:[topOfStack description]];
    } else if (element == SINGLE_OPERAND_OPERATION) {
        id tmp = [self descriptionOfTopOfStack:stack];
        if (tmp != nil) {
            if ([tmp isKindOfClass:[NSMutableString class]]) {
                tmp = [self removeOutmostParenthesesFromText:tmp];
            }
            [result appendString:[NSString stringWithFormat:@"%@%@%@%@", topOfStack, @"(", tmp, @")"]];
        }
    } else if (element == DOUBLE_OPERAND_OPERATION) {
        NSString *prev = [self descriptionOfTopOfStack:stack];
        NSString *prev2 = [self descriptionOfTopOfStack:stack];
        if (prev != nil && prev2 != nil) {
            [result appendString:[NSString stringWithFormat:@"%@ %@ %@", prev2, topOfStack, prev]];
            result = [self wrapByParentheses:result];
        }
    } else {
        return nil;
    }
        
    return result;
}

+ (NSString *)descriptionOfProgram:(id)program {
    NSMutableArray *stack;
    NSString *result;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
        NSString *aResult;
        while ((aResult = [self descriptionOfTopOfStack:stack]) && aResult.length) {
            aResult = [self removeOutmostParenthesesFromText:aResult];
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
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    return [self popOperandOffStack:stack];
}

+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues {
    NSLog(@"program is %@, with variable %@", program, variableValues);
    
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    
    for (int i = 0; i < stack.count; i++) {
        id programElement = [stack objectAtIndex:i];
        NSLog(@"program element is %@", programElement);
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
