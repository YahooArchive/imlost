//
//  FirstRunViewController.m
//  imlost
//
//  Created by Praveenkumar Venkatesan on 5/30/13.
//  Copyright (c) 2013 Team Solace. All rights reserved.
//

#import "FirstRunViewController.h"
#import "SetupViewController.h"

NSString * const kYFUserDefaultsKeyUserType = @"kYFUserDefaultsKeyUserType";

@interface FirstRunViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *kidButton;
@property (weak, nonatomic) IBOutlet UIButton *mommyButton;

@property (strong, nonatomic) SetupViewController *setupVC;

@end

@implementation FirstRunViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.kidButton addTarget:self action:@selector(kidButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.mommyButton addTarget:self action:@selector(mommyButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    self.setupVC = [[SetupViewController alloc] initWithNibName:@"SetupViewController" bundle:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) kidButtonPressed: (id) sender
{
    [[NSUserDefaults standardUserDefaults] setObject:@"Dependent" forKey:kYFUserDefaultsKeyUserType];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.navigationController pushViewController:self.setupVC animated:YES];
}

- (void) mommyButtonPressed: (id) sender
{
    [[NSUserDefaults standardUserDefaults] setObject:@"CareGiver" forKey:kYFUserDefaultsKeyUserType];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.navigationController pushViewController:self.setupVC animated:YES];
}

@end
