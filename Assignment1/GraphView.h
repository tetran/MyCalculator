//
//  GraphView.h
//  RPNCalculator
//
//  Created by Kaneshige Koichi on 12/04/15.
//  Copyright (c) 2012年 P&W Solutions Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GraphView;

@protocol GraphViewDataSource
- (CGFloat)valueOfYForX:(CGFloat)x;
@end


@interface GraphView : UIView

@property (nonatomic) CGFloat scale;
@property (nonatomic) CGPoint origin;

@property (nonatomic, weak) IBOutlet id<GraphViewDataSource> dataSource;

@end
