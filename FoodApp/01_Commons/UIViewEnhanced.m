//
//  UIViewEnhanced.m
//  Mobexo
//
//  Created on 05/12/10.
//  Copyright (c) 2012 Mobexo Ltd. All rights reserved.
//

#import "UIViewEnhanced.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (Enhanced)

- (id)firstResponder {
    if (self.isFirstResponder) return self;
    for (UIView __weak *subView in self.subviews) {
        if ([subView firstResponder]) return subView;
    }
    return nil;
}

- (BOOL)findAndResignFirstResponder {
    if (self.isFirstResponder) {
        [self resignFirstResponder];
        return YES;     
    }
    for (UIView __weak *subView in self.subviews) {
        if ([subView findAndResignFirstResponder]) return YES;
    }
    return NO;
}

- (CGRect)frameInView:(UIView *)parentView {
	CGFloat x = self.frame.origin.x;
	CGFloat y = self.frame.origin.y;
	UIView *v = [self superview];
	while (v && v!=parentView) {
		x += v.frame.origin.x;
		y += v.frame.origin.y;
		v = [v superview];
	}
	return CGRectMake(x, y, self.frame.size.width, self.frame.size.height);
}

- (void)applyBackground:(__weak NSString *)backgroundName {
	/* Condition validation */
	if (!backgroundName) return;
	
	// Load texture
	__autoreleasing UIImage *background = [UIImage imageNamed:backgroundName];
	if (!background) return;

	[self setBackgroundColor:[UIColor colorWithPatternImage:background]];
	[self setClipsToBounds:YES];
}
- (void)applyBackground:(__weak NSString *)backgroundName roundCorner:(CGFloat)radius {
	[self applyBackground:backgroundName];
	[self roundCorner:radius];
}
- (void)applyTexture:(__weak NSString *)textureName {
	/* Condition validation */
	if (!textureName) return;
	
	// Load texture
	__autoreleasing UIImage *texture = [UIImage imageNamed:textureName];
	if (!texture) return;
	
	// Apply texture
	[self setBackgroundColor:[UIColor colorWithPatternImage:texture]];
	[self setClipsToBounds:YES];
}
- (void)applyTexture:(__weak NSString *)textureName roundCorner:(CGFloat)radius {
	[self applyTexture:textureName];
	[self roundCorner:radius];
}
- (void)roundCorner:(CGFloat)radius {
	self.clipsToBounds = YES;
	self.layer.cornerRadius = radius;
}

@end
