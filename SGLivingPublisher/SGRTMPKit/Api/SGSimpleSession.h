//
//  SGSimpleSession.h
//  SGLivingPublisher
//
//  Created by iossinger on 16/7/3.
//  Copyright © 2016年 iossinger. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "SGVideoConfig.h"
#import "SGAudioConfig.h"
#import <AVFoundation/AVFoundation.h>

/**
 *  连接状态
 */
typedef NS_ENUM(NSUInteger, SGSimpleSessionState) {
    SGSimpleSessionStateNone,
    SGSimpleSessionStateConnecting,
    SGSimpleSessionStateConnected,
    SGSimpleSessionStateReconnecting,
    SGSimpleSessionStateEnd,
    SGSimpleSessionStateError,
};

@class SGSimpleSession;
@protocol SGSimpleSessionDelegate <NSObject>

- (void)simpleSession:(SGSimpleSession *)simpleSession statusDidChanged:(SGSimpleSessionState)status;

@end

@interface SGSimpleSession : NSObject


@property (nonatomic,weak) id<SGSimpleSessionDelegate> delegate;

/**
 *  预览层
 */
@property (nonatomic,strong,readonly) UIView *preview;

/**
 *  推流地址
 */
@property (nonatomic,copy) NSString *url;

/**
 *  当前状态
 */
@property (nonatomic,assign,readonly) SGSimpleSessionState state;

/**
 *  视频配置
 */
@property (nonatomic,strong) SGVideoConfig *videoConfig;

/**
 *  音频配置
 */
@property (nonatomic,strong) SGAudioConfig *audioConfig;

/**
 *  用默认设置初始化,修改初始参数在这里
 */
+ (instancetype)defultSession;

/**
 *  开始
 */
- (void)startSession;

/**
 *  停止
 */
- (void)endSession;
@end
