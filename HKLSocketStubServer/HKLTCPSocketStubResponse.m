//
//  HKTCPSocketStubResponse.m
//  HKLSocketStubServer
//
//  Created by Hirohito Kato on 2014/04/04.
//  Copyright (c) 2014年 yourcompany. All rights reserved.
//

#import "HKLTCPSocketStubResponse.h"

@implementation HKLTCPSocketStubResponse

- (instancetype)initWithSocketStubResponse:(HKLTCPSocketStubResponse *)response
{
    self = [super initWithSocketStubResponse:response];
    if (self) {
        self.firstData = response.firstData;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    id copiedObject = [[[self class] allocWithZone:zone] initWithSocketStubResponse:self];
    return copiedObject;
}

- (NSString *)firstDataString
{
    return [[NSString alloc] initWithData:self.firstData encoding:NSUTF8StringEncoding];
}
- (void)setFirstDataString:(NSString *)dataString
{
    self.firstData = [dataString dataUsingEncoding:NSUTF8StringEncoding];
}

- (id)andResponseForAccepted:(NSData *)data
{
    self.firstData = data;
    return self;
}

- (id)andResponseStringForAccepted:(NSString *)dataString
{
    self.firstDataString = dataString;
    return self;
}

#pragma mark - delegate methods

- (void)    socket:(GCDAsyncSocket *)sock
didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    NSLog(@"Accepted a connection from %@", newSocket.connectedHost);
    if (self.firstData) {
        [self asyncWriteData:self.firstData
                    toSocket:sock
                     withTag:0
                  afterDelay:self.processingTimeSeconds];
    }
}

- (void)socket:(GCDAsyncSocket *)sock
   didReadData:(NSData *)data
       withTag:(long)tag
{
    NSLog(@"Received %lu bytes data.", (unsigned long)data.length);
    if (self.checkBlock) {
        self.checkBlock(data);
    }
    if (self.responseData) {
        [self asyncWriteData:self.responseData
                    toSocket:sock
                     withTag:tag
                  afterDelay:self.processingTimeSeconds];
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

#pragma mark - Private methods
- (void)asyncWriteData:(NSData *)data
              toSocket:(GCDAsyncSocket *)sock
               withTag:(long)tag
            afterDelay:(NSTimeInterval)afterDelay
{
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(afterDelay * NSEC_PER_SEC));
    dispatch_after(delay, sock.delegateQueue, ^{
        NSLog(@"Will send %lu bytes data.", (unsigned long)data.length);
        [sock writeData:data
            withTimeout:-1 tag:tag];
    });
}
@end
