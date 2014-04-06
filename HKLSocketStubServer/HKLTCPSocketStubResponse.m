//
//  HKTCPSocketStubResponse.m
//  HKLSocketStubServer
//
//  Created by Hirohito Kato on 2014/04/04.
//  Copyright (c) 2014年 yourcompany. All rights reserved.
//

#import "HKLTCPSocketStubResponse.h"

@implementation HKLTCPSocketStubResponse

- (void)socket:(GCDAsyncSocket *)sock
   didReadData:(NSData *)data
       withTag:(long)tag
{
    NSLog(@"Received %lu bytes data.", (unsigned long)data.length);
    if (self.responseData) {
        dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.processingTimeSeconds * NSEC_PER_SEC));
        dispatch_after(delay, sock.delegateQueue, ^{
            NSLog(@"Will send %lu bytes data.", (unsigned long)self.responseData.length);
            [sock writeData:self.responseData
                withTimeout:-1 tag:tag];
        });
    }
}

- (void)            socket:(GCDAsyncSocket *)sock
didReadPartialDataOfLength:(NSUInteger)partialLength
                       tag:(long)tag
{

}

- (void)     socket:(GCDAsyncSocket *)sock
didWriteDataWithTag:(long)tag
{
    NSLog(@"Did send %lu bytes data.", (unsigned long)self.responseData.length);
}

- (void)             socket:(GCDAsyncSocket *)sock
didWritePartialDataOfLength:(NSUInteger)partialLength
                        tag:(long)tag
{

}

- (NSTimeInterval) socket:(GCDAsyncSocket *)sock
shouldTimeoutWriteWithTag:(long)tag
                  elapsed:(NSTimeInterval)elapsed
                bytesDone:(NSUInteger)length
{
    return 0.0f;
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock
                  withError:(NSError *)err
{

}

@end
