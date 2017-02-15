//
//  SGStreamSession.h
//  SGLivingPublisher
//
//  Created by iossinger on 16/6/16.
//  Copyright © 2016年 iossinger. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSStreamEvent SGStreamStatus;

@class SGStreamSession;
@protocol SGStreamSessionDelegate <NSObject>

- (void)streamSession:(SGStreamSession *)session didChangeStatus:(SGStreamStatus)streamStatus;

@end

@interface SGStreamSession : NSObject

@property (nonatomic,assign,readonly) SGStreamStatus streamStatus;

@property (nonatomic,weak) id<SGStreamSessionDelegate> delegate;

- (void)connectToServer:(NSString *)host port:(UInt32)port;

- (void)disConnect;

- (NSData *)readData;

- (NSInteger)writeData:(NSData *)data;

@end
