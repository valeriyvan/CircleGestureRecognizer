//
//  ViewController.h
//  CircleGestureRecognizer
//
//  Created by Valeriy Van on 2/9/15.
//  Copyright (c) 2015 Valeriy Van. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircleView.h"

@interface ViewController : UIViewController

@property IBOutlet CircleView *circleView;

@property IBOutlet UISlider *circleClosureDistanceVarianceSlider;
@property IBOutlet UISlider *maximumCircleTimeSlider;
@property IBOutlet UISlider *radiusVariancePercentSlider;
@property IBOutlet UISlider *overlapToleranceSlider;
@property IBOutlet UISlider *minimumNumPointsSlider;

@property IBOutlet UILabel *circleClosureDistanceVarianceLabel;
@property IBOutlet UILabel *maximumCircleTimeLabel;
@property IBOutlet UILabel *radiusVariancePercentLabel;
@property IBOutlet UILabel *overlapToleranceLabel;
@property IBOutlet UILabel *minimumNumPointsLabel;
@end

