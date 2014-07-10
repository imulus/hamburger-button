//
//  HamburgerButton.m
//  Hamburger Button
//
//  Created by Bryce Hammond on 7/9/14.
//  Copyright (c) 2014 Robert Böhnke. All rights reserved.
//

#import "HamburgerButton.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>


@interface CALayer (OCBApplyAnimation)

- (void)ocb_applyAnimation:(CABasicAnimation *)animation;

@end

@implementation CALayer (OCBApplyAnimation)
    
- (void)ocb_applyAnimation:(CABasicAnimation *)animation
{
    CABasicAnimation *copy = animation.copy;
    if(nil == copy.fromValue)
    {
        copy.fromValue = [self.presentationLayer valueForKeyPath:copy.keyPath];
    }
    
    [self addAnimation:copy forKey:copy.keyPath];
    [self setValue:copy.toValue forKey:copy.keyPath];
}

@end

@interface HamburgerButton ()

@property (nonatomic, strong) CAShapeLayer *top;
@property (nonatomic, strong) CAShapeLayer *bottom;
@property (nonatomic, strong) CAShapeLayer *middle;

@end

@implementation HamburgerButton

#define MENU_STROKE_START 0.325
#define MENU_STROKE_END 0.9
#define HAMBURGER_STROKE_START 0.028
#define HAMBURGER_STROKE_END 0.111

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupButton];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    [self setupButton];
    
    return self;
}

- (void)setupButton
{
    self.top = [[CAShapeLayer alloc] init];
    CGPathRef shortStroke = [self createShortStroke];
    self.top.path = shortStroke;
    CGPathRelease(shortStroke);
    
    self.middle = [[CAShapeLayer alloc] init];
    CGPathRef outline = [self createOutline];
    self.middle.path = outline;
    CGPathRelease(outline);
    
    self.bottom = [[CAShapeLayer alloc] init];
    shortStroke = [self createShortStroke];
    self.bottom.path = shortStroke;
    CGPathRelease(shortStroke);
    
    for(CAShapeLayer *layer in @[ self.top, self.middle, self.bottom ])
    {
        layer.fillColor = nil;
        layer.strokeColor = [[UIColor whiteColor] CGColor];
        layer.lineWidth = 4;
        layer.miterLimit = 4;
        layer.lineCap = kCALineCapRound;
        layer.masksToBounds = YES;
        CGPathRef strokingPath = CGPathCreateCopyByStrokingPath(layer.path, nil, 4,
                                                                kCGLineCapRound, kCGLineJoinMiter, 4);
        layer.bounds = CGPathGetPathBoundingBox(strokingPath);
        
        CGPathRelease(strokingPath);
        
        layer.actions = @{ @"strokeStart" : [NSNull null],
                           @"strokeEnd" : [NSNull null],
                           @"transform" : [NSNull null] };
        
        [self.layer addSublayer:layer];
        
    }
    
    self.top.anchorPoint = CGPointMake(28.0 / 30.0, 0.5);
    self.top.position = CGPointMake(40, 18);
    
    self.middle.position = CGPointMake(27, 27);
    self.middle.strokeStart = HAMBURGER_STROKE_START;
    self.middle.strokeEnd = HAMBURGER_STROKE_END;
    
    self.bottom.anchorPoint = CGPointMake(28.0 / 30.0, 0.5);
    self.bottom.position = CGPointMake(40, 36);
    
    _showsMenu = NO;
}


- (void)setShowsMenu:(BOOL)showsMenu
{
    _showsMenu = showsMenu;
    
    CABasicAnimation *strokeStart = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    CABasicAnimation *strokeEnd = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    
    if(self.showsMenu)
    {
        strokeStart.toValue = @(MENU_STROKE_START);
        strokeStart.duration = 0.5;
        strokeStart.timingFunction = [[CAMediaTimingFunction alloc] initWithControlPoints:0.25 :-0.4 :0.5 :1];
        
        strokeEnd.toValue = @(MENU_STROKE_END);
        strokeEnd.duration = 0.6;
        strokeEnd.timingFunction = [[CAMediaTimingFunction alloc] initWithControlPoints:0.25 :-0.4 :0.5 :1];
    }
    else
    {
        strokeStart.toValue = @(HAMBURGER_STROKE_START);
        strokeStart.duration = 0.5;
        strokeStart.timingFunction = [[CAMediaTimingFunction alloc] initWithControlPoints:0.25 :0 :0.5 :1.2];
        strokeStart.beginTime = CACurrentMediaTime() + 0.1;
        strokeStart.fillMode = kCAFillModeBackwards;
        
        strokeEnd.toValue = @(HAMBURGER_STROKE_END);
        strokeEnd.duration = 0.6;
        strokeEnd.timingFunction = [[CAMediaTimingFunction alloc] initWithControlPoints:0.25 :0.3 :0.5 :0.9];
    }
    
    [self.middle ocb_applyAnimation:strokeStart];
    [self.middle ocb_applyAnimation:strokeEnd];
    
    CABasicAnimation *topTransform = [CABasicAnimation animationWithKeyPath:@"transform"];
    topTransform.timingFunction = [[CAMediaTimingFunction alloc] initWithControlPoints:0.5 :-0.8 :0.5 :1.85];
    topTransform.duration = 0.4;
    topTransform.fillMode = kCAFillModeBackwards;
    
    CABasicAnimation *bottomTransform = topTransform.copy;
    
    if(self.showsMenu)
    {
        CATransform3D translation = CATransform3DMakeTranslation(-4, 0, 0);
        
        topTransform.toValue = [NSValue valueWithCATransform3D:CATransform3DRotate(translation, -0.7853975, 0, 0, 1)];
        topTransform.beginTime = CACurrentMediaTime() + 0.25;
        
        bottomTransform.toValue = [NSValue valueWithCATransform3D:CATransform3DRotate(translation, 0.7853975, 0, 0, 1)];
        bottomTransform.beginTime = CACurrentMediaTime() + 0.25;
    }
    else
    {
        topTransform.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
        topTransform.beginTime = CACurrentMediaTime() + 0.05;
        
        bottomTransform.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
        bottomTransform.beginTime = CACurrentMediaTime() + 0.05;
    }
    
    [self.top ocb_applyAnimation:topTransform];
    [self.bottom ocb_applyAnimation:bottomTransform];
    
}

- (CGMutablePathRef)createShortStroke
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, 2, 2);
    CGPathAddLineToPoint(path, nil, 28, 2);
    
    return path;
}

- (CGMutablePathRef)createOutline
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, 10, 27);
    CGPathAddCurveToPoint(path, nil, 12.00, 27.00, 28.02, 27.00, 40, 27);
    CGPathAddCurveToPoint(path, nil, 55.92, 27.00, 50.47,  2.00, 27,  2);
    CGPathAddCurveToPoint(path, nil, 13.16,  2.00,  2.00, 13.16,  2, 27);
    CGPathAddCurveToPoint(path, nil,  2.00, 40.84, 13.16, 52.00, 27, 52);
    CGPathAddCurveToPoint(path, nil, 40.84, 52.00, 52.00, 40.84, 52, 27);
    CGPathAddCurveToPoint(path, nil, 52.00, 13.16, 42.39,  2.00, 27,  2);
    CGPathAddCurveToPoint(path, nil, 13.16,  2.00,  2.00, 13.16,  2, 27);
    
    return path;
}




@end
