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

@interface SetupViewController ()<UIImagePickerControllerDelegate,
                                  UINavigationControllerDelegate,
                                    AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) UIImagePickerController *cameraController;
@property (strong, nonatomic) AVAudioPlayer *player;
@property (strong, nonatomic) AVAudioRecorder *recorder;
@property (strong, nonatomic) NSString *filepath;

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

    self.filepath = [NSString stringWithFormat:@"%@/%@.caf", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], @"I'm-Lost-Audio" ] ;
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

- (void) recordButtonPressed: (id) sender
{
    if ([self.recorder isRecording]) {
        [self stopRecording];
        [self.recordButton setTitle: @"Record" forState: UIControlStateNormal];
    }
    else {
        [self startRecording:self.filepath];
        [self.recordButton setTitle: @"Stop" forState: UIControlStateNormal];
    }
    
}

- (void) playButtonPressed: (id) sender
{
    [self playback:self.filepath];
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



#pragma mark Audio

/*********
 startRecording does everything from start to finish to start recording the audio.
 
 Input Arguments: filepath is the absolute string. The file extension has to be hardcoded in the path
 
 How to initialize filepath:
 
 filepath = [NSString stringWithFormat:@"%@/%@.caf", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], @"test" ] ;
 
 *********/

- (void) startRecording: (NSString *)filepath
{
    // initialize the audio session
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    // set the category of the session
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    if(err){
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
    }
    
    //activate app's audio session
    [audioSession setActive:YES error:&err];
    err = nil;
    if(err){
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
    }
    
    //use the audio recorder to start the recording
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    [recordSetting setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    
    NSURL *url = [NSURL fileURLWithPath:filepath];
    err = nil;
    self.recorder = [[ AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&err];
    if(!self.recorder){
        NSLog(@"recorder: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
                                   message: [err localizedDescription]
                                  delegate: nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    //prepare to record
    [self.recorder setDelegate:self];
    [self.recorder prepareToRecord];
    self.recorder.meteringEnabled = YES;
    
    [self.recorder record];
    
}

/**********
 stopRecording will stop the recorder
 
 **********/

- (void) stopRecording
{
    [self.recorder stop];    
}


/*******
 Playback will play back the Audio 
 
 Input Arguments: filepath is the absolute string. The file extension has to be hardcoded in the path
 
 How to initialize filepath:
 
 filepath = [NSString stringWithFormat:@"%@/%@.caf", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], @"test" ] ;
 
 *******/

- (void) playback: (NSString *) filepath
{
    NSError *err = nil;
    
    NSURL *url = [NSURL fileURLWithPath:filepath];
    
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&err];
    
    if (!self.player) {
        NSLog(@"player: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
                                   message: [err localizedDescription]
                                  delegate: nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [self.player setDelegate:self];
    [self.player setMeteringEnabled: YES];
    [self.player prepareToPlay];
    [self.player play];
    
}


// AVAudioRecorder delegate methods

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *) aRecorder successfully:(BOOL)flag
{
    
    NSLog (@"audioRecorderDidFinishRecording:successfully:");
    // your actions here
    
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    NSLog (@"audioRecorderEncodeErrorDidOccur: %@", error);
    
}

- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder
{
    NSLog (@"audioRecorderBeginInterruption:");
    
}

- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder withOptions:(NSUInteger)flags
{
    NSLog (@"audioRecorderEndInterruption:");
    
}


// AVAudioPlayer delegate methods

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog (@"audioPlayerDidFinishPlaying: successfully");
    
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog (@"audioPlayerDecodeErrorDidOccur: %@", error);
    
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    NSLog (@"audioPlayerBeginInterruption:");
    
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags
{
    NSLog (@"audioPlayerEndInterruption:");
    
}



@end
