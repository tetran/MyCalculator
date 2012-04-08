//
//  CalculatorViewController.m
//  Assignment1
//
//  Created by Kaneshige Koichi on 12/04/01.
//  Copyright (c) 2012年 P&W Solutions Co., Ltd. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"

@interface CalculatorViewController ()
@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic) BOOL userAlreadyEnteredFloatingPoint;
@property (nonatomic, strong) CalculatorBrain *brain;
@property (strong, nonatomic) NSMutableDictionary *testVariableValues;
@end

@implementation CalculatorViewController

@synthesize display = _display;
@synthesize subDisplay = _subDisplay;
@synthesize variableDisplay = _variableDisplay;
@synthesize userIsInTheMiddleOfEnteringANumber= _userIsInTheMiddleOfEnteringANumber;
@synthesize userAlreadyEnteredFloatingPoint = _userAlreadyEnterdFloatingPoint;
@synthesize brain = _brain;
@synthesize testVariableValues = _testVariableValues;

- (CalculatorBrain *)brain {
    if (!_brain) {
        _brain = [[CalculatorBrain alloc] init];
    }
    return _brain;
}

- (NSMutableDictionary *)testVariableValues {
    if (!_testVariableValues) {
        _testVariableValues = [[NSMutableDictionary alloc] init];
    }
    return _testVariableValues;
}

- (void)updateVariableDisplay {
    NSSet *variables = [CalculatorBrain variablesUsedInProgram:self.brain.program];
    NSMutableString *display = [NSMutableString stringWithString:@""];
    for (id variable in variables) {
        id variableValue = [self.testVariableValues objectForKey:variable];
        if (variableValue) {
            [display appendFormat:@"  %@ %@ %@", variable, @"=", variableValue];
        }
    }
    self.variableDisplay.text = display;
}

- (IBAction)digitPressed:(UIButton *)sender {
    NSString *digit = [sender currentTitle];
    if (self.userIsInTheMiddleOfEnteringANumber) {
        // avoid input of duplicate floating points
        if ([digit isEqualToString:@"."]) {
            if (self.userAlreadyEnteredFloatingPoint) {
                return;   
            } else {
                self.userAlreadyEnteredFloatingPoint = YES;
            }
        }
        self.display.text = [self.display.text stringByAppendingString:digit];
    } else {
        self.display.text = digit;
        self.userIsInTheMiddleOfEnteringANumber = YES;
        if ([digit isEqualToString:@"."]) {
            self.userAlreadyEnteredFloatingPoint = YES;
        }
    }
    [self updateVariableDisplay];
}

- (NSString *)latestExpressionOfProgram {
    NSArray *comp = [[CalculatorBrain descriptionOfProgram:self.brain.program] componentsSeparatedByString:@", "];
    if (![comp count]) {
        return nil;
    }
    return [comp objectAtIndex:0];
}

- (IBAction)enterPressed {
    [self.brain pushOperand:[self.display.text doubleValue]];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.userAlreadyEnteredFloatingPoint = NO;
    self.subDisplay.text = [self latestExpressionOfProgram];
    
    [self updateVariableDisplay];
}


- (IBAction)operationPressed:(id)sender {
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    
    NSString *operation = [sender currentTitle];
    // double result = [self.brain performOperation:operation];
    [self.brain pushOperation:operation];
    double result = [CalculatorBrain runProgram:self.brain.program usingVariableValues:[self.testVariableValues copy]];
    self.display.text = [NSString stringWithFormat:@"%g", result];
    self.subDisplay.text = [self latestExpressionOfProgram];
    
    [self updateVariableDisplay];
}

- (IBAction)clearPressed {
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.userAlreadyEnteredFloatingPoint = NO;
    self.display.text = @"0";
    self.subDisplay.text = @"";
    [self.brain clear];
    
    [self updateVariableDisplay];
}

- (IBAction)variablePressed:(UIButton *)sender {
    [self.brain pushVariable:[sender currentTitle]];
    
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.userAlreadyEnteredFloatingPoint = NO;
    self.subDisplay.text = [self latestExpressionOfProgram];
    
    [self updateVariableDisplay];
}

- (IBAction)testPressed:(UIButton *)sender {
    NSString *title = [sender currentTitle];
    if ([title isEqualToString:@"test1"]) {
        [self.testVariableValues setObject:[NSNumber numberWithDouble:3] forKey:@"x"];
        [self.testVariableValues setObject:[NSNumber numberWithDouble:2.43] forKey:@"a"];
        [self.testVariableValues setObject:[NSNumber numberWithDouble:-4] forKey:@"b"];
    } else if ([title isEqualToString:@"test2"]) {
        self.testVariableValues = nil;
    } else if ([title isEqualToString:@"test3"]) {
        [self.testVariableValues setObject:[NSNumber numberWithDouble:0] forKey:@"x"];
        [self.testVariableValues setObject:[NSNumber numberWithDouble:999999999999999999] forKey:@"a"];
        [self.testVariableValues setObject:[NSNumber numberWithDouble:-999999999999999999] forKey:@"b"];
    }
    
    [self updateVariableDisplay];
}

- (IBAction)undoPressed {
    [self.brain undo];
    
}

- (void)viewDidUnload {
    [self setSubDisplay:nil];
    [self setVariableDisplay:nil];
    [super viewDidUnload];
}
@end
