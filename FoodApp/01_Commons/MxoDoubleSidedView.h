//
//  MxoDoubleSidedView.h
//  ABC
//
//  Created by Chinh Le on 7/12/13.
//  Copyright (c) 2013 Synova. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	kMxoViewFlow2RenderingAction_None					= 0x00,
	kMxoViewFlow2RenderingAction_ReplaceFrontView		= 0x01,
	kMxoViewFlow2RenderingAction_ReplaceBackView			= 0x02,
	kMxoViewFlow2RenderingAction_ReplaceFrontAndBackView	= 0x03,
	kMxoViewFlow2RenderingAction_FadeInFrontView			= 0x04,
	kMxoViewFlow2RenderingAction_FadeInBackView			= 0x08,
	kMxoViewFlow2RenderingAction_FadeInFrontAndBackView	= 0x0c,
	kMxoViewFlow2RenderingAction_FadeOutFrontView		= 0x10,
	kMxoViewFlow2RenderingAction_FadeOutBackView			= 0x20,
	kMxoViewFlow2RenderingAction_FadeOutFrontAndBackView	= 0x30
} MxoViewFlow2RenderingAction;

@interface MxoDoubleSidedView : UIView{
    UIView __strong *_frontViews;
	UIView __strong *_backViews;
	BOOL _backIsFlippedHorizontally;
	BOOL _faceBack;
    
    BOOL _isFlipping;
}

@property (nonatomic, readonly) NSArray *frontSubviews;
@property (nonatomic, readonly) NSArray *backSubviews;
@property (nonatomic, readonly) CALayer *frontLayer;
@property (nonatomic, readonly) CALayer *backLayer;

- (id)initWithFrame:(CGRect)frame backIsFlippedHorizontally:(BOOL)flipHorizontally;
- (void)addFrontSubview:(UIView *)view;
- (void)addBackSubview:(UIView *)view;
- (void)flipView;
- (void)flipViewToFront;
- (void)removeBackViews;

@end
