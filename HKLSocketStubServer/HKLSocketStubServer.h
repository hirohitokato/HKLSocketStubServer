//
//  HKLSocketStubServer.h
//  HKLSocketStubServer
//
//  Created by Hirohito Kato on 2014/04/03.
//  Copyright (c) 2014 Hirohito Kato.
//

#import <Foundation/Foundation.h>
#import "HKLSocketStubConstants.h"
#import "HKLSocketStubResponse.h"
#import "HKLTCPSocketStubResponse.h"

extern const uint16_t kHKLDefaultListenPort;

@protocol GCDAsyncSocketDelegate;

@interface HKLSocketStubServer : NSObject<HKLSocketStubServerChaining>

@property(nonatomic,strong) NSMutableArray *stubResponses;

+ (instancetype)sharedServer; // returns shared server (already running)
+ (instancetype)stubServer; // returns new stubServer.
+ (HKLSocketStubServer *)currentStubServer;
+ (void)setCurrentStubServer:(HKLSocketStubServer *)stubServer;

- (void)addStubResponse:(HKLSocketStubResponse *)stubResponse;
- (void)verify;
- (void)clear;

- (void)startServer;
- (void)stopServer;

- (HKLSocketStubResponse<GCDAsyncSocketDelegate>*)responseForData:(NSData *)data;
- (HKLSocketStubResponse<GCDAsyncSocketDelegate>*)responseWhenAccepted; // only TCP

@end

#pragma mark - Setting objects
@interface HKLGlobalSettings : NSObject

/** stub server's listen port
 */
@property (nonatomic) uint16_t listenPort;

/**
 * if not nil, then read bytes until (and including) the passed "data" parameter
 */
@property (nonatomic) NSData *separatorData;

+ (instancetype)globalSettings;
@end
