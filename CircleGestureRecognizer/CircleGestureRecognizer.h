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
@property CGFloat circleClosureDistanceVariance; // минимальное расстояние в пикселах между конечными точками
@property CGFloat maximumCircleTime; // максимальное время на рисование
@property CGFloat radiusVariancePercent; // допустимое процентное отклонение радиуса
@property NSInteger overlapTolerance; // на сколько точек (не пикселов! а точек отрезков окружности) окружность может перекрываться
@property NSInteger minimumNumPoints; // минимальное количество точек

@property (readonly) CGPoint center;
@property (readonly) CGFloat radius;
@property (readonly) NSArray *points;
@property (readonly) CircleGestureError error;
@property (readonly) CGPoint wrongPoint; // Точка где споткнулись и выдали ErrorOverlapTolerance или ErrorRadiusVarianceTolerance

@end
