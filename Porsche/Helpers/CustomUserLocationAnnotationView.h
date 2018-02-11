//
//  CustomUserLocationAnnotationView.h
//  Porsche
//
//  Created by Aryaman Sharda on 2/10/18.
//  Copyright © 2018 Aryaman Sharda. All rights reserved.
//

#import <Mapbox/Mapbox.h>

@interface CustomUserLocationAnnotationView : MGLUserLocationAnnotationView

@property (nonatomic) CGFloat size;
@property (nonatomic) CALayer *dot;
@property (nonatomic) CAShapeLayer *arrow;

@end
