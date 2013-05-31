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

#import "ViewController.h"
#import "DataManager.h"
#import "Person.h"
#import "MapPoint.h"
#import "AudioRecordingManager.h"

NSString * const kTesterPhoneNumberForText = @"+4053341946";

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UIButton *button;
@property (strong, nonatomic) NSString *username;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *locationMeasurements;
@property (nonatomic, strong) CLLocation *bestEffortAtLocation;

@property (nonatomic, strong) NSMutableArray *locations;
@property (nonatomic, strong) MKMapView *mapView;
@property (strong, nonatomic) MKPolyline *polyline;

@property (strong, nonatomic) NSString *audioFilepath;
@property (strong, nonatomic) AudioRecordingManager * audioManager;

@property (weak, nonatomic) IBOutlet MKMapView *dependentMapView;

//-(IBAction)pressed:(id)sender;

@end

@implementation ViewController
@synthesize locationManager;
@synthesize locationMeasurements, locations;
@synthesize bestEffortAtLocation;
@synthesize username;
@synthesize mapView;

- (void)viewDidLoad
{
    [super viewDidLoad];
//	// Do any additional setup after loading the view, typically from a nib.
//    
//    // Create the manager object
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
//
//    // This is the most important property to set for the manager. It ultimately determines how the manager will
//    // attempt to acquire location and thus, the amount of power that will be consumed.
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    [locationManager startUpdatingLocation];
//
    username = @"Bobby";

    // TODO: create a setting class and get the audio file path from settings
    self.audioFilepath = [NSString stringWithFormat:@"%@/%@.caf", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], @"I'm-Lost-Audio" ];
    self.audioManager = [[AudioRecordingManager alloc] init];

    locations = [[NSMutableArray alloc] initWithCapacity:20];
    [self createFakeLocations];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    if (!self.isDependent)
    {
        self.mapView = [[MKMapView alloc] initWithFrame:self.view.frame];
        self.mapView.delegate = self;
        [self.view addSubview:self.mapView];

        [self startRoute];
    }
}

//TODO:nanshi - create fake CLLocation locations
// In the future, these locations should be obtained from server side
- (void)createFakeLocations
{
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:37.409966 longitude:-122.026181];
    [locations addObject:(loc)];
    
    loc = [[CLLocation alloc] initWithLatitude:37.411517 longitude:-122.026084];
    [locations addObject:(loc)];
    
    loc = [[CLLocation alloc] initWithLatitude:37.412327 longitude:-122.025923];
    [locations addObject:(loc)];
    
    loc = [[CLLocation alloc] initWithLatitude:37.413554 longitude:-122.025548];
    [locations addObject:(loc)];
    
    loc = [[CLLocation alloc] initWithLatitude:37.414398 longitude:-122.025194];
    [locations addObject:(loc)];
    
    loc = [[CLLocation alloc] initWithLatitude:37.415318 longitude:-122.024915];
    [locations addObject:(loc)];
    
    loc = [[CLLocation alloc] initWithLatitude:37.416119 longitude:-122.024764];
    [locations addObject:(loc)];
    
    loc = [[CLLocation alloc] initWithLatitude:37.416409 longitude:-122.025548];
    [locations addObject:(loc)];
    
    loc = [[CLLocation alloc] initWithLatitude:37.416758 longitude:-122.026159];
    [locations addObject:(loc)];
    
    loc = [[CLLocation alloc] initWithLatitude:37.417193 longitude:-122.026513];
    [locations addObject:(loc)];
    
    loc = [[CLLocation alloc] initWithLatitude:37.417917 longitude:-122.026792];
    [locations addObject:(loc)];
    
    loc = [[CLLocation alloc] initWithLatitude:37.418462 longitude:-122.026406];
    [locations addObject:(loc)];
    
    loc = [[CLLocation alloc] initWithLatitude:37.4183 longitude:-122.025601];
    [locations addObject:(loc)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startRoute
{
    if(locations) {
        // Remove all annotations
        [mapView removeAnnotations:[mapView annotations]];
    }
    
    [self centerMap];
    
    // Origin Location
    // TODO:nanshi - For demo, this is mom's location 37.409966,-122.026181
    CLLocationCoordinate2D locOrigin;
    locOrigin.latitude = 37.409966;
    locOrigin.longitude = -122.026181;
    MapPoint *origin = [[MapPoint alloc] initWithCoordinate:locOrigin title:@"Mom" subtitle:@""];
    [mapView addAnnotation:origin];
    
    // Destination Location.
    // TODO:nanshi - For demo, this is kid's location 37.4183,-122.025601
    CLLocationCoordinate2D locDestination;
    locDestination.latitude = 37.4183;
    locDestination.longitude = -122.025601;
    MapPoint *destination = [[MapPoint alloc] initWithCoordinate:locDestination title:@"Kid" subtitle:@""];
    [mapView addAnnotation:destination];
    
    
//    arrRoutePoints = [self getRoutePointFrom:origin to:destination];
    [self drawRoute];
}

- (void)drawRoute
{
    int numPoints = [locations count];
    if (numPoints > 1)
    {
        CLLocationCoordinate2D* coords = malloc(numPoints * sizeof(CLLocationCoordinate2D));
        for (int i = 0; i < numPoints; i++)
        {
            CLLocation* current = [locations objectAtIndex:i];
            coords[i] = current.coordinate;
        }
        
        _polyline = [MKPolyline polylineWithCoordinates:coords count:numPoints];
        free(coords);
        
        [mapView addOverlay:_polyline];
        [mapView setNeedsDisplay];
    }
}

// MKMapViewDelegate Method -- for viewForOverlay
- (MKOverlayView*)mapView:(MKMapView*)theMapView viewForOverlay:(id <MKOverlay>)overlay
{
    MKPolylineView *view = [[MKPolylineView alloc] initWithPolyline:_polyline];
    view.fillColor = [UIColor greenColor];
    view.strokeColor = [UIColor greenColor];
    view.lineWidth = 6;
    return view;
}

- (void)centerMap
{
    MKCoordinateRegion region;
    
    CLLocationDegrees maxLat = -90;
    CLLocationDegrees maxLon = -180;
    CLLocationDegrees minLat = 90;
    CLLocationDegrees minLon = 180;
    
    for(int idx = 0; idx < locations.count; idx++)
    {
        CLLocation* currentLocation = [locations objectAtIndex:idx];
        
        if(currentLocation.coordinate.latitude > maxLat)
            maxLat = currentLocation.coordinate.latitude;
        if(currentLocation.coordinate.latitude < minLat)
            minLat = currentLocation.coordinate.latitude;
        if(currentLocation.coordinate.longitude > maxLon)
            maxLon = currentLocation.coordinate.longitude;
        if(currentLocation.coordinate.longitude < minLon)
            minLon = currentLocation.coordinate.longitude;
    }
    
    region.center.latitude     = (maxLat + minLat) / 2;
    region.center.longitude    = (maxLon + minLon) / 2;
    region.span.latitudeDelta  = maxLat - minLat;
    region.span.longitudeDelta = maxLon - minLon;
    
    [mapView setRegion:region animated:YES];
}

-(void)sendText:(NSString *)locationURL phoneNumber:(NSString*)kToNumber personName:(NSString*)name
{
    NSLog(@"Sending request.");
    
    // Common constants
    NSString *kTwilioSID = @"AC384121e3ec0bc14697150a947f04e32f";
    NSString *kTwilioSecret = @"0c6b44a8c5c143b04fe883251deb0b1e";
    NSString *kFromNumber = @"+4055719717";
    
    //NSString *kToNumber = @"+4087188401";
    NSString *kMessage = [NSString stringWithFormat:@"Hello %@, %@ is lost at Location: %@", name,username,locationURL];
    NSLog(@"TEXT: %@",kMessage);
    // Build request
    NSString *urlString = [NSString stringWithFormat:@"https://%@:%@@api.twilio.com/2010-04-01/Accounts/%@/SMS/Messages", kTwilioSID, kTwilioSecret, kTwilioSID];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    
    // Set up the body
    NSString *bodyString = [NSString stringWithFormat:@"From=%@&To=%@&Body=%@", kFromNumber, kToNumber, kMessage];
    NSData *data = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    NSError *error;
    NSURLResponse *response;
    NSData *receivedData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    // Handle the received data
    if (error) {
        NSLog(@"Error: %@", error);
    } else {
        NSString *receivedString = [[NSString alloc]initWithData:receivedData encoding:NSUTF8StringEncoding];
        NSLog(@"Request sent. %@", receivedString);
    }
}

- (void)sendMapTextToPerson:(Person *)person {
    NSString *locationURL = [NSString stringWithFormat:@"https://students6.ics.uci.edu/~limll/location.php?username=%@", username];
    for(NSString* number in person.numbers)
    {
        NSString *cleannedNumber = 
        [NSString stringWithFormat:@"+%@",
         [[number componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]]componentsJoinedByString:@""]];
        [self sendText:locationURL phoneNumber:cleannedNumber personName:person.name];
    }
}

//-(IBAction)pressed:(id)sender{
//    [locationManager startUpdatingLocation];
//    //[self performSelector:@selector(stopUpdatingLocation:) withObject:@"Timed Out" afterDelay:45];
//    //[locationManager stopUpdatingLocation];
//    
//    NSMutableArray *people=[DataManager readFromPlist:@"people.plist"];
//    for(Person* person in people)
//    {
//        [self sendMapTextToPerson:person];
//    }
//}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    // store all of the measurements, just so we can see what kind of data we might receive
    [locationMeasurements addObject:newLocation];
    
    // test the age of the location measurement to determine if the measurement is cached
    // in most cases you will not want to rely on cached measurements
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 5.0) return;
    // test that the horizontal accuracy does not indicate an invalid measurement
    if (newLocation.horizontalAccuracy < 0) return;
    // test the measurement to see if it is more accurate than the previous measurement
    if (bestEffortAtLocation == nil || bestEffortAtLocation.horizontalAccuracy > newLocation.horizontalAccuracy) {
        // store the location as the "best effort"
        self.bestEffortAtLocation = newLocation;
        // test the measurement to see if it meets the desired accuracy
        //
        // IMPORTANT!!! kCLLocationAccuracyBest should not be used for comparison with location coordinate or altitidue
        // accuracy because it is a negative value. Instead, compare against some predetermined "real" measure of
        // acceptable accuracy, or depend on the timeout to stop updating. This sample depends on the timeout.
        //
        if (newLocation.horizontalAccuracy <= kCLLocationAccuracyNearestTenMeters){
            // we have a measurement that meets our requirements, so we can stop updating the location
            //
            // IMPORTANT!!! Minimize power usage by stopping the location manager as soon as possible.
            //
            //[self stopUpdatingLocation:NSLocalizedString(@"Acquired Location", @"Acquired Location")];
            // we can also cancel our previous performSelector:withObject:afterDelay: - it's no longer necessary
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopUpdatingLocation:) object:nil];
        }
    }

    // update the display with the new location data
    [self updateMapRegion:newLocation.coordinate];

//    [self sendRequest: newLocation];

    static BOOL isTextSent = NO;
    if (!isTextSent)
    {
        Person * person = [[Person alloc] init];
        person.name = @"Mom";
        person.numbers = [NSArray arrayWithObject:kTesterPhoneNumberForText];
        [self sendMapTextToPerson:person];
        isTextSent = YES;
    }
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    // The location "unknown" error simply means the manager is currently unable to get the location.
    // We can ignore this error for the scenario of getting a single location fix, because we already have a
    // timeout that will stop the location manager to save power.
    if ([error code] != kCLErrorLocationUnknown) {
        [self stopUpdatingLocation:NSLocalizedString(@"Error", @"Error")];
    }
}

- (void)stopUpdatingLocation:(NSString *)state {
    [locationManager stopUpdatingLocation];
    locationManager.delegate = nil;
}

- (void)updateMapRegion:(CLLocationCoordinate2D)coordinate
{
    MKCoordinateSpan span;
    span.latitudeDelta = 0.01;
    span.longitudeDelta = 0.01;
    
    MKCoordinateRegion region;
    region.span = span;
    region.center = coordinate;
    [self.dependentMapView setRegion:region animated:YES];
}

- (void)sendRequest:(CLLocation *)newLocation
{
    NSString *urlString = [NSString stringWithFormat:@"https://students6.ics.uci.edu/~limll/update.php?username=%@&locationx=%f&locationy=%f", username, newLocation.coordinate.latitude, newLocation.coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"GET"];
    
    NSError *error = [[NSError alloc] init];
    NSHTTPURLResponse *responseCode = nil;
    
    [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    if([responseCode statusCode] != 200){
        NSLog(@"Error getting %@, HTTP status code %i", url, [responseCode statusCode]);
    }
}

- (IBAction)onPlayAudioButtonTapped:(id)sender
{
    [self.audioManager playback:self.audioFilepath];
}

@end
