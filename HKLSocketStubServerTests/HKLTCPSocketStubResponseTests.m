//
//  HKLTCPSocketStubResponseTests.m
//  HKLSocketStubServer
//
//  Created by Hirohito Kato on 2014/04/06.
//  Copyright (c) 2014年 KatokichiSoft. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HKLSocketStubServer.h"

@interface HKLTCPSocketStubResponseTests : XCTestCase

@end

@implementation HKLTCPSocketStubResponseTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [HKLSocketStubServer setCurrentStubServer:nil];
    [super tearDown];
}

- (void)testSupportCopy {

    NSData *data = [@"hogehogehogehoge" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *otherData = [@"fugafuga" dataUsingEncoding:NSUTF8StringEncoding];
    HKLTCPSocketStubResponse *response = [[HKLTCPSocketStubResponse alloc] init];
    response.data = data;
    response.processingTimeSeconds = 1.0f;
    response.firstData = otherData;
    HKLTCPSocketStubResponse *copy = [response copy];

    XCTAssertNotEqualObjects(response, copy, @"コピーは別のオブジェクト");
    XCTAssertEqualObjects(response.data, copy.data, @"データは同じ");
    XCTAssertEqual(response.firstData, copy.firstData, @"接続時の返送データも同じ");
}

- (void)testTCPResponseWith {
    HKLTCPSocketStubResponse *response = [[HKLTCPSocketStubResponse alloc] init];
    response.data = [NSData data];
    response.processingTimeSeconds = 1.0f;
    response.firstData = [NSData data];
    XCTAssertNotNil(response.data, @"レスポンス用のデータが存在しない");
    XCTAssertTrue(1.0f == response.processingTimeSeconds, @"処理時間が違う");
    XCTAssertNotNil(response.firstData, @"接続直後に送るデータが存在しない");
    XCTAssertEqualObjects(response.firstDataString, @"", @"空のNSDataは空文字");
}

@end
