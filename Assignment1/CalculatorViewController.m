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
@synthesize userIsInTheMiddleOfEnteringANumber= _userIsInTheMiddleOfEnteringANumber;
@synthesize userAlreadyEnteredFloatingPoint = _userAlreadyEnterdFloatingPoint;
@synthesize brain = _brain;
@synthesize testVariableValues = _testVariableValues;

- (void)setUpLabel {
    [[self.display layer] setCornerRadius:6.0];
    [self.display setClipsToBounds:YES];
    [[self.subDisplay layer] setCornerRadius:6.0];
    [self.subDisplay setClipsToBounds:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpLabel];
}

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

- (void)updateDisplayWith:(double)value {
    NSString *valueString = [NSString stringWithFormat:@"%g", value];
    if (20 < valueString.length) {
        valueString = [NSString stringWithFormat:@"%e", value];
    }
    self.display.text = valueString;
}

- (IBAction)digitPressed:(UIButton *)sender {
    NSString *digit = [sender currentTitle];
    if (self.userIsInTheMiddleOfEnteringANumber) {
        if (20 <= self.display.text.length) {
            return;
        }
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
}

- (IBAction)operationPressed:(id)sender {
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    
    if ([self.brain.program count]) {
        NSString *operation = [sender currentTitle];
        [self.brain pushOperation:operation];
        double result = [CalculatorBrain runProgram:self.brain.program usingVariableValues:[self.testVariableValues copy]];
        [self updateDisplayWith:result];
        self.subDisplay.text = [self latestExpressionOfProgram];    
    }
}

- (IBAction)specialVariablePressed:(id)sender {
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    
    NSString *operation = [sender currentTitle];
    [self.brain pushOperation:operation];
    double result = [CalculatorBrain runProgram:self.brain.program usingVariableValues:[self.testVariableValues copy]];
    [self updateDisplayWith:result];
    self.subDisplay.text = [self latestExpressionOfProgram];    
}

- (IBAction)clearPressed {
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.userAlreadyEnteredFloatingPoint = NO;
    self.display.text = @"0";
    self.subDisplay.text = @"";
    [self.brain clear];
}

- (IBAction)variablePressed:(UIButton *)sender {
    [self.brain pushVariable:[sender currentTitle]];
    
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.userAlreadyEnteredFloatingPoint = NO;
    self.subDisplay.text = [self latestExpressionOfProgram];
}

- (void)reCulculate {
    double result = [CalculatorBrain runProgram:self.brain.program usingVariableValues:[self.testVariableValues copy]];
    [self updateDisplayWith:result];
    self.subDisplay.text = [self latestExpressionOfProgram];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.userAlreadyEnteredFloatingPoint = NO;
}


- (IBAction)undoPressed {
    if (!self.userIsInTheMiddleOfEnteringANumber) {
        if (![self.brain.program count]) return;
        [self.brain undo];
    }
    [self reCulculate];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowGraph"]) {
        NSLog(@"%@", @"prepareForSegue called");
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
}

- (void)viewDidUnload {
    [self setSubDisplay:nil];
    [self setDisplay:nil];
    [super viewDidUnload];
}
@end
