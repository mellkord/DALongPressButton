//
// Created by TBetts on 10/14/13.
//


#import "DALongPressButtonView.h"

static const CGFloat kIndicatorAnimationDelay = 0.2f;
static const CGFloat kIndicatorAnimationDuration = 1.4f;
static const CGFloat kIndicatorHideAnimationMaxDuration = 0.7f;
static const CGFloat kExpandCollapseAnimationDuration = 0.5f;
static const CGFloat kDistanceToContainerView = 3.0f;
static const CGFloat kLineWidthMultiplyer = 0.03f;

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

- (void)setLongPressButtonState:(DALongPressButtonState)longPressButtonState {
    _longPressButtonState = longPressButtonState;
    self.tintColor = (_longPressButtonState == DALongPressButtonStateCollapsed)?self.normalTintColor:self.higlitedTintColor;
    self.frame = (_longPressButtonState == DALongPressButtonStateCollapsed)?self.collapsedFrame:self.expandedFrame;
    
}

- (void)initializeControl
{
    if (_hasInitialized && CGRectEqualToRect(self.frame, CGRectZero))
    {
        return;
    }
    
    int radius = self.bounds.size.width / 2;
    
    self.layer.cornerRadius = radius;
    self.layer.borderColor = self.tintColor.CGColor;
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
    _circleAnimated.strokeColor = self.normalTintColor.CGColor;
    _circleAnimated.lineWidth = self.bounds.size.width * kLineWidthMultiplyer;
    _circleAnimated.actions = @{@"strokeEnd" : [NSNull null]};
    _circleAnimated.strokeEnd = (_longPressButtonState == DALongPressButtonStateCollapsed)?0.0f:1.0f;
    
    [self.layer addSublayer:_circleAnimated];
    
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
    [self performSelector:@selector(startLongTapAnimation) withObject:nil afterDelay:kIndicatorAnimationDelay];
    self.tintColor = self.higlitedTintColor;
    self.layer.borderColor = self.higlitedTintColor.CGColor;
}

- (void)startLongTapAnimation
{
    [_circleAnimated removeAllAnimations];
    
    
    CABasicAnimation *animateCircle = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animateCircle.duration = kIndicatorAnimationDuration;
    animateCircle.fromValue = @0;
    animateCircle.toValue = @1;
    animateCircle.delegate = self;
    
    [_circleAnimated addAnimation:animateCircle forKey:@"forward"];
    
    _circleAnimated.strokeEnd = 1.0;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    self.tintColor = self.normalTintColor;
    self.layer.borderColor = self.normalTintColor.CGColor;
    
    if (_startTime == 0.0f)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                 selector:@selector(startLongTapAnimation) object:nil];
        return;
    }
    
    CFTimeInterval stopTime = [_circleAnimated convertTime:CACurrentMediaTime() fromLayer:nil];
    CFTimeInterval timeOffset = stopTime - _startTime;
    _currentStrokeEnd = timeOffset / kIndicatorAnimationDuration;
    [_circleAnimated removeAllAnimations];
    _circleAnimated.strokeEnd = _currentStrokeEnd;
    
    CABasicAnimation *animateCircle = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animateCircle.duration = kIndicatorHideAnimationMaxDuration * _currentStrokeEnd;
    animateCircle.fromValue = @(_currentStrokeEnd);
    animateCircle.toValue = @0;
    
    [_circleAnimated addAnimation:animateCircle forKey:@"backward"];
    _currentStrokeEnd = 0.0f;
    _circleAnimated.strokeEnd = _currentStrokeEnd;
    _startTime = 0.0f;
    
}

- (void)expandAnimated:(BOOL)animated
{
    if (self.longPressButtonState == DALongPressButtonStateExpanded)
    {
        return;
    }
    
    CGPathRef fromPath  = _circleAnimated.path;
    CGPathRef toPath  = [self generatePathWithRect:CGRectInset(self.expandedFrame, -kDistanceToContainerView, -kDistanceToContainerView)];
    
    if (!animated)
    {
        _circleAnimated.path = toPath;
        self.frame = self.expandedFrame;
        _tableView.alpha = 1.0f;
        self.longPressButtonState = DALongPressButtonStateExpanded;
    }
    
    CABasicAnimation* animateExpand = [CABasicAnimation animationWithKeyPath: @"path"];
    animateExpand.fromValue = (__bridge id) fromPath;
    animateExpand.toValue = (__bridge id) toPath;
    animateExpand.duration = kExpandCollapseAnimationDuration;
    animateExpand.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [_circleAnimated addAnimation:animateExpand forKey:@"expand"];
    
    _circleAnimated.path = toPath;
    
    [UIView animateWithDuration:kExpandCollapseAnimationDuration animations:^{
        self.frame = self.expandedFrame;
        _tableView.alpha = 1.0f;
    }
    completion:^(BOOL finished) {
        self.longPressButtonState = DALongPressButtonStateExpanded;
    }];
}

- (void)collapseAnimated:(BOOL)animated
{
    if (self.longPressButtonState == DALongPressButtonStateCollapsed)
    {
        return;
    }
    
    self.tintColor = self.normalTintColor;
    self.layer.borderColor = self.normalTintColor.CGColor;
    
    CGPathRef fromPath  = _circleAnimated.path;
    CGPathRef toPath  = [self generatePathWithRect:CGRectInset(self.collapsedFrame, -kDistanceToContainerView, -kDistanceToContainerView)];
    
    if (!animated)
    {
        _circleAnimated.path = toPath;
        self.frame = self.collapsedFrame;
        _tableView.alpha = 0.0f;
        self.longPressButtonState = DALongPressButtonStateCollapsed;
    }
    
    CABasicAnimation* animateCollapse = [CABasicAnimation animationWithKeyPath: @"path"];
    animateCollapse.fromValue = (__bridge id) fromPath;
    animateCollapse.toValue = (__bridge id) toPath;
    animateCollapse.duration = kExpandCollapseAnimationDuration;
    animateCollapse.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [_circleAnimated addAnimation:animateCollapse forKey:@"collapse"];
    
    _circleAnimated.path = toPath;
    
    CABasicAnimation* animateCircleAlpha = [CABasicAnimation animationWithKeyPath: @"strokeEnd"];
    animateCircleAlpha.fromValue = @1;
    animateCircleAlpha.toValue = @0;
    animateCircleAlpha.duration = kExpandCollapseAnimationDuration;
    
    [_circleAnimated addAnimation:animateCircleAlpha forKey:@"alpha"];
    
    _circleAnimated.strokeEnd = 0.0f;
    
    [UIView animateWithDuration:kExpandCollapseAnimationDuration animations:^{
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
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        _startTime = 0.0f;
        [self expandAnimated:YES];
    }
}

@end