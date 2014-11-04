//
//  UserInfo.h
//  buhzer
//
//  Created by joe student on 11/2/14.
//  Copyright (c) 2014 cs98. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *hashID;
- (id)initWithName:(NSString *)name withHashID:(NSString *)hashID;

@end