
#import <UIKit/UIKit.h>
#import "CircleGestureRecognizer.h"

@interface CircleView : UIView <CircleGestureFailureDelegate>
{
    NSArray *points;
    CGPoint center;
    CGFloat radius;
    CGPoint wrongPoint;
}

@property IBOutlet UILabel *label;
@property CircleGestureRecognizer *circleGestureRecognizer;

- (void)eraseText;
- (void) handleGesture:(CircleGestureRecognizer *)gr;

@end

