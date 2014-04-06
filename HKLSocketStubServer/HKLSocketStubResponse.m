//
//  HKLSocketStubResponse.m
//  HKLSocketStubServer
//
//  Created by Hirohito Kato on 2014/04/04.
//  Copyright (c) 2014年 yourcompany. All rights reserved.
//

#import "HKLSocketStubResponse.h"

@implementation HKLSocketStubResponse

- (instancetype)initWithSocketStubResponse:(HKLSocketStubResponse *)response
{
    self = [super init];
    if (self) {
        self.data = response.data;
        self.responseData = response.responseData;

        self.processingTimeSeconds = response.processingTimeSeconds;
        self.external = response.external;
    }
    return self;
}

#pragma mark - Accessor
- (NSString *)dataString
{
    return [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
}
- (void)setDataString:(NSString *)dataString
{
    self.data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)responseDataString
{
    return [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
}
- (void)setResponseDataString:(NSString *)dataString
{
    self.responseData = [dataString dataUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark - HKLSocketStubResponseChaining
- (id)forData:(NSData *)data
{
    self.data = data;
    return self;
}

- (id)forDataString:(NSString *)dataString
{
    self.dataString = dataString;
    return self;
}

- (id)andResponse:(NSData *)data
{
    self.responseData = data;
    return self;
}

- (id)andResponseString:(NSString *)dataString
{
    self.responseDataString = dataString;
    return self;
}

- (id)andResponseResource:(NSString *)filename ofType:(NSString *)type
{
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:filename ofType:type];
    NSData *data = [NSData dataWithContentsOfFile:path];
    self.data = data;
    return self;
}

- (id)andProcessingTime:(NSTimeInterval)processingTimeSeconds
{
    self.processingTimeSeconds = processingTimeSeconds;
    return self;
}

@end
