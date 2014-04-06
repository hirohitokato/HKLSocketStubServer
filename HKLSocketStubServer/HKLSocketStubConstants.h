//
//  HKLSocketStubConstants.h
//  HKLSocketStubServer
//
//  Created by Hirohito Kato on 2014/04/04.
//  Copyright (c) 2014年 yourcompany. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HKLSocketStubServerChaining
- (id)expect;
- (id)stub;
@end

@protocol HKLSocketStubResponseChaining
- (id)forData:(NSData *)data;
- (id)forDataString:(NSString *)dataString;
- (id)andResponse:(NSData *)data;
- (id)andResponseString:(NSString *)dataString;
- (id)andResponseResource:(NSString *)filename ofType:(NSString *)type;
- (id)andProcessingTime:(NSTimeInterval)processingTimeSeconds;
@end
