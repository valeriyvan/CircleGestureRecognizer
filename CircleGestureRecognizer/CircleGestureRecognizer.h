#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

@class CircleGestureRecognizer;

@protocol CircleGestureFailureDelegate <UIGestureRecognizerDelegate>
- (void) circleGestureFailed:(CircleGestureRecognizer *)gr;
@end

typedef enum {
    ErrorNone,
    ErrorNotClosed,
    ErrorTooSlow,
    ErrorTooShort,
    ErrorRadiusVarianceTolerance,
    ErrorOverlapTolerance,
} CircleGestureError;

@interface CircleGestureRecognizer : UIGestureRecognizer
@property CGFloat circleClosureDistanceVariance; // Min distance in pixels between starting and end points
@property CGFloat maximumCircleTime; // Max time for drawing
@property CGFloat radiusVariancePercent; // Allowed radius deviation
@property NSInteger overlapTolerance; // Number of allowed overlapping points
@property NSInteger minimumNumPoints; // Min number of points allowed

@property (readonly) CGPoint center;
@property (readonly) CGFloat radius;
@property (readonly) NSArray *points;
@property (readonly) CircleGestureError error;
@property (readonly) CGPoint wrongPoint; // Point where stumbled with ErrorOverlapTolerance or ErrorRadiusVarianceTolerance

@end
