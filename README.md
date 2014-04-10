HKLSocketStubServer ![License MIT](https://go-shields.herokuapp.com/license-MIT-yellow.png) 
=================
HKLSocketStubServer is a fake TCP server for iOS testing.

Can register fake response by `expect` or `stub`.

```Objetive-C
[[[server expect] forPath:@"/api/"] andJSONResponseResource:@"fake-response" ofType:@"json"];
```

It is strongly inspired by awesome [NLTHTTPStubServer](https://github.com/yaakaito/NLTHTTPStubServer) which is written by [yaakaito](https://github.com/yaakaito).

## Features
- Fake TCP server runs on iOS device/simulator
- Responds a specified data for specified incoming data
- Uses a prefix search

## System requirements
- iOS 6.0 or higher (older versiona may be also available, but not tested yet)

## Installation
### CocoaPods

```ruby
pod 'HKLSocketStubServer'
```
```
pod install
```

If you install HKLSocketStubServer manually, then just add HKLSocketStubServer subdirectory to your project.


## Usage

```objective-c
#import "HKLSocketStubServer.h"
```

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

### Specify crop rect by image size based 
```objective-c
// e.g.) Cropping center square
CGFloat width = image.size.width;
CGFloat height = image.size.height;
CGFloat length = MIN(width, height);
controller.imageCropRect = CGRectMake((width - length) / 2,
                                      (height - length) / 2,
                                      length,
                                      length);
```

```objective-c
// e.g.) Cropping center square
CGFloat width = image.size.width;
CGFloat height = image.size.height;
CGFloat length = MIN(width, height);
self.cropView.imageCropRect = CGRectMake((width - length) / 2,
                                         (height - length) / 2,
                                         length,
                                         length);
```

### Reset back crop rect to original image size and rotation 
```objective-c
[controller resetCropRect];
```

```objective-c
[self.cropView resetCropRect];
```


## License

[Apache]: http://www.apache.org/licenses/LICENSE-2.0
[MIT]: http://www.opensource.org/licenses/mit-license.php
[GPL]: http://www.gnu.org/licenses/gpl.html
[BSD]: http://opensource.org/licenses/bsd-license.php

PEPhotoCropEditor is available under the [MIT license][MIT]. See the LICENSE file for more info.