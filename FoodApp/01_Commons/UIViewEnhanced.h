//
//  UIViewEnhanced.h
//  Mobexo
//
//  Created on 05/12/10.
//  Copyright (c) 2012 Mobexo Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIView (Enhanced)

- (id)firstResponder;

- (BOOL)findAndResignFirstResponder;

- (CGRect)frameInView:(UIView *)parentView;

/**
 * Apply background to view's layer
 */
- (void)applyBackground:(__weak NSString *)backgroundName;
- (void)applyBackground:(__weak NSString *)backgroundName roundCorner:(CGFloat)radius;

/**
 * Apply texture to view's layer
 */
- (void)applyTexture:(__weak NSString *)textureName;
- (void)applyTexture:(__weak NSString *)textureName roundCorner:(CGFloat)radius;

/**
 * Round corner of an UIView with specific radius
 */
- (void)roundCorner:(CGFloat)radius;

@end
