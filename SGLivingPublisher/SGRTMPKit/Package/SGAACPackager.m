//
//  SGAACPackager.m
//  SGLivingPublisher
//
//  Created by iossinger on 16/7/4.
//  Copyright © 2016年 iossinger. All rights reserved.
//

#import "SGAACPackager.h"
#import "SGRtmpTypes.h"


@interface SGAACPackager()
{
    char asc[2];
    char header[2];
    BOOL _hasSentAsc;
}
@end

@implementation SGAACPackager
- (void)dealloc{
    self.delegate = nil;
}

- (instancetype)init{
    if (self = [super init]) {
        _hasSentAsc = NO;
    }
    return self;
}
- (void)reset{
    _hasSentAsc = NO;
}
- (void)packageAudioData:(NSData *)data timestamp:(uint64_t)timestamp{
    SGFrame *frame = [[SGFrame alloc] init];
    
    NSMutableData *dataM = [NSMutableData data];
    if (!_hasSentAsc) {
        _hasSentAsc = YES;
        //send header
        header[0] = 0xAF;
        header[1] = 0x00;
        [dataM appendBytes:header length:2];
        [dataM appendBytes:asc length:2];
    }else{
        header[0] = 0xAF;
        header[1] = 0x01;
        [dataM appendBytes:header length:2];
        [dataM appendData:data];
    }
    
    frame.data = dataM;
    frame.timestamp = (int)timestamp;
    frame.msgLength = (int)dataM.length;
    frame.msgTypeId = SGMSGTypeID_AUDIO;
    frame.msgStreamId = SGStreamIDAudio;
    frame.isKeyframe = NO;
    
    if ([self.delegate respondsToSelector:@selector(aacPackager:didPackageAudioFrame:)]) {
        [self.delegate aacPackager:self didPackageAudioFrame:frame];
    }
}

- (void)setConfig:(SGAudioConfig *)config{
    _config = config;
    int index = [self sampleRateIndex:config.sampleRate];
    asc[0] = 0x10 | ((index >> 1) & 0x3);
    asc[1] = ((index & 0x1) <<7) | ((config.channels & 0xF) << 3);
}

//其他的类型先不要(用不着)
- (int)sampleRateIndex:(SGAudioSampleRate)sampleRate{
    int index = 0;
    switch(sampleRate) {
        case SGAudioSampleRate_44100Hz:
            index = 4;
            break;
        case SGAudioSampleRate_48000Hz:
            index = 3;
            break;
        default:
            index = 15;
            break;
    }
    return index;
}
@end
