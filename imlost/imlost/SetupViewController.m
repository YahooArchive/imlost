//
//  SetupViewController.m
//  imlost
//
//  Created by Praveenkumar Venkatesan on 5/30/13.
//  Copyright (c) 2013 Team Solace. All rights reserved.
//

#import "SetupViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>

@interface SetupViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *audioButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) UIImagePickerController *cameraController;

@end

@implementation SetupViewController

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
    
    [self.cameraButton addTarget:self action:@selector(cameraButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.audioButton addTarget:self action:@selector(audioButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark Button Pressed

- (void) cameraButtonPressed: (id) sender
{
    NSLog(@"camera button pressed");
    
    //take a picture on front facing camera
    if ([UIImagePickerController isCameraDeviceAvailable:
         UIImagePickerControllerCameraDeviceFront || UIImagePickerControllerCameraDeviceRear]) {
        self.cameraController = [[UIImagePickerController alloc] init];
        self.cameraController.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        // Displays a control that allows the user to choose picture or
        // movie capture, if both are available:
        self.cameraController.mediaTypes =
        [UIImagePickerController availableMediaTypesForSourceType:
         UIImagePickerControllerSourceTypeCamera];
        
        self.cameraController.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
        
        // Hides the controls for moving & scaling pictures, or for
        // trimming movies. To instead show the controls, use YES.
        self.cameraController.allowsEditing = NO;
        
        self.cameraController.delegate = self;
        
        [self presentViewController:self.cameraController animated:YES completion:^{
            
        }];
        
    }
}

- (void) audioButtonPressed: (id) sender
{
    
}

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"finished taking image");
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        self.cameraButton.titleLabel.hidden = YES;
        self.imageView.image = image;
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"image taking action cancelled");
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
