//
//  AudioRecordingManager.h
//  imlost
//
//  Created by Max Mai on 5/31/13.
//  Copyright (c) 2013 Team Solace. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioRecordingManager : NSObject

- (void) startRecording: (NSString *)filepath;
- (void) stopRecording;
- (BOOL) isRecording;
- (void) playback: (NSString *) filepath;

@end
