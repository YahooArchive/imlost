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

#import "AppDelegate.h"
#import "ViewController.h"
#import "FirstRunViewController.h"
#import "Person.h"
#import "PeopleViewController.h"
#import "DataManager.h"

//NSString * const kYFUserDefaultsKeyAppHasLaunchedBefore = @"kYFUserDefaultsKeyAppHasLaunchedBefore";

// TODO: ADD COLOR constants
// blue: RGB: 158 222 240
// 171 226 179 for green

@interface AppDelegate()

@property (strong, nonatomic) ViewController *viewController;
@property (strong, nonatomic) FirstRunViewController *firstRunViewController;

@end

@implementation AppDelegate {
//	NSMutableArray *people;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    /*
    
    people = [[NSMutableArray alloc] init];
	Person *person = [[Person alloc] init];
	person.name = @"Derek Omuro the First";
    person.numbers=[[NSMutableArray alloc] initWithObjects:@"(408)718-8401",nil];
	[people addObject:person];
    
    person = [[Person alloc] init];
	person.name = @"Derek Omuro the Second";
    person.numbers=[[NSMutableArray alloc] initWithObjects:@"(408)718-8401",@"(408)718-8401",nil];
	[people addObject:person];
    
    [DataManager writeToPlist:@"people.plist" withData:people];
    */    
    [self firstTimeCheck];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma  mark First Run

- (void) firstTimeCheck
{
    NSString * userType = [[NSUserDefaults standardUserDefaults] objectForKey:kYFUserDefaultsKeyUserType];
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:kYFUserDefaultsKeyAppHasLaunchedBefore])
    if (userType != nil)
    {
        // app already launched
        NSLog(@"app already launched");
        self.viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];

        self.viewController.isDependent = [userType isEqualToString:@"Dependent"];

        self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.viewController];

        // set up triple tap on nav bar, to reset user type
        UITapGestureRecognizer * tripleTapRecognizer = [[UITapGestureRecognizer alloc] init];
        tripleTapRecognizer.numberOfTapsRequired = 3;
        [tripleTapRecognizer addTarget:self action:@selector(onNavBarTripleTap:)];
        [self.navigationController.navigationBar addGestureRecognizer:tripleTapRecognizer];
    }
    else
    {        
//        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kYFUserDefaultsKeyAppHasLaunchedBefore];
//        [[NSUserDefaults standardUserDefaults] synchronize];

        // This is the first launch ever
        NSLog(@"first launch ever");
        self.firstRunViewController = [[FirstRunViewController alloc] initWithNibName:@"FirstRunViewController" bundle:nil];
        self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.firstRunViewController];
    }
    
    self.navigationController.navigationBar.topItem.title = @"I'm Lost";
    
    self.window.rootViewController = self.navigationController;

    [self.window makeKeyAndVisible];
}

- (void) onNavBarTripleTap:(id)sender
{
    // for quicker debugging, reset the user type
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kYFUserDefaultsKeyUserType];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
