//
//  HKLTCPSocketStubResponseTests.m
//  HKLSocketStubServer
//
//  Created by Hirohito Kato on 2014/04/06.
//  Copyright (c) 2014年 KatokichiSoft. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HKLSocketStubServer.h"

@interface HKLTCPSocketStubResponseTests : XCTestCase <GCDAsyncSocketDelegate>

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

static dispatch_semaphore_t _sem;
static NSData *_data;
- (void)testFirstData {
    HKLTCPSocketStubResponse *response = [[HKLTCPSocketStubResponse alloc] init];
    response.responseData = [NSData data];

    XCTAssertThrows([response respondsStringWhenAccepted:@""], @"応答データ設定後はacceptの応答を設定できない");
    
    HKLSocketStubServer *stubServer = [[HKLSocketStubServer alloc] init];
    [HKLSocketStubServer setCurrentStubServer:stubServer];
    [HKLGlobalSettings globalSettings].listenPort = kHKLDefaultListenPort+1;
    [stubServer startServer];

    _sem = dispatch_semaphore_create(0);
    [[stubServer expect] respondsStringWhenAccepted:@"hogehoge"];

    // 非同期で待つ
    GCDAsyncSocket *sock = [[GCDAsyncSocket alloc]
                            initWithDelegate:self
                            delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    [sock connectToHost:@"localhost" onPort:kHKLDefaultListenPort+1 error:nil];

    long result = dispatch_semaphore_wait(_sem, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)));

    XCTAssertEqual(result, 0, @"タイムアウトにはならないはず");

    NSData *data = [@"hogehoge" dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertEqualObjects(_data, data, @"hogehogeが返ってくるはず");

    _sem = NULL;
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSData *data = [@"hogehoge" dataUsingEncoding:NSUTF8StringEncoding];
    [sock writeData:data withTimeout:-1 tag:0];
    [sock readDataWithTimeout:1.0 tag:0];
}
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    _data = data;
    dispatch_semaphore_signal(_sem);
}
@end
