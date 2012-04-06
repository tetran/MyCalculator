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
@end

@implementation CalculatorViewController

@synthesize display = _display;
@synthesize subDisplay = _subDisplay;
@synthesize userIsInTheMiddleOfEnteringANumber= _userIsInTheMiddleOfEnteringANumber;
@synthesize userAlreadyEnteredFloatingPoint = _userAlreadyEnterdFloatingPoint;
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

#define MAX_TEXT_LENGTH_IN_SUBDISPLAY 30

// TODO history表示ポリシーについては再考の余地がある
- (void)updateSubDisplayText:(NSString *)aText clearWhenOverflowing:(BOOL) clearWhenOverflowing {
    if (clearWhenOverflowing 
            && MAX_TEXT_LENGTH_IN_SUBDISPLAY < self.subDisplay.text.length + aText.length) {
        self.subDisplay.text = aText;
    } else {
        self.subDisplay.text = [self.subDisplay.text stringByAppendingFormat:@" %@", aText];   
    }
}

- (IBAction)enterPressed {
    [self.brain pushOperand:[self.display.text doubleValue]];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.userAlreadyEnteredFloatingPoint = NO;
    [self updateSubDisplayText:self.display.text clearWhenOverflowing:YES];
}


- (IBAction)operationPressed:(id)sender {
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    
    NSString *operation = [sender currentTitle];
    double result = [self.brain performOperation:operation];
    self.display.text = [NSString stringWithFormat:@"%g", result];
    [self updateSubDisplayText:operation clearWhenOverflowing:NO];
}

- (IBAction)clearPressed {
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.userAlreadyEnteredFloatingPoint = NO;
    self.display.text = @"0";
    self.subDisplay.text = @"";
    [self.brain clear];
}

- (void)viewDidUnload {
    [self setSubDisplay:nil];
    [super viewDidUnload];
}
@end
