//
// Created by TBetts on 10/14/13.
//


#import "DALongPressButtonView.h"

static CGFloat kDistanceToContainerView = 3.0f;
static CGFloat kLineWidthMultiplyer = 0.03f;

@interface DALongPressButtonView()
{
    CAShapeLayer *_circleAnimated;
    UILongPressGestureRecognizer *_longPressGestureRocognizer;
    BOOL _hasInitialized;

    UITableView *_tableView;


    CFTimeInterval _startTime;
    CGFloat _currentStrokeEnd;
}
@end

@implementation DALongPressButtonView

- (void)toggleOnOff
{
    if (self.longPressButtonState == DALongPressButtonStateExpanded)
    {
        [self collapseAnimated:YES];
    }
    self.on = !self.on;
}

- (void)setOn:(BOOL)on
{
    _on = on;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (!_hasInitialized && !CGRectEqualToRect(frame, CGRectZero))
    {
        [self initializeControl];
    }
}

- (void)setLongPressButtonState:(DALongPressButtonState)longPressButtonState {
    _longPressButtonState = longPressButtonState;
    self.frame = (_longPressButtonState == DALongPressButtonStateCollapsed)?self.collapsedFrame:self.expandedFrame;
}


- (void)initializeControl
{
    int radius = self.bounds.size.width / 2;
    
    //self.buttonType = UIButtonTypeCustom;

    self.layer.cornerRadius = radius;
    self.layer.borderColor = [self.borderColor CGColor];
    self.layer.borderWidth = self.bounds.size.width * kLineWidthMultiplyer;
    self.layer.masksToBounds = NO;

    _tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.alpha = (_longPressButtonState == DALongPressButtonStateCollapsed)?0.0f:1.0f;
    _tableView.layer.cornerRadius = radius;

    _tableView.delegate = self.delegate;
    _tableView.dataSource = self.delegate;

    _tableView.layer.masksToBounds = YES;
    
    [self addSubview:_tableView];

    
    _circleAnimated = [CAShapeLayer layer];
    
    _circleAnimated.path = [self generatePathWithRect:CGRectInset(self.bounds, -kDistanceToContainerView, -kDistanceToContainerView)];
    _circleAnimated.position = CGPointMake(-kDistanceToContainerView, -kDistanceToContainerView);
    _circleAnimated.fillColor = [UIColor clearColor].CGColor;
    _circleAnimated.strokeColor = self.borderColor.CGColor;
    _circleAnimated.lineWidth = self.bounds.size.width * kLineWidthMultiplyer;
    _circleAnimated.actions = @{@"strokeEnd" : [NSNull null]};
    
    _longPressGestureRocognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    _longPressGestureRocognizer.minimumPressDuration = 1.6;
    [self addGestureRecognizer:_longPressGestureRocognizer];

    self.userInteractionEnabled = YES;
    _hasInitialized = YES;
}




- (CGPathRef)generatePathWithRect:(CGRect)rect
{
    CGFloat radius = rect.size.width / 2;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddArc(path, nil, radius, radius, radius, -M_PI, -M_PI_2, NO);
    CGPathAddArc(path, nil, radius, radius, radius, -M_PI_2, 0, NO);
    
    CGFloat heightOfStraightSide = rect.size.height - 2 * radius;
    CGPathAddLineToPoint(path, nil, 2 * radius, radius + heightOfStraightSide);
    
    CGPathAddArc(path, nil, radius, radius + heightOfStraightSide, radius, 0, M_PI_2, NO);
    CGPathAddArc(path, nil, radius, radius + heightOfStraightSide, radius, M_PI_2, M_PI, NO);
    
    CGPathAddLineToPoint(path, nil, 0, radius);
    
    return path;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self performSelector:@selector(startLongTapAnimation) withObject:nil afterDelay:0.2];
    self.tintColor = [UIColor blackColor];
    self.layer.borderColor = [UIColor blackColor].CGColor;
}

- (void)startLongTapAnimation
{
    [_circleAnimated removeAllAnimations];
    [self.layer addSublayer:_circleAnimated];
    
    CABasicAnimation *animateCircle = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animateCircle.duration = 1.4f;
    animateCircle.fromValue = @0;
    animateCircle.toValue = @1;
    animateCircle.delegate = self;
    
    [_circleAnimated addAnimation:animateCircle forKey:@"forward"];
    
    _circleAnimated.strokeEnd = 1.0;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self toggleOnOff];
    
    self.tintColor = self.borderColor;
    self.layer.borderColor = self.borderColor.CGColor;
    
    if (_startTime == 0.0f)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                 selector:@selector(startLongTapAnimation) object:nil];
        return;
    }
    
    CFTimeInterval stopTime = [_circleAnimated convertTime:CACurrentMediaTime() fromLayer:nil];
    CFTimeInterval timeOffset = stopTime - _startTime;
    _currentStrokeEnd = timeOffset / 1.4;
    [_circleAnimated removeAllAnimations];
    _circleAnimated.strokeEnd = _currentStrokeEnd;
    
    CABasicAnimation *animateCircle = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animateCircle.duration = 0.7f * _currentStrokeEnd;
    animateCircle.fromValue = @(_currentStrokeEnd);
    animateCircle.toValue = @0;
    
    [_circleAnimated addAnimation:animateCircle forKey:@"backward"];
    _currentStrokeEnd = 0.0f;
    _circleAnimated.strokeEnd = _currentStrokeEnd;
    _startTime = 0.0f;
    
}

- (void)expandAnimated:(BOOL)animated
{
    CGPathRef fromPath  = _circleAnimated.path;
    CGPathRef toPath  = [self generatePathWithRect:CGRectInset(self.expandedFrame, -kDistanceToContainerView, -kDistanceToContainerView)];
    
    CABasicAnimation* animateExpand = [CABasicAnimation animationWithKeyPath: @"path"];
    animateExpand.fromValue = (__bridge id) fromPath;
    animateExpand.toValue = (__bridge id) toPath;
    animateExpand.duration = 0.5;
    animateExpand.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [_circleAnimated addAnimation:animateExpand forKey:@"expand"];
    
    _circleAnimated.path = toPath;
    
    [UIView animateWithDuration:0.5f animations:^{
        self.frame = self.expandedFrame;
        _tableView.alpha = 1.0f;
    }
    completion:^(BOOL finished) {
        self.longPressButtonState = DALongPressButtonStateExpanded;
    }];
}

- (void)collapseAnimated:(BOOL)animated
{
    self.tintColor = self.borderColor;
    self.layer.borderColor = self.borderColor.CGColor;
    
    CGPathRef fromPath  = _circleAnimated.path;
    CGPathRef toPath  = [self generatePathWithRect:CGRectInset(self.collapsedFrame, -kDistanceToContainerView, -kDistanceToContainerView)];
    
    CABasicAnimation* animateCollapse = [CABasicAnimation animationWithKeyPath: @"path"];
    animateCollapse.fromValue = (__bridge id) fromPath;
    animateCollapse.toValue = (__bridge id) toPath;
    animateCollapse.duration = 0.5;
    animateCollapse.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [_circleAnimated addAnimation:animateCollapse forKey:@"collapse"];
    
    _circleAnimated.path = toPath;
    
    CABasicAnimation* animateCircleAlpha = [CABasicAnimation animationWithKeyPath: @"strokeEnd"];
    animateCircleAlpha.fromValue = @1;
    animateCircleAlpha.toValue = @0;
    animateCircleAlpha.duration = 0.5;
    
    [_circleAnimated addAnimation:animateCircleAlpha forKey:@"alpha"];
    
    _circleAnimated.strokeEnd = 0.0f;
    
    [UIView animateWithDuration:0.5f animations:^{
        self.frame = self.collapsedFrame;
        _tableView.alpha = 0.0f;
    }
    completion:^(BOOL finished) {
        self.longPressButtonState = DALongPressButtonStateCollapsed;
    }];
}

- (void)animationDidStart:(CAAnimation *)anim
{
    _startTime = [_circleAnimated convertTime:CACurrentMediaTime() fromLayer:nil];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        NSLog(@"Long press ended");
    }
    else if (recognizer.state == UIGestureRecognizerStateBegan){
        NSLog(@"Long press started");
        _startTime = 0.0f;
        
        [self expandAnimated:YES];
    }
}

@end