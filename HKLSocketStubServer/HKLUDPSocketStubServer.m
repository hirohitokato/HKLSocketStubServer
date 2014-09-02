//
//  HKLUDPSocketStubServer.h
//  HKLSocketStubServer
//
//  Created by Yosuke Chimura on 2014/07/01.
//  Copyright (c) 2014 Hirohito Kato.
//

#import "HKLUDPSocketStubServer.h"

#pragma mark - HKLUDPSocketStubServer class
@interface HKLUDPSocketStubServer () <GCDAsyncUdpSocketDelegate>
@property (nonatomic, strong) GCDAsyncUdpSocket* server;
@end

#pragma mark - HKLUDPSocketStubServer class
@implementation HKLUDPSocketStubServer

#pragma mark Instance methods
- (instancetype)init
{
    if (self = [super init])
    {
        dispatch_queue_t global_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        self.server = [[GCDAsyncUdpSocket alloc] initWithDelegate:self
                                                    delegateQueue:global_queue];
    }
    return self;
}

- (void)dealloc
{
    [self.server close];
    self.server = nil;
}

- (void)startServer
{
    NSError* error = nil;
    
    BOOL result = [self.server enableBroadcast:NO
                                         error:&error];
    if (!result)
    {
        [NSException raise:NSInternalInconsistencyException
                    format:@"%@", error.localizedDescription];
    }
    
    uint16_t port = [HKLGlobalSettings globalSettings].listenPort;
    result = [self.server bindToPort:port
                               error:&error];
    if (!result)
    {
        [NSException raise:NSInternalInconsistencyException
                    format:@"%@", error.localizedDescription];
    }
    
    result = [self.server beginReceiving:&error];
    if (!result)
    {
        [NSException raise:NSInternalInconsistencyException
                    format:@"%@", error.localizedDescription];
    }
}

- (void)stopServer
{
    [self.server pauseReceiving];
}

- (HKLSocketStubResponse<GCDAsyncUdpSocketDelegate>*)responseForData:(NSData*)data
{
    @try
    {
        if (data == nil || data.length == 0)
        {
            return nil;
        }
        
        for (NSUInteger i = 0; i < [self.stubResponses count]; i++)
        {
            HKLSocketStubResponse *response = (self.stubResponses)[i];
            if (response.data.length == 0 || [response.data isStartingWithData:data])
            {
                if (!response.external)
                {
                    [self.stubResponses removeObject:response];
                }
                return [[[response class] alloc] initWithSocketStubResponse:response];
            }
        }
        return nil;
    }
    @catch (NSException *exception)
    {
        NSLog(@"%@", [exception description]);
        return nil;
    }
}

#pragma mark GCDAsyncUdpSocketDelegate
/**
 * By design, UDP is a connectionless protocol, and connecting is not needed.
 * However, you may optionally choose to connect to a particular host for reasons
 * outlined in the documentation for the various connect methods listed above.
 *
 * This method is called if one of the connect methods are invoked, 
 * and the connection is successful.
 **/
- (void)  udpSocket:(GCDAsyncUdpSocket*)sock
didConnectToAddress:(NSData*)address
{
    if (sock.userData)
    {
        HKLSocketStubResponse<GCDAsyncUdpSocketDelegate>* matched = sock.userData;
        [matched udpSocket:sock
       didConnectToAddress:address];
    }
}

/**
 * By design, UDP is a connectionless protocol, and connecting is not needed.
 * However, you may optionally choose to connect to a particular host for reasons
 * outlined in the documentation for the various connect methods listed above.
 *
 * This method is called if one of the connect methods are invoked, and the connection fails.
 * This may happen, for example, if a domain name is given for the host and 
 * the domain name is unable to be resolved.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket*)sock
    didNotConnect:(NSError*)error
{
    if (sock.userData)
    {
        HKLSocketStubResponse<GCDAsyncUdpSocketDelegate>* matched = sock.userData;
        [matched udpSocket:sock
             didNotConnect:error];
    }
}

/**
 * Called when the datagram with the given tag has been sent.
 **/
- (void) udpSocket:(GCDAsyncUdpSocket*)sock
didSendDataWithTag:(long)tag
{
    if (sock.userData)
    {
        HKLSocketStubResponse<GCDAsyncUdpSocketDelegate>* matched = sock.userData;
        [matched udpSocket:sock didSendDataWithTag:tag];
    }
}

/**
 * Called if an error occurs while trying to send a datagram.
 * This could be due to a timeout, or something more serious such as the data 
 * being too large to fit in a sigle packet.
 **/
- (void)    udpSocket:(GCDAsyncUdpSocket *)sock
didNotSendDataWithTag:(long)tag
           dueToError:(NSError *)error
{
    if (sock.userData)
    {
        HKLSocketStubResponse<GCDAsyncUdpSocketDelegate> *matched = sock.userData;
        [matched udpSocket:sock
     didNotSendDataWithTag:tag
                dueToError:error];
    }
}

/**
 * Called when the socket has received the requested datagram.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock
   didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    HKLSocketStubResponse<GCDAsyncUdpSocketDelegate>* matched = [self responseForData:data];
    if (matched)
    {
        sock.userData = matched;
        
        if (matched.checkBlock)
        {
            matched.checkBlock(data);
        }
        [matched udpSocket:sock
            didReceiveData:data
               fromAddress:address
         withFilterContext:filterContext];
    }
}

/**
 * Called when the socket is closed.
 **/
- (void)udpSocketDidClose:(GCDAsyncUdpSocket*)sock
                withError:(NSError*)error
{
    if (sock.userData)
    {
        HKLSocketStubResponse<GCDAsyncUdpSocketDelegate>* matched = sock.userData;
        [matched udpSocketDidClose:sock
                         withError:error];
    }
    sock.userData = nil;
}
@end
