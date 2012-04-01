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
@property (nonatomic) BOOL userAlreadyEnterdFloatingPoint;
@property (nonatomic, strong) CalculatorBrain *brain;
@end

@implementation CalculatorViewController

@synthesize display = _display;
@synthesize userIsInTheMiddleOfEnteringANumber= _userIsInTheMiddleOfEnteringANumber;
@synthesize userAlreadyEnterdFloatingPoint = _userAlreadyEnterdFloatingPoint;
@synthesize brain = _brain;

- (CalculatorBrain *)brain {
    if (!_brain) {
        _brain = [[CalculatorBrain alloc] init];
    }
    return _brain;
}

- (IBAction)digitPressed:(UIButton *)sender {
    NSString *digit = [sender currentTitle];
    if (self.userIsInTheMiddleOfEnteringANumber) {
        // avoid input of duplicate floating points
        if ([digit isEqualToString:@"."]) {
            if (self.userAlreadyEnterdFloatingPoint) {
                return;   
            } else {
                self.userAlreadyEnterdFloatingPoint = YES;
            }
        }
        self.display.text = [self.display.text stringByAppendingString:digit];
    } else {
        self.display.text = digit;
        self.userIsInTheMiddleOfEnteringANumber = YES;
        if ([digit isEqualToString:@"."]) {
            self.userAlreadyEnterdFloatingPoint = YES;
        }
    }
}


- (IBAction)enterPressed {
    [self.brain pushOperand:[self.display.text doubleValue]];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.userAlreadyEnterdFloatingPoint = NO;
}


- (IBAction)operationPressed:(id)sender {
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    
    NSString *operation = [sender currentTitle];
    double result = [self.brain performOperation:operation];
    self.display.text = [NSString stringWithFormat:@"%g", result];
}
@end
