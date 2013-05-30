//
// Copyright (c) 2013, Sivan Goldstein
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in the
//       documentation and/or other materials provided with the distribution.
//     * The names of its contributors may not be used to endorse or promote products
//       derived from this software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL Sivan Goldstein BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// 

#import "TrackingViewController.h"
#import "MapPin.h"
#define METERS_PER_MILE 1609.344

@interface TrackingViewController ()

@end

@implementation TrackingViewController
@synthesize username;
@synthesize map;
CLLocationCoordinate2D loc;
MapPin *pin;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidAppear:(BOOL)animated{
    MKCoordinateSpan span;
    //You can set span for how much Zoom to be display
    span.latitudeDelta=.003;
    span.longitudeDelta=.003;
    
    //set Region to be display on MKMapView
    MKCoordinateRegion cordinateRegion;
    cordinateRegion.center=loc;
    //latAndLongLocation coordinates to be display
    cordinateRegion.span=span;
    
    [map setRegion:cordinateRegion animated:YES];
    //mapView MkMapView

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    map.delegate = self;
    username = @"derek";
    [self updateLocation];

    pin = [[MapPin alloc]initWithCoordinates:loc placeName:username description:@""];
    [map addAnnotation:pin];
    [NSTimer scheduledTimerWithTimeInterval: 5.0 target:self selector:@selector(update:) userInfo:nil repeats: YES];
    
}
-(void) update:(NSTimer *)timer
{
    [self updateLocation];
    [UIView animateWithDuration:0.5 animations:^{
        [pin setCoordinate:loc];
    }];
}

-(void)updateLocation
{
    NSString *urlString = [NSString stringWithFormat:@"https://students6.ics.uci.edu/~limll/%@.data", username];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"GET"];
    
    NSError *error = [[NSError alloc] init];
    NSHTTPURLResponse *responseCode = nil;
    
    NSData* data= [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    NSString* responseString = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
    
    if([responseCode statusCode] != 200){
        NSLog(@"Error getting %@, HTTP status code %i", url, [responseCode statusCode]);
        return;
    }
    NSArray *responseStrings = [responseString componentsSeparatedByString:@"\n"];
    loc.latitude = [responseStrings[0] floatValue];
    loc.longitude = [responseStrings[1] floatValue];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
