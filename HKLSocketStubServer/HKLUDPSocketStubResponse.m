//
//  HKLUDPSocketStubResponse.m
//  HKLSocketStubServer
//
//  Created by Yosuke Chimura on 2014/06/30.
//  Copyright (c) 2014 Hirohito Kato.
//

#import "HKLUDPSocketStubResponse.h"

@implementation HKLUDPSocketStubResponse

- (instancetype)initWithSocketStubResponse:(HKLUDPSocketStubResponse *)response
{
    if (self = [super initWithSocketStubResponse:response])
    {
        self.responseHost = response.responseHost;
        self.responsePort = response.responsePort;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    id copiedObject = [[[self class] allocWithZone:zone] initWithSocketStubResponse:self];
    return copiedObject;
}

- (id)respondsWhenAccepted:(NSData *)data
{
    return self;
}

- (id)respondsStringWhenAccepted:(NSString *)dataString
{
    return self;
}

#pragma mark - Private methods
- (void)asyncWriteData:(NSData*)data
              toSocket:(GCDAsyncUdpSocket*)sock
               withTag:(long)tag
            afterDelay:(NSTimeInterval)afterDelay
{
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW,
                                          (int64_t)(afterDelay * NSEC_PER_SEC));
    dispatch_after(delay, sock.delegateQueue, ^{
        [sock sendData:data
                toHost:self.responseHost
                  port:self.responsePort
           withTimeout:3.0
                   tag:0];
    });
}

#pragma mark - delegate methods
/**
 * By design, UDP is a connectionless protocol, and connecting is not needed.
 * However, you may optionally choose to connect to a particular host for reasons
 * outlined in the documentation for the various connect methods listed above.
 *
 * This method is called if one of the connect methods are invoked, and the 
 * connection is successful.
 **/
- (void)  udpSocket:(GCDAsyncUdpSocket*)sock
didConnectToAddress:(NSData*)address
{
    
}

/**
 * By design, UDP is a connectionless protocol, and connecting is not needed.
 * However, you may optionally choose to connect to a particular host for reasons
 * outlined in the documentation for the various connect methods listed above.
 *
 * This method is called if one of the connect methods are invoked,
 * and the connection fails.
 * This may happen, for example, if a domain name is given for the host and the
 * domain name is unable to be resolved.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket*)sock
    didNotConnect:(NSError*)error
{
    
}

/**
 * Called when the datagram with the given tag has been sent.
 **/
- (void) udpSocket:(GCDAsyncUdpSocket*)sock
didSendDataWithTag:(long)tag
{
    
}

/**
 * Called if an error occurs while trying to send a datagram.
 * This could be due to a timeout, or something more serious such as the data 
 * being too large to fit in a sigle packet.
 **/
- (void)    udpSocket:(GCDAsyncUdpSocket*)sock
didNotSendDataWithTag:(long)tag
           dueToError:(NSError*)error
{
    
}

/**
 * Called when the socket has received the requested datagram.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket*)sock
   didReceiveData:(NSData*)data
      fromAddress:(NSData*)address
withFilterContext:(id)filterContext
{
    if (self.checkBlock)
    {
        self.checkBlock(data);
    }
    
    if (self.responseData)
    {
        [self asyncWriteData:self.responseData
                    toSocket:sock
                     withTag:0
                  afterDelay:self.processingTimeSeconds];
    }
}

/**
 * Called when the socket is closed.
 **/
- (void)udpSocketDidClose:(GCDAsyncUdpSocket*)sock
                withError:(NSError*)error
{
    
}
@end
