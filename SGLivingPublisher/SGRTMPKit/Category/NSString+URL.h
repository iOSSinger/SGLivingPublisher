//
//  NSString+URL.h
//  SGLivingPublisher
//
//  Created by iossinger on 16/6/17.
//  Copyright © 2016年 iossinger. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  解析推流地址
 */
@interface NSString (URL)

@property(readonly) NSString *scheme;
@property(readonly) NSString *host;
@property(readonly) NSString *app;
@property(readonly) NSString *playPath;
@property(readonly) UInt32    port;

@end
