//
//  GraphView.m
//  RPNCalculator
//
//  Created by Kaneshige Koichi on 12/04/15.
//  Copyright (c) 2012年 P&W Solutions Co., Ltd. All rights reserved.
//

#import "GraphView.h"
#import "AxesDrawer.h"

#define DEFAULT_SCALE 10

@interface GraphView()
@end

@implementation GraphView

@synthesize scale = _scale, origin = _origin;
@synthesize dataSource = _dataSource;


- (CGFloat)scale {
    if (!_scale) {
        return DEFAULT_SCALE;
    } else {
        return _scale;
    }
}

- (void)setScale:(CGFloat)scale {
    if (_scale != scale) {
        _scale = scale;
    }
    [self setNeedsDisplay];
}

- (CGPoint)origin {
    return _origin;
}

- (void)setOrigin:(CGPoint)origin {
    _origin = origin;
    [self setNeedsDisplay];
}

- (void)setUp {
    self.contentMode = UIViewContentModeRedraw;
}

- (void)awakeFromNib {
    [self setUp];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    NSLog(@"origin is %@", NSStringFromCGPoint(self.origin));
    [AxesDrawer drawAxesInRect:rect originAtPoint:self.origin scale:self.scale];
}


@end
