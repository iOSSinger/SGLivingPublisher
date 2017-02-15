//
//  SGVideoSource.m
//  SGLivingPublisher
//
//  Created by iossinger on 16/6/13.
//  Copyright © 2016年 iossinger. All rights reserved.
//

#import "SGVideoSource.h"
#import <AVFoundation/AVFoundation.h>

@interface SGVideoSource ()<AVCaptureVideoDataOutputSampleBufferDelegate>
{
    dispatch_queue_t _videoQueue;
}

@property (nonatomic,strong) AVCaptureSession *session;
@property (nonatomic,strong) AVCaptureDevice *videoDevice;
@property (nonatomic,strong) AVCaptureDeviceInput *vdeoInput;
@property (nonatomic,strong) AVCaptureConnection *videoConnection;
@property (nonatomic,strong) AVCaptureVideoDataOutput *videoDataOutput;

@end


@implementation SGVideoSource
- (void)dealloc{
    NSLog(@"%s",__func__);
}
- (instancetype)init{
    if (self = [super init]) {
        
        [self setVideoCapture];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseCameraCapture) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeCameraCapture) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

/**
 *  预览
 */
- (AVCaptureVideoPreviewLayer *)preLayer{
    if (_preLayer == nil) {
        _preLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        _preLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _preLayer;
}

//视频会话
- (void)setVideoCapture{
    
    self.session = [[AVCaptureSession alloc] init];
    
    //设置摄像头的分辨率640*480
    if ([self.session canSetSessionPreset:AVCaptureSessionPreset640x480]) {
        self.session.sessionPreset = AVCaptureSessionPreset640x480;
    }
    
    self.videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //自动变焦
    if([self.videoDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]){
        if([self.videoDevice lockForConfiguration:nil]){
            self.videoDevice.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        }
    }
    
    //输入
    self.vdeoInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.videoDevice error:nil];
    if([self.session canAddInput:self.vdeoInput]){
        [self.session addInput:self.vdeoInput];
    }
    
    //输出设置
    self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    
    //kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange 表示原始数据的格式为YUV420
    NSDictionary *settings = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange], kCVPixelBufferPixelFormatTypeKey, nil];
    self.videoDataOutput.videoSettings = settings;
    self.videoDataOutput.alwaysDiscardsLateVideoFrames = YES;
    
    _videoQueue = dispatch_queue_create("VideoQueue", DISPATCH_QUEUE_SERIAL);
    
    [self.videoDataOutput setSampleBufferDelegate:self queue:_videoQueue];
    
    if([self.session canAddOutput:self.videoDataOutput]){
        [self.session addOutput:self.videoDataOutput];
    }
    
    self.videoConnection = [self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
    
    //设置输出图像的方向
    self.videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
}

#pragma mark- ------------------control------------------------
//开始
- (void)startVideoCapture{
    [self.session startRunning];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}
//停止
- (void)stopVideoCapture{
    [self.session stopRunning];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

//进入后台暂停
- (void)pauseCameraCapture{
    [self.session stopRunning];
}
//进入前台开始
- (void)resumeCameraCapture{
    [self.session startRunning];
}

- (void)setConfig:(SGVideoConfig *)config{
    _config = config;
    NSLog(@"video config is %@",config);
    
    //设置帧速
    NSError *error;
    [self.videoDevice lockForConfiguration:&error];
    
    if (error == nil) {
        NSLog(@"支持的帧速范围是: %@",[self.videoDevice.activeFormat.videoSupportedFrameRateRanges objectAtIndex:0]);
        
        if (self.videoDevice.activeFormat.videoSupportedFrameRateRanges){
            [self.videoDevice setActiveVideoMinFrameDuration:CMTimeMake(1, config.fps)];
            [self.videoDevice setActiveVideoMaxFrameDuration:CMTimeMake(1, config.fps)];
        }
    }
    
    [self.videoDevice unlockForConfiguration];
}

#pragma mark - delegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    CVPixelBufferRef pixelBufferRef = CMSampleBufferGetImageBuffer(sampleBuffer);
    if ([self.delegate respondsToSelector:@selector(videoSource:didOutputSampleBuffer:)]) {
        [self.delegate videoSource:self didOutputSampleBuffer:pixelBufferRef];
    }
}
@end
