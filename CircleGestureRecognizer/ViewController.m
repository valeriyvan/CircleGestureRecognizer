//
//  ViewController.m
//  CircleGestureRecognizer
//
//  Created by Valeriy Van on 2/9/15.
//  Copyright (c) 2015 Valeriy Van. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    [self setLabelsAndGestureRecognizerProperties];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setLabelsAndGestureRecognizerProperties {
    self.circleView.circleGestureRecognizer.circleClosureDistanceVariance = self.circleClosureDistanceVarianceSlider.value;
    self.circleClosureDistanceVarianceLabel.text = [NSString stringWithFormat:@"%.1lf", self.circleView.circleGestureRecognizer.circleClosureDistanceVariance];

    self.circleView.circleGestureRecognizer.maximumCircleTime = self.maximumCircleTimeSlider.value;
    self.maximumCircleTimeLabel.text = [NSString stringWithFormat:@"%.1lf", self.circleView.circleGestureRecognizer.maximumCircleTime];

    self.circleView.circleGestureRecognizer.radiusVariancePercent = self.radiusVariancePercentSlider.value;
    self.radiusVariancePercentLabel.text = [NSString stringWithFormat:@"%.2lf", self.circleView.circleGestureRecognizer.radiusVariancePercent];

    self.circleView.circleGestureRecognizer.overlapTolerance = self.overlapToleranceSlider.value;
    self.overlapToleranceLabel.text = [NSString stringWithFormat:@"%ld", self.circleView.circleGestureRecognizer.overlapTolerance];

    self.circleView.circleGestureRecognizer.minimumNumPoints = self.minimumNumPointsSlider.value;
    self.minimumNumPointsLabel.text = [NSString stringWithFormat:@"%ld", self.circleView.circleGestureRecognizer.minimumNumPoints];
}

- (IBAction)sliderChanged:(UISlider *)sender {
    [self setLabelsAndGestureRecognizerProperties];
}

@end
