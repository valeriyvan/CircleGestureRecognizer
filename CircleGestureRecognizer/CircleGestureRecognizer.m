#import "CircleGestureRecognizer.h"

#pragma mark - Helpers
#define degreesToRadian(x) (M_PI * x / 180.0)
#define radiansToDegrees(x) (180.0 * x / M_PI)

CGFloat distanceBetweenPoints (CGPoint first, CGPoint second) {
    CGFloat deltaX = second.x - first.x;
    CGFloat deltaY = second.y - first.y;
    return sqrt(deltaX*deltaX + deltaY*deltaY );
}

//CGFloat angleBetweenPoints(CGPoint first, CGPoint second) {
//    CGFloat height = second.y - first.y;
//    CGFloat width = first.x - second.x;
//    CGFloat rads = atan(height/width);
//    return radiansToDegrees(rads);
//}

CGFloat angleBetweenLines(CGPoint line1Start, CGPoint line1End, CGPoint line2Start, CGPoint line2End) {
    CGFloat a = line1End.x - line1Start.x;
    CGFloat b = line1End.y - line1Start.y;
    CGFloat c = line2End.x - line2Start.x;
    CGFloat d = line2End.y - line2Start.y;
    CGFloat rads = acos(((a*c) + (b*d)) / ((sqrt(a*a + b*b)) * (sqrt(c*c + d*d))));
    return radiansToDegrees(rads);
}

#pragma mark - CircleGestureRecognizer

@implementation CircleGestureRecognizer {
    NSMutableArray *points_;
    CGPoint firstTouch_;
    NSTimeInterval firstTouchTime_;
}

- (id) init {
    if ( (self = [super init]) ) {
        //_circleClosureAngleVariance = 45.0;  // not used
        _circleClosureDistanceVariance = 50.0;
        _maximumCircleTime = 3.0;
        _radiusVariancePercent = 25.0;
        _overlapTolerance = 3;
        _minimumNumPoints = 6;
        points_ = [[NSMutableArray alloc] init];
        firstTouch_ = CGPointZero;
        firstTouchTime_ = 0.0;
        _center = CGPointZero;
        _radius = 0.0;
        _wrongPoint = CGPointZero;
    }
    return self;
}

- (void) failWithError:(CircleGestureError)error {
    NSLog(@"Fail: not a circle, err.code %d", error);
    _error = error;
    self.state = UIGestureRecognizerStateFailed;
    if ( [self.delegate conformsToProtocol:@protocol(CircleGestureFailureDelegate)] ) {
        [(id<CircleGestureFailureDelegate>)self.delegate circleGestureFailed:self];
    }
}

- (NSArray *) points {
    NSMutableArray *allPoints = [points_ mutableCopy];
    [allPoints insertObject:NSStringFromCGPoint(firstTouch_) atIndex:0];
    return [NSArray arrayWithArray:allPoints];
}

- (void) reset {
    [super reset];
    [points_ removeAllObjects];
    firstTouch_ = CGPointZero;
    firstTouchTime_ = 0.0;
    _center = CGPointZero;
    _radius = 0.0;
    _wrongPoint = CGPointZero;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    firstTouch_ = [[touches anyObject] locationInView:self.view];
    firstTouchTime_ = [NSDate timeIntervalSinceReferenceDate];
    self.state = UIGestureRecognizerStateBegan;
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    CGPoint startPoint = [[touches anyObject] locationInView:self.view];
    [points_ addObject:NSStringFromCGPoint(startPoint)];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    CGPoint endPoint = [[touches anyObject] locationInView:self.view];
    [points_ addObject:NSStringFromCGPoint(endPoint)];

    // End too far from start
    if ( distanceBetweenPoints(firstTouch_, endPoint) > _circleClosureDistanceVariance ) {
        [self failWithError:ErrorNotClosed];
        return;
    }

    // Drawing overtimed
    if ( [NSDate timeIntervalSinceReferenceDate] - firstTouchTime_ > _maximumCircleTime ) {
        [self failWithError:ErrorTooSlow];
        return;
    }

    // Not enough number of point
    if ( [points_ count] < _minimumNumPoints ) {
        [self failWithError:ErrorTooShort];
        return;
    }

    CGPoint leftMost = firstTouch_;
    NSUInteger leftMostIndex = NSUIntegerMax;
    CGPoint topMost = firstTouch_;
    NSUInteger topMostIndex = NSUIntegerMax;
    CGPoint rightMost = firstTouch_;
    NSUInteger  rightMostIndex = NSUIntegerMax;
    CGPoint bottomMost = firstTouch_;
    NSUInteger bottomMostIndex = NSUIntegerMax;

    // Extreem points of rectangle around circle
    int index = 0;
    for ( NSString *pointString in points_ ) {
        CGPoint onePoint = CGPointFromString(pointString);
        if ( onePoint.x > rightMost.x ) {
            rightMost = onePoint;
            rightMostIndex = index;
        }
        if ( onePoint.x < leftMost.x ) {
            leftMost = onePoint;
            leftMostIndex = index;
        }
        if ( onePoint.y > topMost.y ) {
            topMost = onePoint;
            topMostIndex = index;
        }
        if ( onePoint.y < bottomMost.y ) {
            bottomMost = onePoint;
            bottomMostIndex = index;
        }
        index++;
    }

    // If startPoint one of extreem points
    if ( rightMostIndex == NSUIntegerMax ) {
        rightMost = firstTouch_;
    }
    if ( leftMostIndex == NSUIntegerMax ) {
        leftMost = firstTouch_;
    }
    if ( topMostIndex == NSUIntegerMax ) {
        topMost = firstTouch_;
    }
    if ( bottomMostIndex == NSUIntegerMax ) {
        bottomMost = firstTouch_;
    }

    // Circle center is center of rectangle
    _center = CGPointMake((rightMost.x + leftMost.x) / 2.0, (topMost.y + bottomMost.y) / 2.0);

    // Let radius be distance from starting point to center
    _radius = fabs(distanceBetweenPoints(_center, firstTouch_));

    // Проверяем что порядок точек похож на окружность и расстояние от текущей точки до центра
    // отклоняется от радиуса в допустимых пределах

    // Let's check that order of points is like in circle and destance from current point to center
    // deviates as allowed.

    CGFloat currentAngle = 0.0; // Angle between (center, start point) and (center, current point)
    BOOL    hasSwitched = NO; // YES if angle changed sign (came accross 180%)

    CGFloat minRadius = _radius - (_radius * _radiusVariancePercent);
    CGFloat maxRadius = _radius + (_radius * _radiusVariancePercent);

    index = 0;
    for ( NSString *pointString in points_ ) {
        CGPoint point = CGPointFromString(pointString);
        CGFloat distanceFromRadius = fabs(distanceBetweenPoints(_center, point));
        if ( distanceFromRadius < minRadius || distanceFromRadius > maxRadius ) {
            _wrongPoint = point;
            [self failWithError:ErrorRadiusVarianceTolerance];
            return;
        }

        // Same angle between (center, start point) and (center, current point)
        CGFloat pointAngle = angleBetweenLines(firstTouch_, _center, point, _center);

        if ( (pointAngle > currentAngle && hasSwitched) && (index < points_.count - _overlapTolerance) ) {
            _wrongPoint = point;
            [self failWithError:ErrorOverlapTolerance];
            return;
        }

        if ( pointAngle < currentAngle ) {
            if ( !hasSwitched )
                hasSwitched = YES;
        }

        currentAngle = pointAngle;
        index++;
    }

    _error = ErrorNone;
    self.state = UIGestureRecognizerStateEnded;
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    self.state = UIGestureRecognizerStateFailed;
    [super touchesCancelled:touches withEvent:event];
}

@end