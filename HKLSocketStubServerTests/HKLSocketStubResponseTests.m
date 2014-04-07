//
//  HKStubResponseTests.m
//  HKLSocketStubServer
//
//  Created by Hirohito Kato on 2014/04/04.
//  Copyright (c) 2014年 yourcompany. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HKLSocketStubServer.h"

@interface HKLSocketStubResponseTests : XCTestCase <GCDAsyncSocketDelegate>

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
    response.processingTimeSeconds = 1.0f;
    XCTAssertNotNil(response.data, @"レスポンス用のデータが存在しない");
    XCTAssertTrue(1.0f == response.processingTimeSeconds, @"処理時間が違う");
}

- (void)testSupportCopy {

    NSData *data = [@"hogehogehogehoge" dataUsingEncoding:NSUTF8StringEncoding];
    HKLSocketStubResponse *response = [[HKLTCPSocketStubResponse alloc] init];
    response.data = data;
    response.processingTimeSeconds = 1.0f;

    HKLSocketStubResponse *copy = [response copy];

    XCTAssertNotEqualObjects(response, copy, @"コピーは別のオブジェクト");
    XCTAssertEqualObjects(response.data, copy.data, @"データは同じ");
}

static dispatch_semaphore_t _sem;

- (void)testCallDataCheckBlock {
    HKLSocketStubServer *stubServer = [HKLSocketStubServer sharedServer];
    NSData *data = [@"hogehoge" dataUsingEncoding:NSUTF8StringEncoding];

    _sem = dispatch_semaphore_create(0);
    __block BOOL called = NO;
    [[[stubServer expect] forData:data] andCheckData:^(NSData *data) {
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        XCTAssertEqualObjects(@"hogehoge", str, @"データは一致するはず");
        called = YES;
        dispatch_semaphore_signal(_sem);
    }];

    // @TODO: 非同期で待つ
    GCDAsyncSocket *sock = [[GCDAsyncSocket alloc]
                            initWithDelegate:self
                            delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    [sock connectToHost:@"localhost" onPort:54321 error:nil];
    long result = dispatch_semaphore_wait(_sem, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)));
    XCTAssertEqual(result, 0, @"タイムアウトにはならないはず");
    XCTAssertTrue(called, @"checkblockが呼ばれているはず");

    _sem = NULL;
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSData *data = [@"hogehoge" dataUsingEncoding:NSUTF8StringEncoding];
    [sock writeData:data withTimeout:-1 tag:0];
}
@end
