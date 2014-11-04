//
//  WaitlistQueue.h
//  buhzer
//
//  Created by joe student on 11/3/14.
//  Copyright (c) 2014 cs98. All rights reserved.
//

#import "Waitlist.h"
#import "Entry.h"

@interface WaitlistQueue : NSObject

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) Waitlist *waitlist;
@property (nonatomic, strong) Entry *entry;

@end