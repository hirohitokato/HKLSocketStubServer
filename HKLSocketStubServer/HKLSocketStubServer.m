//
//  HKLSocketStubServer.m
//  HKLSocketStubServer
//
//  Created by Hirohito Kato on 2014/04/03.
//  Copyright (c) 2014 Hirohito Kato.
//

#import "HKLSocketStubServer.h"
#import "HKLTCPSocketStubResponse.h"
#import "GCDAsyncSocket.h"

@interface NSData (HKNSDataUtility)
- (BOOL)isStartingWithData:(NSData *)data;
@end
@implementation NSData (HKNSDataUtility)
- (BOOL)isStartingWithData:(NSData *)data
{
    if (self.length < data.length) {
        return NO;
    }
    const uint8_t *selfPtr = self.bytes;
    const uint8_t *dataPtr = data.bytes;
    if (memcmp(selfPtr, dataPtr, data.length)) {
        return NO;
    }
    return YES;
}
@end

#pragma mark -
@interface HKLSocketStubGetter : HKLSocketStubServer
@end
@implementation HKLSocketStubGetter
@end

#pragma mark -
@interface HKLSocketStubServer () <GCDAsyncSocketDelegate>
@end

@implementation HKLSocketStubServer
{
    GCDAsyncSocket *_server;
    NSMutableArray *_acceptSocks;
}

#pragma mark - Instance Accessor
- (instancetype)init
{
    self = [super init];
    if (self) {
        _stubResponses = [NSMutableArray array];
        dispatch_queue_t global_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        _server = [[GCDAsyncSocket alloc] initWithDelegate:self
                                             delegateQueue:global_queue];
        _acceptSocks = [NSMutableArray array];

        [[self class] setCurrentStubServer:self];
    }
    return self;
}

+ (instancetype)sharedServer
{
    static dispatch_once_t pred = 0;
    __strong static HKLSocketStubServer *_sharedServer = nil;
    dispatch_once(&pred, ^{
        _sharedServer = [self stubServer];

        [_sharedServer startServer];
    });
    return _sharedServer;
}

+ (instancetype)stubServer
{
    return [[[self class] alloc] init];
}

+ (HKLSocketStubServer *)currentStubServer {
    return [[self class] __currentStubServer:[[self class] __stubGetter]];
}

+ (void)setCurrentStubServer:(HKLSocketStubServer *)stubServer {
    [[self class] __currentStubServer:stubServer];
}

+ (HKLSocketStubGetter*)__stubGetter {
    return [[HKLSocketStubGetter alloc] init];
}

+ (HKLSocketStubServer *)__currentStubServer:(HKLSocketStubServer *)stubServer
{
    __strong static id _currentServer = nil;
    if(![stubServer isKindOfClass:[HKLSocketStubGetter class]]){
        _currentServer = stubServer;
    }
    return _currentServer;
}

#pragma mark -
- (HKLSocketStubResponse<GCDAsyncSocketDelegate>*)responseForData:(NSData *)data
{
    if (data == nil || data.length == 0) {
        return nil;
    }
    for (NSUInteger i = 0; i < [self.stubResponses count]; i++) {
        HKLSocketStubResponse *response = (self.stubResponses)[i];
        if(response.data.length == 0 || [response.data isStartingWithData:data]){
            if (!response.external) {
                [self.stubResponses removeObject:response];
            }
            return [[[response class] alloc] initWithSocketStubResponse:response];
        }
    }
    return nil;
}

- (HKLSocketStubResponse<GCDAsyncSocketDelegate>*)responseWhenAccepted
{
    for (NSUInteger i = 0; i < [self.stubResponses count]; i++) {
        // Returns 1st matched response, and ignore others.
        HKLSocketStubResponse *response = (self.stubResponses)[i];
        if ([response isKindOfClass:[HKLTCPSocketStubResponse class]]
            && [(HKLTCPSocketStubResponse *)response firstData] != nil) {

            if (!response.external) {
                [self.stubResponses removeObject:response];
            }
            return [[[response class] alloc] initWithSocketStubResponse:response];
        }
    }
    return nil;
}

#pragma mark - Public methods
- (void)addStubResponse:(HKLSocketStubResponse *)stubResponse {
    [self.stubResponses addObject:stubResponse];
}

- (void)verify
{
    NSUInteger expects = 0;
    for (HKLTCPSocketStubResponse *response in self.stubResponses){
        if (!response.external) {
            expects += 1;
        }
    }

    if (expects > 0) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"%lu expected responses were not invoked: %@", (unsigned long)expects, self.stubResponses];
    }

}

- (void)clear
{
    [self.stubResponses removeAllObjects];
}

- (void)startServer
{
    NSError *error;
    uint16_t listenPort = [HKLGlobalSettings globalSettings].listenPort;
    BOOL result = [_server acceptOnPort:listenPort
                                  error:&error];
    if(!result)
    {
        [NSException raise:NSInternalInconsistencyException
                    format:@"error starting stub server"];
    }
}

- (void)stopServer
{
    [_server disconnect];
}

- (id)expect
{

    HKLSocketStubResponse *stub = [[HKLTCPSocketStubResponse alloc] init];
    [self addStubResponse:stub];
    return stub;
}

- (id)tcpStub
{

    HKLSocketStubResponse *stub = [[HKLTCPSocketStubResponse alloc] init];
    stub.external = YES;
    [self addStubResponse:stub];
    return stub;
}

#pragma mark -
- (void)    socket:(GCDAsyncSocket *)sock
didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    [_acceptSocks addObject:newSocket];

    NSData *separator = [HKLGlobalSettings globalSettings].separatorData;
    if (separator) {
        [newSocket readDataToData:separator
                      withTimeout:-1
                              tag:0];
    } else {
        [newSocket readDataWithTimeout:-1
                                   tag:0];
    }

    HKLSocketStubResponse<GCDAsyncSocketDelegate> *matched = [self responseWhenAccepted];
    if (matched) {
        [matched socket:sock didAcceptNewSocket:newSocket];
    }
    newSocket.userData = matched;
}

- (void)socket:(GCDAsyncSocket *)sock
   didReadData:(NSData *)data
       withTag:(long)tag
{
    HKLSocketStubResponse<GCDAsyncSocketDelegate> *matched = [self responseForData:data];
    if (matched) {
        // Keep self as a socket delegate (for calling checkBlock)
        // [sock setDelegate:matched];
        sock.userData = matched;

        if (matched.checkBlock) {
            matched.checkBlock(data);
        }
        [matched socket:sock didReadData:data withTag:tag];
    }
}

- (void)            socket:(GCDAsyncSocket *)sock
didReadPartialDataOfLength:(NSUInteger)partialLength
                       tag:(long)tag
{
    if (sock.userData) {
        HKLSocketStubResponse<GCDAsyncSocketDelegate> *matched = sock.userData;
        [matched socket:sock didReadPartialDataOfLength:partialLength tag:tag];
    }
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock
shouldTimeoutReadWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length
{
    if (sock.userData) {
        HKLSocketStubResponse<GCDAsyncSocketDelegate> *matched = sock.userData;
        return [matched socket:sock shouldTimeoutReadWithTag:tag elapsed:elapsed bytesDone:length];
    } else {
        return 0.0f;
    }
}

- (void)     socket:(GCDAsyncSocket *)sock
didWriteDataWithTag:(long)tag
{
    if (sock.userData) {
        HKLSocketStubResponse<GCDAsyncSocketDelegate> *matched = sock.userData;
        [matched socket:sock didWriteDataWithTag:tag];
    }
}

- (void)             socket:(GCDAsyncSocket *)sock
didWritePartialDataOfLength:(NSUInteger)partialLength
                        tag:(long)tag
{
    if (sock.userData) {
        HKLSocketStubResponse<GCDAsyncSocketDelegate> *matched = sock.userData;
        [matched socket:sock didWritePartialDataOfLength:partialLength tag:tag];
    }
}

- (NSTimeInterval) socket:(GCDAsyncSocket *)sock
shouldTimeoutWriteWithTag:(long)tag
                  elapsed:(NSTimeInterval)elapsed
                bytesDone:(NSUInteger)length
{
    if (sock.userData) {
        HKLSocketStubResponse<GCDAsyncSocketDelegate> *matched = sock.userData;
        return [matched socket:sock shouldTimeoutWriteWithTag:tag elapsed:elapsed bytesDone:length];
    } else {
        return 0.0f;
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock
                  withError:(NSError *)err
{
    if (sock.userData) {
        HKLSocketStubResponse<GCDAsyncSocketDelegate> *matched = sock.userData;
        [matched socketDidDisconnect:sock withError:err];
    }
    sock.userData = nil;
    [_acceptSocks removeObject:sock];
}

@end

//-------------------------------------------------------------------
#pragma mark - Global Settings
//-------------------------------------------------------------------
const uint16_t kHKLDefaultListenPort = 54321;

@implementation HKLGlobalSettings

+ (instancetype)globalSettings {
    static dispatch_once_t once = 0;
    __strong static id _sharedSettings = nil;
    dispatch_once(&once, ^{
        _sharedSettings = [[self alloc] init];

        ((HKLGlobalSettings*)_sharedSettings).listenPort = kHKLDefaultListenPort;
    });
    return _sharedSettings;
}
@end
