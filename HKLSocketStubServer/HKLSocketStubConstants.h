//
//  HKLSocketStubConstants.h
//  HKLSocketStubServer
//
//  Created by Hirohito Kato on 2014/04/04.
//  Copyright (c) 2014 Hirohito Kato.
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
- (id)respondsWhenAccepted:(NSData *)data;
- (id)respondsStringWhenAccepted:(NSString *)dataString;
- (id)responds:(NSData *)data;
- (id)respondsString:(NSString *)dataString;
- (id)respondsResource:(NSString *)filename ofType:(NSString *)type;
- (id)andProcessingTime:(NSTimeInterval)processingTimeSeconds;
- (id)andCheckData:(HKLSocketStubDataCheckBlock)checkBLock;
@end
