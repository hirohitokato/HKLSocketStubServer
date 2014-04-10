//
//  HKLSocketStubResponse.m
//  HKLSocketStubServer
//
//  Created by Hirohito Kato on 2014/04/04.
//  Copyright (c) 2014 Hirohito Kato.
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
        self.checkBlock = [response.checkBlock copy];
        
        self.external = response.external;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    id copiedObject = [[[self class] allocWithZone:zone] initWithSocketStubResponse:self];
    return copiedObject;
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

// Only available for TCP (UDP is a connectionless protocol)
- (id)respondsWhenAccepted:(NSData *)data
{
    [NSException raise:NSInternalInconsistencyException
                format:@"You must implement me in subclass."];
    return nil;
}

// Only available for TCP (UDP is a connectionless protocol)
- (id)respondsStringWhenAccepted:(NSString *)dataString
{
    [NSException raise:NSInternalInconsistencyException
                format:@"You must implement me in subclass."];
    return nil;
}

- (id)responds:(NSData *)data
{
    self.responseData = data;
    return self;
}

- (id)respondsString:(NSString *)dataString
{
    self.responseDataString = dataString;
    return self;
}

- (id)respondsResource:(NSString *)filename ofType:(NSString *)type
{
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:filename ofType:type];
    NSData *data = [NSData dataWithContentsOfFile:path];
    self.responseData = data;
    return self;
}

- (id)andProcessingTime:(NSTimeInterval)processingTimeSeconds
{
    self.processingTimeSeconds = processingTimeSeconds;
    return self;
}

- (id)andCheckData:(HKLSocketStubDataCheckBlock)checkBLock
{
    self.checkBlock = [checkBLock copy];
    return self;
}
@end
