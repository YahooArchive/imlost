//
//  AudioRecordingManager.m
//  imlost
//
//  Created by Max Mai on 5/31/13.
//  Copyright (c) 2013 Team Solace. All rights reserved.
//

#import "AudioRecordingManager.h"
#import <AVFoundation/AVFoundation.h>

@interface AudioRecordingManager () <AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (strong, nonatomic) AVAudioPlayer *player;
@property (strong, nonatomic) AVAudioRecorder *recorder;

@end

@implementation AudioRecordingManager

#pragma mark Audio

/*********
 startRecording does everything from start to finish to start recording the audio.

 Input Arguments: filepath is the absolute string. The file extension has to be hardcoded in the path

 How to initialize filepath:

 filepath = [NSString stringWithFormat:@"%@/%@.caf", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], @"test" ] ;

 *********/

- (BOOL) isRecording
{
    return [self.recorder isRecording];
}

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
