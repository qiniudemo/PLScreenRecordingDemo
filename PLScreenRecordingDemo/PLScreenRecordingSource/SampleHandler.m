//
//  SampleHandler.m
//  PLScreenRecordingSource
//
//  Created by 何昊宇 on 16/10/27.
//  Copyright © 2016年 Aaron. All rights reserved.
//


#import "SampleHandler.h"

//  To handle samples with a subclass of RPBroadcastSampleHandler set the following in the extension's Info.plist file:
//  - RPBroadcastProcessMode should be set to RPBroadcastProcessModeSampleBuffer
//  - NSExtensionPrincipalClass should be set to this class

@implementation SampleHandler

- (void)broadcastStartedWithSetupInfo:(NSDictionary<NSString *,NSObject *> *)setupInfo {
    // User has requested to start the broadcast. Setup info from the UI extension will be supplied.

}

- (void)broadcastPaused {
    // User has requested to pause the broadcast. Samples will stop being delivered.
}

- (void)broadcastResumed {
    // User has requested to resume the broadcast. Samples delivery will resume.
}

- (void)broadcastFinished {
    // User has requested to finish the broadcast.
}

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer withType:(RPSampleBufferType)sampleBufferType {
    
    switch (sampleBufferType) {
        case RPSampleBufferTypeVideo:
//             Handle audio sample buffer
//            NSLog(@"请将此处的视频流推到服务器上");
            [[BroadcastManager sharedBroadcastManager] pushVideoSampleBuffer:sampleBuffer];
            break;
        case RPSampleBufferTypeAudioApp:
//            NSLog(@"请将此处的程序输出音频流推到服务器上");
            // Handle audio sample buffer for app audio
            [[BroadcastManager sharedBroadcastManager] pushAudioSampleBuffer:sampleBuffer withChannelID:kPLAudioChannelApp];
            break;
        case RPSampleBufferTypeAudioMic:
//            NSLog(@"请将此处的麦克风音频流推到服务器上");
            // Handle audio sample buffer for mic audio
            [[BroadcastManager sharedBroadcastManager] pushAudioSampleBuffer:sampleBuffer withChannelID:kPLAudioChannelMic];
            break;
            
        default:
            NSLog(@"没有这个type呀呀呀呀呀呀呀呀呀呀");
            break;
    }
}

@end
