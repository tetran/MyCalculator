//
//  GraphViewController.m
//  RPNCalculator
//
//  Created by Kaneshige Koichi on 12/04/15.
//  Copyright (c) 2012年 P&W Solutions Co., Ltd. All rights reserved.
//

#import "GraphViewController.h"
#import "GraphView.h"

@interface GraphViewController () <GraphViewDataSource>
@property (nonatomic, weak) IBOutlet GraphView *graphView;
@end

@implementation GraphViewController

@synthesize graphView = _graphView;


- (void)setGraphView:(GraphView *)graphView {
    _graphView = graphView;
    
    self.graphView.dataSource = self;
}

- (CGFloat)valueOfYForX:(CGFloat)x {
    return 0;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

@end
