//
//  LABase64.h
//  SynLib
//
//  Created by Sopheap Lao on 02/02/12.
//  Copyright (c) 2012 Synova Ltd. All rights reserved.
//


@interface NSString (LABase64)

- (NSString *)base64Encoded;
- (NSData *)base64Decoded;

@end


@interface NSData (LABase64)

- (NSString *)base64Encoded;
- (NSData *)base64Decoded;

@end
