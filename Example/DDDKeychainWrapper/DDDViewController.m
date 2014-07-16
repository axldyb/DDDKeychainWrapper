//
//  DDDViewController.m
//  DDDKeychainWrapper
//
//  Created by axldyb on 07/16/2014.
//  Copyright (c) 2014 axldyb. All rights reserved.
//

#import "DDDViewController.h"
#import <DDDKeychainWrapper/DDDKeychainWrapper.h>

@interface DDDViewController ()

@end

@implementation DDDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [DDDKeychainWrapper setString:@"Test string" forKey:@"my_key"];
    
    NSString *testString = [DDDKeychainWrapper stringForKey:@"my_key"];
    
    NSLog(@"The test string: %@", testString);
}

@end
