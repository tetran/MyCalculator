//
//  LabelWithPadding.m
//  RPNCalculator
//
//  Created by Kaneshige Koichi on 12/04/15.
//  Copyright (c) 2012年 P&W Solutions Co., Ltd. All rights reserved.
//

#import "LabelWithPadding.h"

@implementation LabelWithPadding

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 5, 0, 5);
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
