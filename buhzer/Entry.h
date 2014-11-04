//
//  Entry.h
//  buhzer
//
//  Created by joe student on 11/3/14.
//  Copyright (c) 2014 cs98. All rights reserved.
//

@interface Entry : NSObject

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *waitlistId;
@property (nonatomic, strong) NSString *providerUserId;
@property (nonatomic, strong) NSString *clientUserId;
@property (nonatomic, strong) NSDate *createdAt;
@property BOOL isActive;
@property BOOL isBuzzed;

@end
