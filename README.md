# DDDKeychainWrapper

[![CI Status](http://img.shields.io/travis/axldyb/DDDKeychainWrapper.svg?style=flat)](https://travis-ci.org/axldyb/DDDKeychainWrapper)
[![Version](https://img.shields.io/cocoapods/v/DDDKeychainWrapper.svg?style=flat)](http://cocoadocs.org/docsets/DDDKeychainWrapper)
[![License](https://img.shields.io/cocoapods/l/DDDKeychainWrapper.svg?style=flat)](http://cocoadocs.org/docsets/DDDKeychainWrapper)
[![Platform](https://img.shields.io/cocoapods/p/DDDKeychainWrapper.svg?style=flat)](http://cocoadocs.org/docsets/DDDKeychainWrapper)

## Usage

Storing your sensitive data in the keychain can take up a lot of time and effort. It should be easy to just drop something in there and retrive it with a few simple lines of code. DDDKeychainWrapper offers this simplicity and here is how we do it: 

```objective-c
	// Writing to the Keychain
	[DDDKeychainWrapper setString:@"Secret string" forKey:@"my_key"];
    
    // Reading from the Keychain
    NSString *secretString = [DDDKeychainWrapper stringForKey:@"my_key"];
```

DDDKeychainWrapper has support for the following types

* NSString
* NSDate
* NSData
* NSArray
* NSDictionary
* NSNumber
* BOOL
* Objects (Must confirm to NSCoding)

A method for wiping the keychain data inserted via the wrapper exists as well.

## Installation

DDDKeychainWrapper is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "DDDKeychainWrapper"

## Author

axldyb, aksel.dybdal@shortcut.no

## License
© 2014 Aksel Dybdal
DDDKeychainWrapper is available under the MIT license. See the LICENSE file for more info.

