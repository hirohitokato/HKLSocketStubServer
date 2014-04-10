//
//  HKLSocketStubServerTests.m
//  HKLSocketStubServerTests
//
//  Created by Hirohito Kato on 2014/04/03.
//  Copyright (c) 2014 Hirohito Kato.
//

#import <XCTest/XCTest.h>
#import "HKLSocketStubServer.h"
#import "HKLTCPSocketStubResponse.h"

@interface HKLSocketStubServerTests : XCTestCase

@end

@implementation HKLSocketStubServerTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [HKLSocketStubServer setCurrentStubServer:nil];
    [super tearDown];
}

- (void)testSharedStubServerAccessor
{
    XCTAssertNotNil([HKLSocketStubServer stubServer],
                    @"同じインスタンスが取得出来る");
}

- (void)testCurrentStubServerAccessser {

    XCTAssertNil([HKLSocketStubServer currentStubServer],
                 @"まだサーバーは作られていない");
    HKLSocketStubServer *server1 = [HKLSocketStubServer stubServer];
    [HKLSocketStubServer setCurrentStubServer:server1];
    XCTAssertEqualObjects(server1, [HKLSocketStubServer currentStubServer],
                          @"登録したはずのオブジェクトと一致しない");
    HKLSocketStubServer *server2 = [HKLSocketStubServer stubServer];
    [HKLSocketStubServer setCurrentStubServer:server2];

    XCTAssertEqualObjects(server2, [HKLSocketStubServer currentStubServer],
                          @"登録したはずのオブジェクトと一致しないまたは上書きされていない");
    XCTAssertNotEqualObjects(server1, [HKLSocketStubServer currentStubServer],
                             @"以前のものが取得されている");
}

- (void)testIsStubEmpty {
    HKLSocketStubServer *server = [HKLSocketStubServer stubServer];
    XCTAssertNoThrow([server verify], @"何もないので空のはずだが");
    [server addStubResponse: [[HKLTCPSocketStubResponse alloc] init]];
    XCTAssertThrows([server verify], @"スタブがあるので空ではないはず");

}

- (void)testClear {
    HKLSocketStubServer *server = [HKLSocketStubServer stubServer];
    [server addStubResponse:[[HKLTCPSocketStubResponse alloc] init]];
    XCTAssertThrows([server verify], @"スタブがあるので空ではないはず");
    [server clear];
    XCTAssertNoThrow([server verify], @"何もないので空のはずだが");

}


- (void)testChainingStub {

    HKLSocketStubServer *server = [HKLSocketStubServer stubServer];
    HKLTCPSocketStubResponse *response = [server expect];
    XCTAssertEqual(1U, [server.stubResponses count], @"スタブが1つ作られるはず");
    XCTAssertEqualObjects(response, (server.stubResponses)[0], @"オブジェクトが一致しない");

    [server expect];
    XCTAssertEqual(2U, [server.stubResponses count], @"スタブが2つ作られるはず");
}

- (void)testResponseForData {
    HKLSocketStubServer *server = [HKLSocketStubServer stubServer];
    XCTAssertNil([server responseForData:nil], @"まだスタブされてない");
    XCTAssertNil([server responseForData:[NSData data]], @"まだスタブされてない");

    HKLSocketStubResponse *emptyData = [[[HKLTCPSocketStubResponse alloc] init] forData:[NSData data]];
    [server addStubResponse:emptyData];
    XCTAssertNil([server responseForData:[NSData data]], @"空データを渡しても問答無用で返さない");
    XCTAssertNotNil([server responseForData:[NSData dataWithBytes:"a" length:1]], @"空データには何を渡してもスタブが返ってくるはず");
    XCTAssertNil([server responseForData:[NSData dataWithBytes:"a" length:1]], @"スタブは一度返すと消費されてしまうので次はもう返ってこない");

    [server addStubResponse:emptyData];
    XCTAssertNil([server responseForData:[NSData data]], @"空データには問答無用で返せない");
    XCTAssertNotNil([server responseForData:[NSData dataWithBytes:"hoge" length:4]], @"空データを追加したので、何を渡してもスタブを返す");
    XCTAssertNil([server responseForData:[NSData dataWithBytes:"a" length:1]], @"スタブは一度返すと消費されてしまうので次はもう返ってこない");

    HKLSocketStubResponse *someData = [[[HKLTCPSocketStubResponse alloc] init] forDataString:@"hoge"];
    HKLSocketStubResponse *someOtherData = [[[HKLTCPSocketStubResponse alloc] init] forDataString:@"fuga"];
    [server addStubResponse:someData];
    XCTAssertNil([server responseForData:someOtherData.data], @"データ内容が違うので返せない");
    XCTAssertEqualObjects([server responseForData:someData.data].dataString, someData.dataString, @"スタブが返ってくるはず");

    [server clear];
    XCTAssertNoThrow([server verify], @"次のテストの前に状態を空にしておく");
}

- (void)testExternalStub {
    HKLSocketStubServer *server = [HKLSocketStubServer stubServer];
    HKLSocketStubResponse *response = [[HKLTCPSocketStubResponse alloc] init];
    response.external = YES;
    [[response forDataString:@"dummy"] respondsString:@"fuga"];
    [server addStubResponse:response];

    NSData *data = [NSData dataWithBytes:"dummy" length:5];
    [server responseForData:data];
    HKLSocketStubResponse *actual = [server responseForData:data];

    XCTAssertNotNil(actual, @"スタブが返ってくるはず");
    XCTAssertEqualObjects(actual.dataString, response.dataString, @"同じデータ内容のはず");

    XCTAssertNoThrow([server verify], @"外部スタブが残っていても例外を返さない");

    actual = [server responseForData:data];
    XCTAssertNotNil(actual, @"再度スタブが返ってくるはず");
    XCTAssertEqualObjects(actual.dataString, response.dataString, @"再度得たスタブも同じデータ内容のはず");

    XCTAssertNoThrow([server verify], @"外部スタブが残っていても例外を返さない");
}

@end
