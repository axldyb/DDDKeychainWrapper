//
//  DDDUtilsKeychainWrapperTests.m
//  DDDUtils Tests
//
//  Created by Aksel Dybdal on 02.04.14.
//  Copyright (c) 2014 akseldybdal. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <DDDKeychainWrapper/DDDKeychainWrapper.h>

@interface DDDKeychainWrapperTests : XCTestCase

@end

@implementation DDDKeychainWrapperTests

- (void)tearDown
{
    [super tearDown];
    
    [DDDKeychainWrapper wipeKeychain];
}

- (void)test_string
{
    NSString *testKey = @"test_key";
    NSString *testString = @"test_string";
    
    [DDDKeychainWrapper setString:testString forKey:testKey];
    
    NSString *result = [DDDKeychainWrapper stringForKey:testKey];
    XCTAssert([result isEqualToString:testString], @"String does not match");
}

- (void)test_data
{
    NSString *testKey = @"test_key";
    NSString *testString = @"test_string";
    NSData *testData = [testString dataUsingEncoding:NSUTF8StringEncoding];
    
    [DDDKeychainWrapper setData:testData forKey:testKey];
    NSData *result = [DDDKeychainWrapper dataForKey:testKey];
    
    NSString *resultString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
    XCTAssert([resultString isEqualToString:testString], @"Data does not match");
}

- (void)test_array
{
    NSString *testKey = @"test_key";
    NSString *testString = @"test_string";
    NSArray *testArray = @[testString];
    
    [DDDKeychainWrapper setArray:testArray forKey:testKey];
    NSArray *result = [DDDKeychainWrapper arrayForKey:testKey];
    
    NSString *resultString = (NSString *)result.firstObject;
    XCTAssert([resultString isEqualToString:testString], @"Array does not match");
}

- (void)test_dictionary
{
    NSString *testKey = @"test_key";
    NSDate *testDate = [NSDate date];
    NSDictionary *testDictionary = @{testKey: testDate};
    
    [DDDKeychainWrapper setDictionary:testDictionary forKey:testKey];
    NSDictionary *result = [DDDKeychainWrapper dictionaryForKey:testKey];
    
    NSDate *resultDate = (NSDate *)result[testKey];
    XCTAssert([resultDate isEqualToDate:testDate], @"Dictionary does not match");
}

- (void)test_number
{
    NSString *testKey = @"test_key";
    NSNumber *testNumber = @456;
    
    [DDDKeychainWrapper setNumber:testNumber forKey:testKey];
    
    NSNumber *result = [DDDKeychainWrapper numberForKey:testKey];
    XCTAssert([result isEqualToNumber:testNumber], @"Number does not match");
}

- (void)test_bool
{
    NSString *testKey = @"test_key";
    BOOL testBool = YES;
    
    [DDDKeychainWrapper setBoolean:testBool forKey:testKey];
    
    BOOL result = [DDDKeychainWrapper booleanForKey:testKey];
    XCTAssert(result ==  testBool, @"Bool does not match");
}

- (void)test_bool_missing
{
    BOOL result = [DDDKeychainWrapper booleanForKey:@"some_key"];
    XCTAssert(result == NO, @"Bool does not match");
}

- (void)test_object
{
    NSString *testKey = @"test_key";
    NSString *testString = @"test_string";
    NSDictionary *objectDict = @{testKey : testString};
    
    [DDDKeychainWrapper setObject:objectDict forKey:testKey];
    
    NSDictionary *result = [DDDKeychainWrapper objectForKey:testKey];
    XCTAssert([objectDict[testKey] isEqualToString:result[testKey]], @"Object does not match");
}

- (void)test_wipe
{
    NSString *testKey = @"test_key";
    NSString *testString = @"test_string";
    
    [DDDKeychainWrapper setString:testString forKey:testKey];
    [DDDKeychainWrapper wipeKeychain];
    
    NSString *result = [DDDKeychainWrapper stringForKey:testKey];

    // Dispatch_async is needed on OSX because to give wipe time to work
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        XCTAssert(NO == [result isEqualToString:testString], @"Wipe keychain failed");
    });

}

@end
