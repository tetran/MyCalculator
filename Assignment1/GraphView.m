//
//  GraphView.m
//  RPNCalculator
//
//  Created by Kaneshige Koichi on 12/04/15.
//  Copyright (c) 2012年 P&W Solutions Co., Ltd. All rights reserved.
//

#import "GraphView.h"
#import "AxesDrawer.h"

#define DEFAULT_SCALE 1

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
        [self setNeedsDisplay];
    }
}

- (void)setOrigin:(CGPoint)origin {
    _origin = origin;
    [self setNeedsDisplay];
}

- (void)setUp {
    self.contentMode = UIViewContentModeRedraw;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setUp];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

// reset scale when pinching
- (void)pinch:(UIPinchGestureRecognizer *)gesture {
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) {
        self.scale *= gesture.scale;
        gesture.scale = 1;
    }
}

- (void)pan:(UIPanGestureRecognizer *)gesture {
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) {
        CGPoint translation = [gesture translationInView:self];
        self.origin = CGPointMake(self.origin.x + translation.x, self.origin.y + translation.y);
        [gesture setTranslation:CGPointZero inView:self];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *aTouch = [touches anyObject];
    if (aTouch.tapCount == 2 || aTouch.tapCount == 3) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *aTouch = [touches anyObject];
    if (aTouch.tapCount == 3) {
        self.origin = [aTouch locationInView:self];
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    static int NumberOfPoints;
    if (!NumberOfPoints) {
        NumberOfPoints = self.bounds.size.width * self.contentScaleFactor;
    }
    
    CGFloat scale = self.scale;
    
    CGFloat step = 1 / scale / self.contentScaleFactor;
    CGFloat leftEndX = -self.origin.x/scale;
    
    CGPoint points[NumberOfPoints];
    CGFloat x;
    int count;
    for (x = leftEndX, count = 0; count < NumberOfPoints; x += step, count++) {
        CGFloat xValue = self.origin.x + x*scale;
        CGFloat yValue = self.origin.y - [self.dataSource valueOfYForX:x]*scale;
        points[count] = CGPointMake(xValue, yValue);
    }
    
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(currentContext, 2.0);
    CGContextSetRGBStrokeColor(currentContext, 1, 0.6, 0, 1);
    CGContextAddLines(currentContext, points, NumberOfPoints);
    CGContextStrokePath(currentContext);
    
    CGContextSetLineWidth(currentContext, 1.0);
    CGContextSetRGBStrokeColor(currentContext, 0, 0, 0, 1);
    [AxesDrawer drawAxesInRect:rect originAtPoint:self.origin scale:scale];
}

@end
