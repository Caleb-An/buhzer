//
//  UserInfo.m
//  buhzer
//
//  Created by joe student on 11/2/14.
//  Copyright (c) 2014 cs98. All rights reserved.
//

#import "UserInfo.h"
#import <Foundation/Foundation.h>

@implementation UserInfo
- (id)initWithName:(NSString *)name withHashID:(NSString *)hashID {
    self.name = name;
    self.hashID = hashID;
    
    return self;
}
@end