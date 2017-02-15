//
//  SGVideoSource.h
//  SGLivingPublisher
//
//  Created by iossinger on 16/6/13.
//  Copyright © 2016年 iossinger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "SGVideoConfig.h"


@class SGVideoSource;
@protocol SGVideoSourceDelegate <NSObject>

- (void)videoSource:(SGVideoSource *)source didOutputSampleBuffer:(CVPixelBufferRef)pixelBuffer;

@end

@interface SGVideoSource : NSObject

/**
 *  预览层
 */
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *preLayer;

/**
 *  代理
 */
@property (nonatomic,weak) id<SGVideoSourceDelegate> delegate;

/**
 *  配置
 */
@property (nonatomic,strong) SGVideoConfig *config;

/**
 *  开始
 */
- (void)startVideoCapture;

/**
 *  停止
 */
- (void)stopVideoCapture;

@end
