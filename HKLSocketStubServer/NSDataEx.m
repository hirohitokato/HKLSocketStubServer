//
//  NSDataEx.m
//  HKLSocketStubServer
//
//  Created by Yosuke Chimura on 2014/07/01.
//  Copyright (c) 2014 Hirohito Kato.
//

#import "NSDataEx.h"

@implementation NSData (Ex)
- (BOOL)isStartingWithData:(NSData *)data
{
    if (self.length < data.length)
    {
        return NO;
    }
    
    const uint8_t *selfPtr = self.bytes;
    const uint8_t *dataPtr = data.bytes;
    if (memcmp(selfPtr, dataPtr, data.length))
    {
        return NO;
    }
    return YES;
}
@end
