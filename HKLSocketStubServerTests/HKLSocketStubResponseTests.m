//
//  HKStubResponseTests.m
//  HKLSocketStubServer
//
//  Created by Hirohito Kato on 2014/04/04.
//  Copyright (c) 2014年 yourcompany. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HKLSocketStubServer.h"

@interface HKLSocketStubResponseTests : XCTestCase

@end

@implementation HKLSocketStubResponseTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [HKLSocketStubServer setCurrentStubServer:nil];
    [super tearDown];
}

- (void)testResponseWith {
    HKLSocketStubResponse *response = [[HKLTCPSocketStubResponse alloc] init];
    response.data = [NSData data];
    response.shouldTimeout = YES;
    response.processingTimeSeconds = 1.0f;
    XCTAssertNotNil(response.data, @"レスポンス用のデータが存在しない");
    XCTAssertTrue(response.shouldTimeout, @"タイムアウトしない");
    XCTAssertTrue(1.0f == response.processingTimeSeconds, @"処理時間が違う");
}



@end
