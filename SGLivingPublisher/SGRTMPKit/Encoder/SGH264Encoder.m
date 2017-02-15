//
//  SGH264Encoder.m
//  SGLivingPublisher
//
//  Created by iossinger on 16/6/21.
//  Copyright © 2016年 iossinger. All rights reserved.
//

#import "SGH264Encoder.h"
#import <VideoToolbox/VideoToolbox.h>


@interface SGH264Encoder()
{
    VTCompressionSessionRef _compressionSession;
    NSInteger frameCount;
}
@end


@implementation SGH264Encoder

- (void)stopEncoder{
    if (_compressionSession != nil) {
        VTCompressionSessionCompleteFrames(_compressionSession, kCMTimeInvalid);
        VTCompressionSessionInvalidate(_compressionSession);
        CFRelease(_compressionSession);
        _compressionSession = NULL;
    }
}

- (void)setConfig:(SGVideoConfig *)config{
    _config = config;
    [self initCompressionSession];
}

- (void)initCompressionSession{
    
    if(_compressionSession){
        VTCompressionSessionCompleteFrames(_compressionSession, kCMTimeInvalid);
        
        VTCompressionSessionInvalidate(_compressionSession);
        CFRelease(_compressionSession);
        _compressionSession = NULL;
    }
    
    OSStatus status = VTCompressionSessionCreate(NULL, _config.videoSize.width, _config.videoSize.height, kCMVideoCodecType_H264, NULL, NULL, NULL, didCompressBuffer, (__bridge void *)self, &_compressionSession);
    if(status != noErr){
        return;
    }
    
    VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_MaxKeyFrameInterval,(__bridge CFTypeRef)@(_config.fps*2));
    VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_MaxKeyFrameIntervalDuration,(__bridge CFTypeRef)@(_config.fps*2));
    
    VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_AverageBitRate, (__bridge CFTypeRef)@(_config.bitrate));
    NSArray *limit = @[@(_config.bitrate * 1.5/8),@(1)];
    VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_DataRateLimits, (__bridge CFArrayRef)limit);
    
    VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_ExpectedFrameRate, (__bridge CFTypeRef)@(self.config.fps));
    VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_RealTime, kCFBooleanFalse);
    VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_ProfileLevel, kVTProfileLevel_H264_Baseline_AutoLevel);
    
    VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_AllowFrameReordering, kCFBooleanFalse);
    //16:9
    VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_AspectRatio16x9, kCFBooleanTrue);
    
    VTCompressionSessionPrepareToEncodeFrames(_compressionSession);
}

- (void)encodeVideoData:(CVPixelBufferRef)pixelBuffer timeStamp:(uint64_t)timeStamp{
    
    frameCount ++;
    CMTime presentationTimeStamp = CMTimeMake(frameCount, 1000);
    VTEncodeInfoFlags flags;
    CMTime duration = CMTimeMake(1, self.config.fps);
    
    NSDictionary *properties = nil;
    if(frameCount % (int32_t)(self.config.keyframeInterval) == 0){//强制关键帧
        properties = @{(__bridge NSString *)kVTEncodeFrameOptionKey_ForceKeyFrame: @YES};
    }
    
    NSNumber *timeNumber = @(timeStamp);
    VTCompressionSessionEncodeFrame(_compressionSession, pixelBuffer, presentationTimeStamp, duration, (__bridge CFDictionaryRef)properties, (__bridge void *)timeNumber, &flags);
    
}

static void didCompressBuffer(void *VTref, void *VTFrameRef, OSStatus status, VTEncodeInfoFlags infoFlags, CMSampleBufferRef sampleBuffer)
{
    SGH264Encoder *bself = (__bridge SGH264Encoder *)VTref;
    uint64_t timeStamp = [((__bridge_transfer NSNumber*)VTFrameRef) longLongValue];
    CMBlockBufferRef block = CMSampleBufferGetDataBuffer(sampleBuffer);
    CFArrayRef attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, false);
    
    //    CMTime pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    //    CMTime dts = CMSampleBufferGetDecodeTimeStamp(sampleBuffer);
    
    bool isKeyframe = NO;
    if(attachments != NULL) {
        CFDictionaryRef attachment;
        CFBooleanRef dependsOnOthers;
        attachment = (CFDictionaryRef)CFArrayGetValueAtIndex(attachments, 0);
        dependsOnOthers = (CFBooleanRef)CFDictionaryGetValue(attachment, kCMSampleAttachmentKey_DependsOnOthers);
        isKeyframe = (dependsOnOthers == kCFBooleanFalse);
    }
    
    if(isKeyframe) {
        
        // Send the SPS and PPS.
        CMFormatDescriptionRef format = CMSampleBufferGetFormatDescription(sampleBuffer);
        size_t spsSize, ppsSize;
        size_t parmCount;
        const uint8_t* sps, *pps;
        
        CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, 0, &sps, &spsSize, &parmCount, NULL );
        CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, 1, &pps, &ppsSize, &parmCount, NULL );
        
        NSData *spsData = [NSData dataWithBytes:sps length:spsSize];
        NSData *ppsData = [NSData dataWithBytes:pps length:ppsSize];
        //sps pps 无分隔符
        if ([bself.delegate respondsToSelector:@selector(h264Encoder:didGetSps:pps:timestamp:)]) {
            [bself.delegate h264Encoder:bself didGetSps:spsData pps:ppsData timestamp:timeStamp];
        }
    }
    
    char  *buffer;
    size_t total;
    //前4个字节表示长度后面的数据的长度
    //除了关键帧,其它帧只有一个数据
    CMBlockBufferGetDataPointer(block, 0, NULL, &total, &buffer);
    size_t offset = 0;
    int const headLen = 4;

    while (offset < total - headLen) {
        int NALUnitLength = 0;
        memcpy(&NALUnitLength, buffer + offset, headLen);
        
        NALUnitLength = CFSwapInt32BigToHost(NALUnitLength);
        NSData *data = [NSData dataWithBytes:buffer+headLen+offset length:NALUnitLength];
        offset += headLen + NALUnitLength;
        if ([bself.delegate respondsToSelector:@selector(h264Encoder:didEncodeFrame:timestamp:isKeyFrame:)]) {
            [bself.delegate h264Encoder:bself didEncodeFrame:data timestamp:timeStamp isKeyFrame:isKeyframe];
        }
    }
}
@end
