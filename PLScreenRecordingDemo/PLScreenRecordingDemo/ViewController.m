//
//  ViewController.m
//  PLScreenRecordingDemo
//
//  Created by 何昊宇 on 16/10/26.
//  Copyright © 2016年 Aaron. All rights reserved.
//

#import "ViewController.h"
#import <AVKit/AVKit.h>

@interface ViewController ()<RPPreviewViewControllerDelegate,RPScreenRecorderDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, weak) UILabel *timeLable;
@property (nonatomic, weak) UIButton *startBtn;
@property (nonatomic, weak) UIButton *stopBtn;

@property RPBroadcastController *broadcastController;
@property RPBroadcastActivityViewController * broadcastAVC;
@end

static int count = 0;


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerCallBack) userInfo:nil repeats:YES];
    
    [self setUpNetworkCheck];
    [self setupUI];
    
    
}


- (void)timerCallBack
{
    count++;
    self.timeLable.text = [NSString stringWithFormat:@"%3d",count];
}

-(void)setUpNetworkCheck{
    UILabel *lable1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 350, self.view.frame.size.width, 30)];
    [lable1 setText:@"↓下面这个webview为空白表示网络异常↓"];
    [self.view addSubview:lable1];
    
    UIWebView *webview = [[UIWebView alloc] initWithFrame:CGRectMake(0, 380, self.view.frame.size.width, self.view.frame.size.height-380)];
    [webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://m.baidu.com/"]]];
    [self.view addSubview:webview];
    
    UILabel *lable = [[UILabel alloc] init];
    self.timeLable = lable;
    lable.textAlignment = NSTextAlignmentCenter;
    lable.backgroundColor = [UIColor purpleColor];
    lable.textColor = [UIColor blackColor];
    lable.text = @"0000";
    [lable sizeToFit];
    [self.view addSubview:lable];
    lable.center = self.view.center;
}

- (void)setupUI
{
    UIButton *start = [UIButton buttonWithType:UIButtonTypeCustom];
    self.startBtn = start;
    [self.view addSubview:start];
    [start setTitle:@"开始录制" forState:UIControlStateNormal];
    start.backgroundColor = [UIColor yellowColor];
    start.frame = CGRectMake(0, 0, 150, 100);
    [start addTarget:self action:@selector(startClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *stop = [UIButton buttonWithType:UIButtonTypeCustom];
    self.stopBtn = stop;
    [self.view addSubview:stop];
    [stop setTitle:@"停止录制" forState:UIControlStateNormal];
    stop.frame = CGRectMake(0, 100, 150, 100);
    stop.backgroundColor = [UIColor redColor];
    [stop addTarget:self action:@selector(stopClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.startBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    
}

- (void)startClicked:(UIButton *)btn
{
    [RPBroadcastActivityViewController loadBroadcastActivityViewControllerWithHandler:^(RPBroadcastActivityViewController * _Nullable broadcastActivityViewController, NSError * _Nullable error) {
        if (error) {
            NSLog(@"start broadcastActivityViewController error - %@",error);
        }
        self.broadcastAVC = broadcastActivityViewController;
        self.broadcastAVC.delegate = self;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.broadcastAVC.modalPresentationStyle = UIModalPresentationFormSheet;
        }
        [self presentViewController:self.broadcastAVC animated:YES completion:^{
            NSLog(@"弹出成功");
        }];
        
        
        
    }];
    
    
}

- (void)stopClicked:(UIButton *)btn
{
    
    if(_broadcastController){// && [_broadcastController isBroadcasting])
        [_broadcastController finishBroadcastWithHandler:^(NSError * _Nullable error) {
            [_startBtn setTitle:@"开始直播" forState:UIControlStateNormal];
        }];
    }
    
}

- (void)previewControllerDidFinish:(RPPreviewViewController *)previewController
{
    NSLog(@"previewControllerDidFinish"  );
    [previewController dismissViewControllerAnimated:YES completion:nil];
}

/* @abstract Called when the view controller is finished and returns a set of activity types that the user has completed on the recording. The built in activity types are listed in UIActivity.h. */
- (void)previewController:(RPPreviewViewController *)previewController didFinishWithActivityTypes:(NSSet <NSString *> *)activityTypes
{
    NSLog(@"activity - %@",activityTypes);
}

-(void)broadcastController:(RPBroadcastController *)broadcastController didFinishWithError:(NSError *)error{
    NSLog(@"broadcastController:didFinishWithError"  );
    
}

-(void)screenRecorder:(RPScreenRecorder *)screenRecorder didStopRecordingWithError:(NSError *)error previewViewController:(RPPreviewViewController *)previewViewController{
    NSLog(@"didStopRecordingWithError: %@", error);
}


-(void)broadcastController:(RPBroadcastController *)broadcastController didUpdateServiceInfo:(NSDictionary<NSString *,NSObject<NSCoding> *> *)serviceInfo{
    NSLog(@"broadcastController didUpdateServiceInfo: %@", serviceInfo);
}

-(void)broadcastActivityViewController:(RPBroadcastActivityViewController *)broadcastActivityViewController didFinishWithBroadcastController:(RPBroadcastController *)broadcastController error:(NSError *)error{
    NSLog(@"broadcastActivityViewController"  );

    [broadcastActivityViewController dismissViewControllerAnimated:YES completion:NULL];
    self.broadcastController = broadcastController;
    if (error)
    {
        NSLog(@"    error=%@", error);
        return;
    }
    
    NSLog(@"    broadcastController.broadcasting=%d", broadcastController.broadcasting);
    NSLog(@"    broadcastController.paused=%d", broadcastController.paused);
    NSLog(@"    broadcastController.broadcastURL=%@", broadcastController.broadcastURL);
    NSLog(@"    broadcastController.serviceInfo=%@", broadcastController.serviceInfo);
    NSLog(@"    broadcastController.broadcastExtensionBundleID=%@", broadcastController.broadcastExtensionBundleID);
    
    [[RPScreenRecorder sharedRecorder] setCameraEnabled:YES];
    [[RPScreenRecorder sharedRecorder] setMicrophoneEnabled:YES];
    [[RPScreenRecorder sharedRecorder] setDelegate:self];
    broadcastController.delegate = self;
   
   
    void (^permissionBlock)(void) = ^{
    NSLog(@"    正在初始化....."  );
    [self.startBtn setTitle:@"正在初始化…" forState:UIControlStateNormal];
    
    [broadcastController startBroadcastWithHandler:^(NSError * _Nullable error) {
        if (!error) {
            NSLog(@"    直播中....."  );
            [self.startBtn setTitle:@"直播中" forState:UIControlStateNormal];
             dispatch_async(dispatch_get_main_queue(), ^{
                  UIView *cameraPreviewView =  [[RPScreenRecorder sharedRecorder] cameraPreviewView];
            [cameraPreviewView setFrame:CGRectMake(100, 100, cameraPreviewView.frame.size.width, cameraPreviewView.frame.size.height)];
            [self.view addSubview:cameraPreviewView];
            
            UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]
                                                            initWithTarget:self
                                                            action:@selector(handlePan:)];
            [cameraPreviewView addGestureRecognizer:panGestureRecognizer];
             });
            
        } else {
            NSLog(@"    直播失败：%@", [error description]);
        }
    }];
    };
    
    void (^noAccessBlock)(void) = ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Access", nil)
                                                            message:NSLocalizedString(@"!", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
    };
    
    switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]) {
        case AVAuthorizationStatusAuthorized:
            permissionBlock();
            break;
        case AVAuthorizationStatusNotDetermined: {
            [self requestDeviceAccessWithCompletionHandler:^(BOOL granted) {
                granted ? permissionBlock() : noAccessBlock();
            }];
        }
            break;
        default:
            noAccessBlock();
            break;
    }
}

- (void)requestDeviceAccessWithCompletionHandler:(void (^)(BOOL granted))handler {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if (handler) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                handler(granted);
            });
        }
    }];
}

- (void)handlePan:(UIPanGestureRecognizer*)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint location = [recognizer locationInView:self.view];
        NSLog(@"location=%@", NSStringFromCGPoint(location));
        if ([self view:recognizer.view isInRootView:self.view location:location])
        {
            recognizer.view.center = location;
        } else {
            NSLog(@"is NOT inRootView");
        }
    }
}

- (BOOL)view:(UIView *)view isInRootView:(UIView *)rootView location:(CGPoint)location
{
    CGFloat DEFAULT_SCREEN_DISTANCE = 10;
    if ((location.x - view.frame.size.width * 0.5 > DEFAULT_SCREEN_DISTANCE &&
         location.x + view.frame.size.width * 0.5 < rootView.frame.size.width - DEFAULT_SCREEN_DISTANCE) &&
        location.y - view.frame.size.height * 0.5 > DEFAULT_SCREEN_DISTANCE &&
        location.y + view.frame.size.height * 0.5 < rootView.frame.size.height - DEFAULT_SCREEN_DISTANCE)
    {
        return YES;
    }
    
    return NO;
}



@end
