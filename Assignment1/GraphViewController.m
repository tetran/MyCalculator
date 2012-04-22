//
//  GraphViewController.m
//  RPNCalculator
//
//  Created by Kaneshige Koichi on 12/04/15.
//  Copyright (c) 2012年 P&W Solutions Co., Ltd. All rights reserved.
//

#import "GraphViewController.h"
#import "GraphView.h"
#import "CalculatorBrain.h"

@interface GraphViewController () <GraphViewDataSource>
@property (nonatomic, weak) IBOutlet GraphView *graphView;
@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;
@end

@implementation GraphViewController

@synthesize graphView = _graphView;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;
@synthesize toolbar = _toolbar;
@synthesize program = _program;

- (void)setProgram:(id)program {
    _program = program;
    [self.graphView setNeedsDisplay];
}

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem {
    if (_splitViewBarButtonItem != splitViewBarButtonItem) {
        NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
        if (_splitViewBarButtonItem) {
            [toolbarItems removeObject:_splitViewBarButtonItem];
        }
        if (splitViewBarButtonItem) {
            [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
        }
        self.toolbar.items = toolbarItems;
        _splitViewBarButtonItem = splitViewBarButtonItem;
    }
}

- (void)setGraphView:(GraphView *)graphView {
    _graphView = graphView;
    
    [self.graphView addGestureRecognizer:[[UIPinchGestureRecognizer alloc]initWithTarget:self.graphView action:@selector(pinch:)]];
    [self.graphView addGestureRecognizer:[[UIPanGestureRecognizer alloc]initWithTarget:self.graphView action:@selector(pan:)]];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults stringForKey:@"origin"]) {
        self.graphView.origin = CGPointFromString([userDefaults stringForKey:@"origin"]);
    } else {
        CGPoint midPoint;
        midPoint.x = self.graphView.bounds.origin.x + self.graphView.bounds.size.width/2;
        midPoint.y = self.graphView.bounds.origin.y + self.graphView.bounds.size.height/2;
        self.graphView.origin = midPoint;
    }
    if ([userDefaults floatForKey:@"scale"]) {
        self.graphView.scale = [userDefaults floatForKey:@"scale"];
    } 
    self.graphView.dataSource = self;
}

- (CGFloat)valueOfYForX:(CGFloat)x {
    NSMutableDictionary *variableValues = [[NSMutableDictionary alloc] init];
    [variableValues setValue:[NSNumber numberWithFloat:x] forKey:@"x"];
    return [CalculatorBrain runProgram:self.program usingVariableValues:[variableValues copy]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

- (void)viewWillDisappear:(BOOL)animated {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:NSStringFromCGPoint(self.graphView.origin) forKey:@"origin"];
    [userDefaults setFloat:self.graphView.scale forKey:@"scale"];
}

@end
