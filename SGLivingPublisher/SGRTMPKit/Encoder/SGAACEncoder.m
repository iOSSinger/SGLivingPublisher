//
//  SGAACEncoder.m
//  SGLivingPublisher
//
//  Created by iossinger on 16/6/22.
//  Copyright © 2016年 iossinger. All rights reserved.
//

#import "SGAACEncoder.h"

@interface SGAACEncoder()
{
    AudioConverterRef _converter;
}

@end

@implementation SGAACEncoder


- (AudioConverterRef)converter{
    if (_converter == nil) {
        [self creatAudioConvert];
    }
    return _converter;
}

- (void)creatAudioConvert{
    
    AudioStreamBasicDescription inputFormat = {0};
    inputFormat.mSampleRate = self.audioConfig.sampleRate;
    inputFormat.mFormatID = kAudioFormatLinearPCM;//输入格式为pcm
    inputFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked;
    inputFormat.mChannelsPerFrame = (UInt32)self.audioConfig.channels;
    inputFormat.mFramesPerPacket = 1;
    inputFormat.mBitsPerChannel = 16;
    inputFormat.mBytesPerFrame = inputFormat.mBitsPerChannel / 8 * inputFormat.mChannelsPerFrame;
    inputFormat.mBytesPerPacket = inputFormat.mBytesPerFrame * inputFormat.mFramesPerPacket;
    
    AudioStreamBasicDescription outputFormat;
    memset(&outputFormat, 0, sizeof(outputFormat));
    outputFormat.mSampleRate       = inputFormat.mSampleRate;
    outputFormat.mFormatID         = kAudioFormatMPEG4AAC;    // AAC编码 kAudioFormatMPEG4AAC kAudioFormatMPEG4AAC_HE_V2
    outputFormat.mChannelsPerFrame = (UInt32)self.audioConfig.channels;;
    outputFormat.mFramesPerPacket  = 1024;
    const OSType subtype = kAudioFormatMPEG4AAC;
    AudioClassDescription requestedCodecs[2] = {
        {
            kAudioEncoderComponentType,
            subtype,
            kAppleSoftwareAudioCodecManufacturer
        },
        {
            kAudioEncoderComponentType,
            subtype,
            kAppleHardwareAudioCodecManufacturer
        }
    };
    
    OSStatus result = AudioConverterNewSpecific(&inputFormat, &outputFormat, 2, requestedCodecs, &_converter);
    
    if (result == noErr) {
        NSLog(@"creat convert success!");
    }else{
        NSLog(@"creat convert error!");
        _converter = nil;
    }
}

- (void)encodeData:(AudioBufferList)inBufferList timestamp:(uint64_t)timestamp{
    if (!self.converter) {
        return;
    }
    int size = inBufferList.mBuffers[0].mDataByteSize;
    
    if (size <= 0) {
        return;
    }
    
    char *aacBuf = malloc(size);
    
    // 初始化一个输出缓冲列表
    AudioBufferList outBufferList;
    outBufferList.mNumberBuffers              = 1;
    outBufferList.mBuffers[0].mNumberChannels = inBufferList.mBuffers[0].mNumberChannels;
    outBufferList.mBuffers[0].mDataByteSize   = inBufferList.mBuffers[0].mDataByteSize; // 设置缓冲区大小
    outBufferList.mBuffers[0].mData           = aacBuf; // 设置AAC缓冲区
    UInt32 outputDataPacketSize               = 1;
    if (AudioConverterFillComplexBuffer(_converter, inputDataProc, &inBufferList, &outputDataPacketSize, &outBufferList, NULL) != noErr){
        return;
    }
    
    int outsize = outBufferList.mBuffers[0].mDataByteSize;
    NSData *data = [NSData dataWithBytes:aacBuf length:outsize];
    free(aacBuf);
    
    //第一帧af00 + 2字节 +数据
    //后面  af01 + 去掉7字节头
    if ([self.delegate respondsToSelector:@selector(aacEncoder:didEncodeBuffer:timestamp:)]) {
        [self.delegate aacEncoder:self didEncodeBuffer:data timestamp:timestamp];
    }
}

#pragma mark -- AudioCallBack
OSStatus inputDataProc(AudioConverterRef inConverter, UInt32 *ioNumberDataPackets, AudioBufferList *ioData,AudioStreamPacketDescription **outDataPacketDescription, void *inUserData) {
    //编码过程中，会要求这个函数来填充输入数据，也就是原始PCM数据
    AudioBufferList bufferList = *(AudioBufferList*)inUserData;
    ioData->mBuffers[0].mNumberChannels = 1;
    ioData->mBuffers[0].mData           = bufferList.mBuffers[0].mData;
    ioData->mBuffers[0].mDataByteSize   = bufferList.mBuffers[0].mDataByteSize;
    return noErr;
}
@end
