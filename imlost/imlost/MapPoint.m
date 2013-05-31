//
//  MapPoint.m
//  imlost
//
//  Created by Nan Shi on 5/31/13.
//  Copyright (c) 2013 Team Solace. All rights reserved.
//

#import "MapPoint.h"


@implementation MapPoint
@synthesize coordinate, title, subtitle;

- (id)initWithCoordinate:(CLLocationCoordinate2D)c title:(NSString *)t subtitle:(NSString *)st;
{
	self = [super init];
	coordinate = c;
	[self setTitle:t];
    [self setSubtitle:st];
	
	return self;
}

@end