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
@synthesize expression = _expression;
@synthesize program = _program;


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
    self.graphView.dataSource = self;
}

- (CGFloat)valueOfYForX:(CGFloat)x {
    NSMutableDictionary *variableValues = [[NSMutableDictionary alloc] init];
    [variableValues setValue:[NSNumber numberWithFloat:x] forKey:@"x"];
    return [CalculatorBrain runProgram:self.program usingVariableValues:[variableValues copy]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
}


@end
