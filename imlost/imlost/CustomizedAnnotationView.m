//
//  CustomizedAnnotationView.m
//  imlost
//
//  Created by Nan Shi on 5/31/13.
//  Copyright (c) 2013 Team Solace. All rights reserved.
//

#import "CustomizedAnnotationView.h"


@implementation CustomizedAnnotationView
- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self != nil)
    {
        CGRect frame = self.frame;
        frame.size = CGSizeMake(60.0, 85.0);
        self.frame = frame;
        self.backgroundColor = [UIColor clearColor];
        self.centerOffset = CGPointMake(-5, -5);
    }
    return self;
}

@end
