//
//  User.h
//  buhzer
//
//  Created by Caleb on 10/7/14.
//  Copyright (c) 2014 cs98. All rights reserved.
//


// response JSON example:
//{
//    "id": 2,
//    "provider": "GOOGLE",
//    "accountType": "CLIENT",
//    "uniqueHash": "null",
//    "uid": "1",
//    "name": "dummy",
//    "email": "dummy@dummy.com",
//    "firstName": "dummy",
//    "lastName": "dummy",
//    "createdAt": 1412652409000
//}
@interface User : NSObject
@property (nonatomic, strong) NSString* id;
@property (nonatomic, strong) NSString* provider;
@property (nonatomic, strong) NSString* accountType;
@property (nonatomic, strong) NSString* uniqueHash;

@property (nonatomic, strong) NSString* uid;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* firstName;
@property (nonatomic, strong) NSString* lastName;
@property (nonatomic, strong) NSString* email;
@property (nonatomic, strong) NSString* createdAt; 
@end
