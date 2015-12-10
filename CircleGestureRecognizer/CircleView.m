#import "CircleView.h"

@implementation CircleView
@synthesize label;

- (void)addCircleGestureRecognizer {
    self.circleGestureRecognizer = [[CircleGestureRecognizer alloc] init];
    [self.circleGestureRecognizer addTarget:self action:@selector(handleGesture:)];
    [self addGestureRecognizer:self.circleGestureRecognizer];
    self.circleGestureRecognizer.delegate = self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addCircleGestureRecognizer];
    }
    return self;
}

- (void) awakeFromNib {
    [super awakeFromNib];
    [self addCircleGestureRecognizer];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    if ( [points count] > 1 ) {
        // Green circles of min and max allowed radius
        CGContextSetLineWidth(context, 1.0);
        CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor);
        // Min
        CGFloat radiusMin = radius - radius*self.circleGestureRecognizer.radiusVariancePercent;
        CGRect rect = CGRectMake(center.x - radiusMin, center.y - radiusMin, radiusMin*2.0, radiusMin*2.0);
        CGContextAddEllipseInRect(context, rect);
        CGContextDrawPath(context, kCGPathStroke);
        // Max
        CGFloat radiusMax = radius + radius*self.circleGestureRecognizer.radiusVariancePercent;
        rect = CGRectMake(center.x - radiusMax, center.y - radiusMax, radiusMax*2.0, radiusMax*2.0);
        CGContextAddEllipseInRect(context, rect);
        CGContextDrawPath(context, kCGPathStroke);

        // Connect all points with red segments
        CGContextSetLineWidth(context, 2.0);
        CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
        CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);

        BOOL first = YES;
        for (NSString *onePointString in points) {
            CGPoint nextPoint = CGPointFromString(onePointString);
            if ( first ) {
                first = NO;
                // First point will be bold
                CGRect dotRect = CGRectMake(nextPoint.x - 3.0, nextPoint.y - 3.0, 6.0, 6.0);
                CGContextAddEllipseInRect(context, dotRect);
                CGContextDrawPath(context, kCGPathFillStroke);
                CGContextMoveToPoint(context, nextPoint.x, nextPoint.y);
            } else {
                CGContextAddLineToPoint(context, nextPoint.x, nextPoint.y);
            }
        }
        CGContextStrokePath(context);
        if ( radius > 0 ) {
            // Two radiuses, to top and upright
            CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor);
            CGContextSetFillColorWithColor(context, [UIColor greenColor].CGColor);
            // Green point in the center
            CGRect dotRect = CGRectMake(center.x - 3.0, center.y - 3.0, 6.0, 6.0);
            CGContextAddEllipseInRect(context, dotRect);
            CGContextDrawPath(context, kCGPathFillStroke);
            CGContextMoveToPoint(context, center.x, center.y - radius);
            CGContextAddLineToPoint(context, center.x, center.y);
            CGContextAddLineToPoint(context, center.x + radius, center.y);
            CGContextStrokePath(context);
        }
        if (!CGPointEqualToPoint(wrongPoint, CGPointZero)) {
            // Wrong point will be yellow bold
            CGContextSetStrokeColorWithColor(context, [UIColor yellowColor].CGColor);
            CGContextSetFillColorWithColor(context, [UIColor yellowColor].CGColor);
            // Green dot in the center
            CGRect dotRect = CGRectMake(wrongPoint.x - 3.0, wrongPoint.y - 3.0, 6.0, 6.0);
            CGContextAddEllipseInRect(context, dotRect);
            CGContextDrawPath(context, kCGPathFillStroke);
        }
    } else {
        CGContextSetFillColorWithColor(context, self.backgroundColor.CGColor);
        CGContextAddRect(context, self.bounds);
        CGContextFillPath(context);
    }
}

- (void)circleGestureFailed:(CircleGestureRecognizer *)gr {
    self.label.textColor = [UIColor redColor];
    switch ( gr.error ) {
        case ErrorNotClosed:
            self.label.text = @"Fail: finished too far from start";
            break;
        case ErrorOverlapTolerance:
            wrongPoint = gr.wrongPoint;
            center = gr.center;
            radius = gr.radius;
            self.label.text = @"Fail: separate point too far from each other";
            break;
        case ErrorRadiusVarianceTolerance:
            wrongPoint = gr.wrongPoint;
            center = gr.center;
            radius = gr.radius;
            self.label.text = @"Fail: redius deviats too much";
            break;
        case ErrorTooShort:
            self.label.text = [NSString stringWithFormat:@"Fail: мало точек (%ld)", (unsigned long)gr.points.count];
            break;
        case ErrorTooSlow:
            self.label.text = @"Fail: have been drawing too long";
            break;
        case ErrorNone:
            self.label.text = @"";
            break;
    }
    [self setNeedsDisplay];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    label.text = @"";
    return YES;
}

- (void) handleGesture:(CircleGestureRecognizer *)gr {
    switch (gr.state) {
        case UIGestureRecognizerStateEnded:
            label.textColor = [UIColor whiteColor];
            label.text = [NSString stringWithFormat:@"Success: center %@, radius %f", NSStringFromCGPoint(gr.center), gr.radius];
            center = gr.center;
            radius = gr.radius;
            break;
        case UIGestureRecognizerStateChanged:
            points = gr.points;
            break;
        case UIGestureRecognizerStateBegan:
            points = nil;
            center = CGPointZero;
            radius = -1;
            wrongPoint = CGPointZero;
            break;
        default:
            break;
    }
    [self setNeedsDisplay];
}

- (void)eraseText {
    label.text = @"";
    [self setNeedsDisplay];
}

@end
