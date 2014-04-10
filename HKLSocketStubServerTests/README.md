HKLSocketStubServer ![License MIT](https://go-shields.herokuapp.com/license-MIT-yellow.png) 
=================
HKLSocketStubServer is a fake TCP server for iOS testing.

Can register fake response by `expect` or `stub`.

```Objetive-C
[[[server expect] forPath:@"/api/"] andJSONResponseResource:@"fake-response" ofType:@"json"];
```

This is strongly inspired by awesome [NLTHTTPStubServer](https://github.com/yaakaito/NLTHTTPStubServer) which is written by [yaakaito](https://github.com/yaakaito).

## Features
- Fake TCP server runs on iOS device/simulator
- Responds a specified data for specified incoming data via TCP
- Uses a prefix search

## System requirements
- iOS 6.0 or higher (older version may be also available, but not tested yet)

## Installation

If you install HKLSocketStubServer manually, then just add HKLSocketStubServer subdirectory to your project.

## Usage

Write the following code at the top of your TestCase.

```objective-c
#import "HKLSocketStubServer.h"
```

The most simply test example using [GCDAsyncSocket](https://github.com/robbiehanson/CocoaAsyncSocket) is as follows.

+ Get the shared server. the default URL is `localhost:54321`.
+ register the response data for specified data
+ Send a data to HKLSocketStubServer via TCP. Receive the response.
+ Verify the all expects are invoked

Saying it simply, you change the server URL from real to fake.

```objective-c
static dispatch_semaphore_t _sem_testRespondsResourceOfType;
static NSString *_str_testRespondsResourceOfType;

- (void)testRespondsResourceOfType
{
    HKLSocketStubServer *stubServer = [HKLSocketStubServer sharedServer];

    // Register fake response for incoming "foo" string
    [[[[stubServer expect] forDataString:@"foo"] respondsString:@"bar"];

    // GCDAsyncSocket: Setup async socket.
    GCDAsyncSocket *sock = [[GCDAsyncSocket alloc]
                            initWithDelegate:self
                            delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    [sock connectToHost:@"localhost" onPort:kHKLDefaultListenPort+5 error:nil];

    // Wait a response from HKLSocketStubServer
    _sem_testRespondsResourceOfType = dispatch_semaphore_create(0);
    long result = dispatch_semaphore_wait(_sem_testRespondsResourceOfType,
                                          dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)));

    //
    XCTAssertEqual(result, 0, @"should get result immediately.");
    XCTAssertEqualObjects(@"bar", _str_testRespondsResourceOfType,
                          @"ファイルのデータが得られるはず");

    _str_testRespondsResourceOfType = nil;

    XCTAssertNoThrow([server verify], @"all fake responses have been sent.");
}

// GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    // Send "foo" data to server.
    NSData *data = [@"foo" dataUsingEncoding:NSUTF8StringEncoding];
    [sock readDataWithTimeout:-1 tag:0]; // Start reading without timeout
    [sock writeData:data withTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    // Store the received string(should be "bar") and signal to the main thread.
    _str_testRespondsResourceOfType = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    dispatch_semaphore_signal(_sem_testRespondsResourceOfType);
}
@end
```

### Basics

#### Get a server instance and clear

**Get shared instance.**

```objective-c
HKLSocketStubServer *server =[HKLSocketStubServer sharedServer];
```

**Remove all fake responses.**

```objective-c
[server clear];
```

#### Expecations and verifycation

```objective-c
[[server expect] forData:[@"something binary data" dataUsingEncoding:NSUTF8StringEncoding]];
```

Register fake response. Server will response this fake if requested `/fake`.
After this setup the functionality under test should be invoked followed by

```objective-c
[server verify];
```

When expected responses have not been invoked, `verify` method will raise an exception.

#### Stubs

```objective-c
[[server stub] forDataString:@"bar"]
```

`stub` is similar to `expect`, But `stub` remains server response queue after invoked it.
Therefore, `verify` ignores response that registered by `stub`.

### Complicated response

**Simulate waiting**

```objective-c
// e.g.) Send response after 10 sec.
[[[server stub] forPath:@"/fake"] andProcessingTime:10.0f];
```

**Check incoming data in blocks**

```objective-c
// e.g.) Log the data from client.
[[[stubServer expect] forData:data] andCheckData:^(NSData *data) {
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"Received %@", str);
    }];
```

[NLTHTTPStubServer](https://github.com/yaakaito/NLTHTTPStubServer) architecture is also available for your understanding.

## License

[Apache]: http://www.apache.org/licenses/LICENSE-2.0
[MIT]: http://www.opensource.org/licenses/mit-license.php
[GPL]: http://www.gnu.org/licenses/gpl.html
[BSD]: http://opensource.org/licenses/bsd-license.php

PEPhotoCropEditor is available under the [MIT license][MIT]. See the LICENSE file for more info.