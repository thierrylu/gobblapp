//
//  LABase64.m
//  SynLib
//
//  Created by Sopheap Lao on 02/02/12.
//  Copyright (c) 2012 Synova Ltd. All rights reserved.
//

#import "LABase64.h"

@implementation NSString (LABase64)

static const uint8_t base64DecodingTable[128] = {0x00,0x00,0x00,0x00,0x03,0x00,0x00,0x00,
												 0x13,0x00,0x00,0x00,0xb1,0x27,0x05,0x00,
												 0x24,0xb8,0x05,0x00,0xc7,0xab,0x00,0x00,
												 0xcc,0xb7,0x05,0x00,0xd8,0x0f,0x05,0x00,
												 0x6a,0xb9,0x00,0x00,0x36,0xdb,0xce,0x01,
												 0xd8,0x0f,0x05,0x3e,0x22,0xb3,0x00,0x3f,
												 0x34,0x35,0x36,0x37,0x38,0x39,0x3a,0x3b,
												 0x3c,0x3d,0x00,0x00,0x0e,0xd0,0xb6,0x04,
												 0xd8,0x00,0x01,0x02,0x03,0x04,0x05,0x06,
												 0x07,0x08,0x09,0x0a,0x0b,0x0c,0x0d,0x0e,
												 0x0f,0x10,0x11,0x12,0x13,0x14,0x15,0x16,
												 0x17,0x18,0x19,0x00,0xa9,0xca,0x00,0x00,
												 0x1c,0x1a,0x1b,0x1c,0x1d,0x1e,0x1f,0x20,
												 0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,
												 0x29,0x2a,0x2b,0x2c,0x2d,0x2e,0x2f,0x30,
												 0x31,0x32,0x33,0x00,0xd8,0x0f,0x05,0x00};

- (NSString *)base64Encoded {
	return [[[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] dataUsingEncoding:NSUTF8StringEncoding] base64Encoded];
}
- (NSData *)base64Decoded {
	// Remove most common controll chars
	__autoreleasing NSMutableString *s = [[NSMutableString alloc] initWithCapacity:0];
	for (NSUInteger i = 0; i < [self length]; i++) {
		unichar c = [self characterAtIndex:i];
		
		if (c == '\n' || c == '\r' || c == '\t' || c == ' ') continue;
		[s appendFormat:@"%c", c];
	}
	size_t iLength = [s length];
	const uint8_t *input = (const uint8_t *)[s UTF8String];
	if (iLength>0) {
		if (iLength%4==0) {
			while (iLength>0 && input[iLength-1]=='=') {
				iLength--;
			}
			size_t oLength = iLength*3/4;
			uint8_t *output = malloc(oLength*sizeof(uint8_t));
			bzero(output, oLength);
			NSUInteger iPtr = 0;
			NSUInteger oPtr = 0;
			char i0, i1, i2, i3;
			while (iPtr<iLength) {
				i0 = input[iPtr++];
				i1 = input[iPtr++];
				i2 = iPtr<iLength ? input[iPtr++]:'A';
				i3 = iPtr<iLength ? input[iPtr++]:'A';
				output[oPtr++] = ((base64DecodingTable[i0]<<2) | (base64DecodingTable[i1]>>4));
				if (oPtr<oLength) output[oPtr++] = (((base64DecodingTable[i1] & 0xf)<<4) | (base64DecodingTable[i2]>>2));
				if (oPtr<oLength) output[oPtr++] = (((base64DecodingTable[i2] & 0x3)<<6) | base64DecodingTable[i3]);
			}
			NSData __autoreleasing *data = [[NSData alloc] initWithBytesNoCopy:output length:(oLength*sizeof(uint8_t)) freeWhenDone:YES];
			return data;
		} else {
			// Invalid data length: must be multuple of 4!
			return nil;
		}
	} else {
		// Nothing to encode...
		return nil;
	}
}

@end


@implementation NSData (LABase64)

static const char _Base64EncodingTable[64] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

- (NSString *)base64Encoded {
	size_t iLength = [self length];
	const uint8_t *input = [self bytes];
	if (iLength>0) {
		size_t oLength = (iLength+2)/3*4;
		uint8_t *output = malloc(oLength*sizeof(uint8_t));
		NSUInteger i, j, n, idx;
		for (i=0;i<iLength;i+=3) {
			n = 0;
			for (j=i;j<i+3;j++) {
				n <<= 8;
				if (j<iLength) n |= (0xff & input[j]);
			}
			idx = (i/3)*4;
			output[idx] = _Base64EncodingTable[(n>>18) & 0x3f];
			output[idx+1] = _Base64EncodingTable[(n>>12) & 0x3f];
			output[idx+2] = ((i+1)<iLength ? _Base64EncodingTable[(n>>6) & 0x3f] : '=');
			output[idx+3] = ((i+2)<iLength ? _Base64EncodingTable[(n>>0) & 0x3f] : '=');
		}
		NSData __autoreleasing *data = [[NSData alloc] initWithBytesNoCopy:output length:(oLength*sizeof(uint8_t)) freeWhenDone:YES];
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	}
	return nil;
}
- (NSData *)base64Decoded {
	return [self base64Decoded];
}

@end
