//
//  HKLUDPSocketStubResponse.h
//  HKLSocketStubServer
//
//  Created by Yosuke Chimura on 2014/06/30.
//  Copyright (c) 2014 Hirohito Kato.
//

#import <Foundation/Foundation.h>
#import "HKLSocketStubResponse.h"
#import "GCDAsyncUdpSocket.h"

@interface HKLUDPSocketStubResponse : HKLSocketStubResponse
<GCDAsyncUdpSocketDelegate, NSCopying>
@property (nonatomic) NSString* responseHost;
@property (nonatomic) uint16_t  responsePort;
@end
