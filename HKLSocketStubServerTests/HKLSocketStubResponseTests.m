//
//  HKStubResponseTests.m
//  HKLSocketStubServer
//
//  Created by Hirohito Kato on 2014/04/04.
//  Copyright (c) 2014 Hirohito Kato.
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


- (void)testCallDataCheckBlock {
    HKLSocketStubServer *stubServer = [HKLSocketStubServer stubServer];
    [stubServer startServer];
    NSData *data = [@"hogehoga" dataUsingEncoding:NSUTF8StringEncoding];

    dispatch_semaphore_t _sem;
    _sem = dispatch_semaphore_create(0);
    __block BOOL called = NO;
    [[[stubServer expect] forData:data] andCheckData:^(NSData *data) {
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        XCTAssertEqualObjects(@"hogehoga", str, @"データは一致するはず");
        called = YES;
        dispatch_semaphore_signal(_sem);
    }];

    // 非同期で待つ
    GCDAsyncSocket *sock = [[GCDAsyncSocket alloc]
                            initWithDelegate:self
                            delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    [sock connectToHost:@"localhost" onPort:kHKLDefaultListenPort error:nil];
    long result = dispatch_semaphore_wait(_sem,
                                          dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)));
    XCTAssertEqual(result, 0, @"タイムアウトにはならないはず");
    XCTAssertTrue(called, @"checkblockが呼ばれているはず");

    [stubServer verify];
    _sem = NULL;
}

static dispatch_semaphore_t _sem_testRespondsResourceOfType;
static NSString *_str_testRespondsResourceOfType;
- (void)testRespondsResourceOfType
{
    HKLSocketStubServer *stubServer = [HKLSocketStubServer stubServer];
    [HKLGlobalSettings globalSettings].listenPort = kHKLDefaultListenPort + 5;
    [stubServer startServer];

    [[[[stubServer expect] forDataString:@"hogehoga"]
      respondsResource:@"dummy" ofType:@"txt"]
     andCheckData:^(NSData *data) {
         NSLog(@"received.");
     }];

    GCDAsyncSocket *sock = [[GCDAsyncSocket alloc]
                            initWithDelegate:self
                            delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    [sock connectToHost:@"localhost" onPort:kHKLDefaultListenPort+5 error:nil];

    // 非同期で待つ
    _sem_testRespondsResourceOfType = dispatch_semaphore_create(0);
    long result = dispatch_semaphore_wait(_sem_testRespondsResourceOfType,
                                          dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)));
    XCTAssertEqual(result, 0, @"タイムアウトにはならないはず");
    XCTAssertEqualObjects(@"This is dummy.", _str_testRespondsResourceOfType,
                          @"ファイルのデータが得られるはず");
    _sem_testRespondsResourceOfType = nil;
    _str_testRespondsResourceOfType = nil;
}
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    // for testCallDataCheckBlock
    NSData *data = [@"hogehoga" dataUsingEncoding:NSUTF8StringEncoding];
    [sock readDataWithTimeout:-1 tag:0];
    [sock writeData:data withTimeout:-1 tag:0];
}
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    _str_testRespondsResourceOfType = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    dispatch_semaphore_signal(_sem_testRespondsResourceOfType);
}
@end
