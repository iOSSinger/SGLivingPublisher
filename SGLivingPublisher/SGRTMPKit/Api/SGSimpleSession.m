//
//  SGSimpleSession.m
//  SGLivingPublisher
//
//  Created by iossinger on 16/7/3.
//  Copyright © 2016年 iossinger. All rights reserved.
//

#import "SGSimpleSession.h"
#import "SGRtmpSession.h"
#import "SGRtmpConfig.h"

#import "SGVideoSource.h"
#import "SGH264Encoder.h"
#import "SGH264Packager.h"

#import "SGAudioSource.h"
#import "SGAACEncoder.h"
#import "SGAACPackager.h"


#define NOW (CACurrentMediaTime()*1000)

@interface SGSimpleSession()<SGRtmpSessionDeleagte,SGVideoSourceDelegate,SGH264EncoderDeleagte,SGH264PackagerDelegate,SGAudioSourceDelegate,SGAACEncoderDeleagte,SGAACPackagerDelegate>
{
    uint64_t _startTime;
    /**
     *  是否可以发送数据
     */
    BOOL     _sendable;
}
@property (nonatomic,strong) SGRtmpSession  *rtmpSession;

@property (nonatomic,strong) SGVideoSource  *videoSource;
@property (nonatomic,strong) SGH264Encoder  *h264Encoder;
@property (nonatomic,strong) SGH264Packager *h264Packager;

@property (nonatomic,strong) SGAudioSource  *audioSource;
@property (nonatomic,strong) SGAACEncoder   *aacEncoder;
@property (nonatomic,strong) SGAACPackager  *aacPackager;

@end


@implementation SGSimpleSession
- (instancetype)init{
    if (self = [super init]) {
        _state = SGSimpleSessionStateNone;
        _sendable = NO;
    }
    return self;
}

- (void)dealloc{
    [self endSession];
    
    self.delegate = nil;
    self.videoSource = nil;
    self.audioSource = nil;
}

+ (instancetype)defultSession{
    SGSimpleSession *session = [[self alloc] init];
    return session;
}
- (void)setVideoConfig:(SGVideoConfig *)videoConfig{
    _videoConfig = videoConfig;
    self.videoSource.config = videoConfig;
    self.h264Encoder.config =  videoConfig;
    [self.videoSource startVideoCapture];
    
    _preview = [[UIView alloc] init];
    //kvc 赋值layer
    [_preview setValue:self.videoSource.preLayer forKey:@"_layer"];
}
- (void)setAudioConfig:(SGAudioConfig *)audioConfig{
    _audioConfig = audioConfig;
    self.audioSource.config = audioConfig;
    self.aacEncoder.audioConfig = audioConfig;
    self.aacPackager.config = audioConfig;
    [self.audioSource start];
}
#pragma mark- ------lazyLoad-------------------

- (SGRtmpSession *)rtmpSession{
    if (_rtmpSession == nil) {
        _rtmpSession = [[SGRtmpSession alloc] init];
        _rtmpSession.delegate = self;
        SGRtmpConfig *config = [[SGRtmpConfig alloc] init];
        config.url = self.url;
        config.width = self.videoConfig.videoSize.width;
        config.height = self.videoConfig.videoSize.height;
        config.frameDuration = 1.0 / self.videoConfig.fps;
        config.videoBitrate = self.videoConfig.bitrate;
        config.audioSampleRate = self.audioConfig.sampleRate;
        config.stereo = self.audioConfig.channels == 2;
        _rtmpSession.config = config;
    }
    return _rtmpSession;
}

- (SGVideoSource *)videoSource{
    if (_videoSource == nil) {
        _videoSource = [[SGVideoSource alloc] init];
        _videoSource.delegate = self;
    }
    return _videoSource;
}

-(SGH264Encoder *)h264Encoder{
    if (_h264Encoder == nil) {
        _h264Encoder = [[SGH264Encoder alloc] init];
        _h264Encoder.delegate = self;
    }
    return _h264Encoder;
}
- (SGH264Packager *)h264Packager{
    if (_h264Packager == nil) {
        _h264Packager = [[SGH264Packager alloc] init];
        _h264Packager.delegate = self;
    }
    return _h264Packager;
}

- (SGAudioSource *)audioSource{
    if (_audioSource == nil) {
        _audioSource = [[SGAudioSource alloc] init];
        _audioSource.delegate = self;
    }
    return _audioSource;
}
- (SGAACEncoder *)aacEncoder{
    if (_aacEncoder == nil) {
        _aacEncoder = [[SGAACEncoder alloc] init];
        _aacEncoder.delegate = self;
    }
    return _aacEncoder;
}

- (SGAACPackager *)aacPackager{
    if (_aacPackager == nil) {
        _aacPackager = [[SGAACPackager alloc] init];
        _aacPackager.delegate = self;
    }
    return _aacPackager;
}

#pragma mark- ------control-------------------

- (void)startSession{
    [self.rtmpSession connect];
}

- (void)endSession{
    _state = SGSimpleSessionStateEnd;
    _sendable = NO;
    [self.rtmpSession disConnect];
    [self.aacPackager reset];
    [self.h264Packager reset];
    //传给外层
    if ([self.delegate respondsToSelector:@selector(simpleSession:statusDidChanged:)]) {
        [self.delegate simpleSession:self statusDidChanged:_state];
    }
}

#pragma mark- ------SGRtmpSessionDeleagte-------------------
- (void)rtmpSession:(SGRtmpSession *)rtmpSession didChangeStatus:(SGRtmpSessionStatus)rtmpStatus{
    switch (rtmpStatus) {
        case SGRtmpSessionStatusConnected:
        {
            _state = SGSimpleSessionStateConnecting;
        }
            break;
        case SGRtmpSessionStatusSessionStarted:
        {
            _startTime = NOW;
            _sendable = YES;
            _state = SGSimpleSessionStateConnected;
        }
            
            break;
        case SGRtmpSessionStatusNotConnected:
        {
            _state = SGSimpleSessionStateEnd;
            [self endSession];
        }
            break;
        case SGRtmpSessionStatusError:
        {
            _state = SGSimpleSessionStateError;
            [self endSession];
        }
            break;
        default:
            break;
    }

    if ([self.delegate respondsToSelector:@selector(simpleSession:statusDidChanged:)]) {
        [self.delegate simpleSession:self statusDidChanged:_state];
    }
}
#pragma mark- ------SGVideoSourceDelegate-------------------
- (void)videoSource:(SGVideoSource *)source didOutputSampleBuffer:(CVPixelBufferRef)pixelBuffer{
    
    if (!_sendable) {
        return;
    }
    [self.h264Encoder encodeVideoData:pixelBuffer timeStamp:self.currentTimestamp];
}
#pragma mark- ------SGH264EncoderDeleagte-------------------
- (void)h264Encoder:(SGH264Encoder *)encoder didGetSps:(NSData *)spsData pps:(NSData *)ppsData timestamp:(uint64_t)timestamp{
    if (!_sendable) {
        return;
    }
    
    [self.h264Packager packageKeyFrameSps:spsData pps:ppsData timestamp:timestamp];
}
- (void)h264Encoder:(SGH264Encoder *)encoder didEncodeFrame:(NSData *)data timestamp:(uint64_t)timestamp isKeyFrame:(BOOL)isKeyFrame{
    if (!_sendable) {
        return;
    }
    [self.h264Packager packageFrame:data timestamp:timestamp isKeyFrame:isKeyFrame];
}
#pragma mark- ------SGH264PackagerDelegate-------------------
-(void)h264Packager:(SGH264Packager *)packager didPacketFrame:(SGFrame *)frame{
    if (!_sendable) {
        return;
    }
    if (_rtmpSession) {
       [self.rtmpSession sendBuffer:frame];
    }
}


#pragma mark- ------audioSourceDelegate-------------------
- (void)audioSource:(SGAudioSource *)source didOutputAudioBufferList:(AudioBufferList)bufferList{
    if (!_sendable) {
        return;
    }
    [self.aacEncoder encodeData:bufferList timestamp:self.currentTimestamp];
}
#pragma mark- ------SGAACEncoderDeleagte-------------------
- (void)aacEncoder:(SGAACEncoder *)encoder didEncodeBuffer:(NSData *)data timestamp:(uint64_t)timestamp{
    if (!_sendable) {
        return;
    }
    [self.aacPackager packageAudioData:data timestamp:timestamp];
}

#pragma mark- ------SGAACPackagerDelegate-------------------
- (void)aacPackager:(SGAACPackager *)packager didPackageAudioFrame:(SGFrame *)frame{
    if (!_sendable) {
        return;
    }
    if (_rtmpSession) {
       [self.rtmpSession sendBuffer:frame];
    }
}

#pragma mark- ------Other-------------------
- (uint64_t)currentTimestamp{
    return NOW - _startTime;
}
@end
