//
//  HKLUDPSocketStubServer.h
//  HKLSocketStubServer
//
//  Created by Yosuke Chimura on 2014/07/01.
//  Copyright (c) 2014 Hirohito Kato.
//

#import "HKLSocketStubServer.h"
#import "HKLUDPSocketStubResponse.h"

@interface HKLUDPSocketStubServer : HKLSocketStubServer
- (instancetype)init;
- (void)startServer;
- (void)stopServer;

- (HKLSocketStubResponse<GCDAsyncUdpSocketDelegate>*)responseForData:(NSData*)data;
@end
