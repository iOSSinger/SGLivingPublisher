//
//  SGAudioConfigModel.h
//  SGLivingPublisher
//
//  Created by iossinger on 16/6/15.
//  Copyright © 2016年 iossinger. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  音频码率
 */
typedef NS_ENUM(NSUInteger, SGAudioBitRate) {
    SGAudioBitRate_32Kbps  = 32000 ,
    SGAudioBitRate_64Kbps  = 64000 ,
    SGAudioBitRate_96Kbps  = 96000 ,
    SGAudioBitRate_128Kbps = 128000,
    SGAudioBitRate_Default = 64000//默认64Kbps
};

/**
 *  采样率
 */
typedef NS_ENUM(NSUInteger, SGAudioSampleRate) {
    SGAudioSampleRate_44100Hz = 44100,
    SGAudioSampleRate_48000Hz = 48000,
    SGAudioSampleRate_Defalut = 44100//默认44100
};


@interface SGAudioConfig : NSObject
/**
 *  声道数
 */
@property (nonatomic,assign) NSUInteger channels;
/**
 *  码率
 */
@property (nonatomic,assign) SGAudioBitRate bitRate;
/**
 *  采样率
 */
@property (nonatomic,assign) SGAudioSampleRate sampleRate;
/**
 *  默认配置
 */
+ (instancetype)defaultConfig;
@end
