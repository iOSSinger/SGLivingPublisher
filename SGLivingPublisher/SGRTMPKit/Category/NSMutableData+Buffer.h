//
//  NSMutableData+Buffer.h
//  SGLivingPublisher
//
//  Created by iossinger on 16/6/2.
//  Copyright © 2016年 iossinger. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, AMFDataType) {
    kAMFNumber  = 0,
    kAMFBoolean,
    kAMFString,
    kAMFObject,
    kAMFMovieClip,		/* reserved, not used */
    kAMFNull,
    kAMFUndefined,
    kAMFReference,
    kAMFEMCAArray,
    kAMFObjectEnd,
    kAMFStrictArray,
    kAMFDate,
    kAMFLongString,
    kAMFUnsupported,
    kAMFRecordSet,		/* reserved, not used */
    kAMFXmlDoc,
    kAMFTypedObject,
    kAMFAvmPlus,		/* switch to AMF3 */
    kAMFInvalid = 0xff
};

@interface NSMutableData (Buffer)
+ (char *)be24:(int32_t)val;

- (void)appendBuff:(const uint8_t *)src : (size_t)srcsize;

- (void)appendByte:(uint8_t)val;

- (void)appendByte16:(short)val;
+ (int)getByte16:(uint8_t *)val;

- (void)appendByte24:(int32_t)val;
+ (int)getByte24:(uint8_t *)val;

- (void)appendByte32:(int32_t)val;
+ (int)getByte32:(uint8_t *)val;

- (void)appendString:(NSString *)string;
+ (NSString *)getString:(uint8_t *)buf : (int *)bufsize;

- (void)appendDouble:(double)val;
+ (double)getDouble:(uint8_t *)buf;

- (void)appendBool:(bool)val;

- (void)putKey:(NSString *)key;

- (void)putStringValue:(NSString *)value;

- (void)putKey:(NSString *)key doubleValue:(double)val;

- (void)putKey:(NSString *)key stringValue:(NSString *)val;

- (void)putKey:(NSString *)key boolValue:(bool)val;
@end
