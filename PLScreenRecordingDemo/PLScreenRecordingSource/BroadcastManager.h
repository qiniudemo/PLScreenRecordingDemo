//
//  BroadcastManager.h
//  PLScreenRecordingDemo
//
//  Created by 何昊宇 on 16/10/27.
//  Copyright © 2016年 Aaron. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <PLMediaStreamingKit/PLStreamingKit.h>

@interface BroadcastManager : NSObject

@property (nonatomic, strong) PLStreamingSession *session;

+ (instancetype)sharedBroadcastManager;
- (PLStreamState)streamState;
- (void)pushVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer;
- (void)pushAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer withChannelID:(const NSString *)channelID;

@end
