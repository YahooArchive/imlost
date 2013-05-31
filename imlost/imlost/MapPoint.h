//
//  MapPoint.h
//  imlost
//
//  Created by Nan Shi on 5/31/13.
//  Copyright (c) 2013 Team Solace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

/**
 * Customized MapPoint conforms to MKAnnotation delegate.
 */
@interface MapPoint : NSObject <MKAnnotation>

- (id)initWithCoordinate:(CLLocationCoordinate2D)c title:(NSString *)t subtitle:(NSString *)st;

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@end
