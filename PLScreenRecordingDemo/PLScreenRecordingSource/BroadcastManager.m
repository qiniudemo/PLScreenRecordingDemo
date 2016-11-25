//
//  BroadcastManager.m
//  PLScreenRecordingDemo
//
//  Created by 何昊宇 on 16/10/27.
//  Copyright © 2016年 Aaron. All rights reserved.
//

#import "BroadcastManager.h"
#define kDeviceWidth [UIScreen mainScreen].bounds.size.width        //屏幕宽
#define KDeviceHeight [UIScreen mainScreen].bounds.size.height      //屏幕高

@interface BroadcastManager()<PLStreamingSessionDelegate>

@end

@implementation BroadcastManager

static BroadcastManager *_instance;

- (instancetype)init
{
    if (self = [super init]) {
        [PLStreamingEnv initEnv];
        CGSize videoSize = CGSizeMake(kDeviceWidth, KDeviceHeight);
        PLVideoStreamingConfiguration *videoConfiguration = [[PLVideoStreamingConfiguration alloc] initWithVideoSize:videoSize expectedSourceVideoFrameRate:24 videoMaxKeyframeInterval:24*3 averageVideoBitRate:1000*1024 videoProfileLevel:AVVideoProfileLevelH264High41];
        PLAudioStreamingConfiguration *audioConfiguration = [PLAudioStreamingConfiguration defaultConfiguration];
        audioConfiguration.inputAudioChannelDescriptions = @[kPLAudioChannelApp, kPLAudioChannelMic];
        
        self.session = [[PLStreamingSession alloc] initWithVideoStreamingConfiguration:videoConfiguration
                                                           audioStreamingConfiguration:audioConfiguration
                                                                                stream:nil];
        self.session.delegate = self;
#warning 以下 pushURL 需替换为一个真实的流地址
        NSString *pushURL = @"你的推流地址";
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.session startWithPushURL:[NSURL URLWithString:pushURL] feedback:^(PLStreamStartStateFeedback feedback) {
                if (PLStreamStartStateSuccess == feedback) {
                    NSLog(@"connect success");
                } else {
                    NSLog(@"connect failed");
                }
            }];
        });
    }
    return self;
}

+ (void)initialize
{
    _instance = [[BroadcastManager alloc] init];
}

- (PLStreamState)streamState
{
    return self.session.streamState;
}

- (void)pushVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    [self.session pushVideoSampleBuffer:sampleBuffer];
}

- (void)pushAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer withChannelID:(const NSString *)channelID
{
    [self.session pushAudioSampleBuffer:sampleBuffer withChannelID:channelID completion:nil];
}

+ (instancetype)sharedBroadcastManager
{
    return _instance;
}

// 实现其他必要的协议方法

- (void)streamingSession:(PLStreamingSession *)session didDisconnectWithError:(NSError *)error
{
    NSLog(@"error : %@", error);
}

- (void)streamingSession:(PLStreamingSession *)session streamStatusDidUpdate:(PLStreamStatus *)status
{
    NSLog(@"%@", status);
}


@end
