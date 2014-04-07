//
//  HKTCPSocketStubResponse.h
//  HKLSocketStubServer
//
//  Created by Hirohito Kato on 2014/04/04.
//  Copyright (c) 2014年 yourcompany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HKLSocketStubResponse.h"
#import "GCDAsyncSocket.h"

@interface HKLTCPSocketStubResponse : HKLSocketStubResponse
<GCDAsyncSocketDelegate, NSCopying>
@property (nonatomic) NSData *firstData;         // expected 1st incoming data when the connection is accepted.
@property (nonatomic) NSString *firstDataString; // expected 1st incoming data when the connection is accepted.(UTF-8 string expression)

@end
