//
//  HKLSocketStubConstants.h
//  HKLSocketStubServer
//
//  Created by Hirohito Kato on 2014/04/04.
//  Copyright (c) 2014年 yourcompany. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^HKLSocketStubDataCheckBlock)(NSData* data);

@protocol HKLSocketStubServerChaining
@required
// Returns TCP stub server
- (id)expect;
- (id)tcpStub;
@end

@protocol HKLSocketStubResponseChaining
@required
- (id)forData:(NSData *)data;
- (id)forDataString:(NSString *)dataString;
- (id)andResponseWhenAccepted:(NSData *)data;
- (id)andResponseStringWhenAccepted:(NSString *)dataString;
- (id)andResponse:(NSData *)data;
- (id)andResponseString:(NSString *)dataString;
- (id)andResponseResource:(NSString *)filename ofType:(NSString *)type;
- (id)andProcessingTime:(NSTimeInterval)processingTimeSeconds;
- (id)andCheckData:(HKLSocketStubDataCheckBlock)checkBLock;
@end
