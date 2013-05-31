//
//  SetupViewController.m
//  imlost
//
//  Created by Praveenkumar Venkatesan on 5/30/13.
//  Copyright (c) 2013 Team Solace. All rights reserved.
//

#import "SetupViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <AVFoundation/AVFoundation.h>

#import "AudioRecordingManager.h"

@interface SetupViewController ()<UIImagePickerControllerDelegate,
                                  UINavigationControllerDelegate,
                                    AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) UIImagePickerController *cameraController;

@property (strong, nonatomic) NSString *audioFilepath;
@property (strong, nonatomic) AudioRecordingManager * audioManager;

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
    [self.cameraButton setTitle: @"Take a Picture" forState: UIControlStateNormal];

    
    [self.recordButton addTarget:self action:@selector(recordButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.recordButton setTitle: @"Record" forState: UIControlStateNormal];

    
    [self.playButton addTarget:self action:@selector(playButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.playButton setTitle: @"Play" forState: UIControlStateNormal];

    self.audioFilepath = [NSString stringWithFormat:@"%@/%@.caf", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], @"I'm-Lost-Audio" ];

    self.audioManager = [[AudioRecordingManager alloc] init];

    UIBarButtonItem *confirmButton = [[UIBarButtonItem alloc] initWithTitle:@"Confirm" style:UIBarButtonItemStylePlain target:self action:@selector(confirmButtonTapped:)];
    self.navigationItem.rightBarButtonItem = confirmButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)confirmButtonTapped:(id)sender
{
    // should not do this, o well.
    exit(0);
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

- (void) recordButtonPressed: (id) sender
{
    if ([self.audioManager isRecording]) {
        [self.audioManager stopRecording];
        [self.recordButton setTitle: @"Record" forState: UIControlStateNormal];
    }
    else {
        [self.audioManager startRecording:self.audioFilepath];
        [self.recordButton setTitle: @"Stop" forState: UIControlStateNormal];
    }
    
}

- (void) playButtonPressed: (id) sender
{
    [self.audioManager playback:self.audioFilepath];
}

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"finished taking image");
    
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        [self.cameraButton setTitle: @" " forState: UIControlStateNormal];
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
