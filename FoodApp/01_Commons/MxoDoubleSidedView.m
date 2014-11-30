//
//  MxoDoubleSidedView.m
//  ABC
//
//  Created by Chinh Le on 7/12/13.
//  Copyright (c) 2013 Synova. All rights reserved.
//

#import "MxoDoubleSidedView.h"

@interface MxoDoubleSidedView ()
- (void)_initWithBackFlippedHorizontally:(BOOL)flipHorizontally;
@end

@implementation MxoDoubleSidedView

- (NSMutableArray *)_renderingActionForViewWrapper:(MxoDoubleSidedView *)viewWrapper {
    //	NSLog(@"Rendering action for relativeIndex %i",viewWrapper.relativeIndex);
	NSMutableArray __autoreleasing *action = [[NSMutableArray alloc] init];
    
	UIView __autoreleasing *oldFront = nil;
	UIView __autoreleasing *oldBack = nil;
	UIView __autoreleasing *newFront = nil;
	UIView __autoreleasing *newBack = nil;
	BOOL isFlipped = YES;
    if (isFlipped) {
        newFront = [viewWrapper.backSubviews objectAtIndex:0];
        newBack = [viewWrapper.frontSubviews objectAtIndex:0];
    } else {
        newFront = [viewWrapper.frontSubviews objectAtIndex:0];
        newBack = [viewWrapper.backSubviews objectAtIndex:0];
    }
	[action addObject:[NSNumber numberWithUnsignedInteger:0]];
	if (newFront || newBack) {
		BOOL frontChanged = NO;
		BOOL backChanged = NO;
		if (viewWrapper.frontSubviews.count>0 && !viewWrapper.hidden) {
			oldFront = [viewWrapper.frontSubviews objectAtIndex:0];
			frontChanged = ![oldFront isEqual:newFront];
			if (frontChanged) {
				[action replaceObjectAtIndex:0 withObject:[NSNumber numberWithUnsignedInteger:([(NSNumber *)[action objectAtIndex:0] unsignedIntegerValue] | kMxoViewFlow2RenderingAction_ReplaceFrontView)]];
				[action addObject:oldFront];
				[action addObject:[NSNumber numberWithFloat:oldFront.alpha]];
				[action addObject:newFront];
				[action addObject:[NSNumber numberWithFloat:newFront.alpha]];
			}
		} else {
			[action replaceObjectAtIndex:0 withObject:[NSNumber numberWithUnsignedInteger:([(NSNumber *)[action objectAtIndex:0] unsignedIntegerValue] | kMxoViewFlow2RenderingAction_FadeInFrontView)]];
			[action addObject:newFront];
			[action addObject:[NSNumber numberWithFloat:newFront.alpha]];
		}
		if (viewWrapper.backSubviews.count>0 && !viewWrapper.hidden) {
			oldBack = [viewWrapper.backSubviews objectAtIndex:0];
			backChanged = ![oldBack isEqual:newBack];
			if (backChanged) {
				[action replaceObjectAtIndex:0 withObject:[NSNumber numberWithUnsignedInteger:([(NSNumber *)[action objectAtIndex:0] unsignedIntegerValue] | kMxoViewFlow2RenderingAction_ReplaceBackView)]];
				[action addObject:oldBack];
				[action addObject:[NSNumber numberWithFloat:oldBack.alpha]];
				[action addObject:newBack];
				[action addObject:[NSNumber numberWithFloat:newBack.alpha]];
			}
		} else {
			[action replaceObjectAtIndex:0 withObject:[NSNumber numberWithUnsignedInteger:([(NSNumber *)[action objectAtIndex:0] unsignedIntegerValue] | kMxoViewFlow2RenderingAction_FadeInBackView)]];
			[action addObject:newBack];
			[action addObject:[NSNumber numberWithFloat:newBack.alpha]];
		}
	} else {
		if (viewWrapper.frontSubviews.count>0 && !viewWrapper.hidden) {
			oldFront = [viewWrapper.frontSubviews objectAtIndex:0];
			[action replaceObjectAtIndex:0 withObject:[NSNumber numberWithUnsignedInteger:([(NSNumber *)[action objectAtIndex:0] unsignedIntegerValue] | kMxoViewFlow2RenderingAction_FadeOutFrontView)]];
			[action addObject:[viewWrapper.frontSubviews objectAtIndex:0]];
			[action addObject:[NSNumber numberWithFloat:oldFront.alpha]];
		}
		if (viewWrapper.backSubviews.count>0 && !viewWrapper.hidden) {
			oldBack = [viewWrapper.backSubviews objectAtIndex:0];
			[action replaceObjectAtIndex:0 withObject:[NSNumber numberWithUnsignedInteger:([(NSNumber *)[action objectAtIndex:0] unsignedIntegerValue] | kMxoViewFlow2RenderingAction_FadeOutBackView)]];
			[action addObject:[viewWrapper.backSubviews objectAtIndex:0]];
			[action addObject:[NSNumber numberWithFloat:oldBack.alpha]];
		}
	}
	return action;
}

- (void)_renderFadeOutWithAction:(NSMutableArray *)action {
	MxoViewFlow2RenderingAction a = (int)[(NSNumber *)[action objectAtIndex:0] unsignedIntegerValue];
	switch (a) {
		case kMxoViewFlow2RenderingAction_ReplaceFrontAndBackView: {
			[[action objectAtIndex:1] setAlpha:0.0f];
			[[action objectAtIndex:5] setAlpha:0.0f];
			break;
		}
		case kMxoViewFlow2RenderingAction_ReplaceFrontView: {
			[[action objectAtIndex:1] setAlpha:0.0f];
			break;
		}
		case kMxoViewFlow2RenderingAction_ReplaceBackView: {
			[[action objectAtIndex:1] setAlpha:0.0f];
			break;
		}
		case kMxoViewFlow2RenderingAction_FadeInFrontAndBackView: {
			break;
		}
		case kMxoViewFlow2RenderingAction_FadeInFrontView: {
			break;
		}
		case kMxoViewFlow2RenderingAction_FadeInBackView: {
			break;
		}
		case kMxoViewFlow2RenderingAction_FadeOutFrontAndBackView: {
			[[action objectAtIndex:1] setAlpha:0.0f];
			[[action objectAtIndex:3] setAlpha:0.0f];
			break;
		}
		case kMxoViewFlow2RenderingAction_FadeOutFrontView: {
			[[action objectAtIndex:1] setAlpha:0.0f];
			break;
		}
		case kMxoViewFlow2RenderingAction_FadeOutBackView: {
			[[action objectAtIndex:1] setAlpha:0.0f];
			break;
		}
		default: {
			break;
		}
	}
}

- (void)_renderRemoveFromSuperviewWithAction:(NSMutableArray *)action {
	MxoViewFlow2RenderingAction a = (int)[(NSNumber *)[action objectAtIndex:0] unsignedIntegerValue];
	switch (a) {
		case kMxoViewFlow2RenderingAction_ReplaceFrontAndBackView: {
			[[action objectAtIndex:1] removeFromSuperview];
			[[action objectAtIndex:1] setAlpha:[(NSNumber *)[action objectAtIndex:2] floatValue]];
			[[action objectAtIndex:5] removeFromSuperview];
			[[action objectAtIndex:5] setAlpha:[(NSNumber *)[action objectAtIndex:6] floatValue]];
			break;
		}
		case kMxoViewFlow2RenderingAction_ReplaceFrontView: {
			[[action objectAtIndex:1] removeFromSuperview];
			[[action objectAtIndex:1] setAlpha:[(NSNumber *)[action objectAtIndex:2] floatValue]];
			break;
		}
		case kMxoViewFlow2RenderingAction_ReplaceBackView: {
			[[action objectAtIndex:1] removeFromSuperview];
			[[action objectAtIndex:1] setAlpha:[(NSNumber *)[action objectAtIndex:2] floatValue]];
			break;
		}
		case kMxoViewFlow2RenderingAction_FadeInFrontAndBackView: {
			break;
		}
		case kMxoViewFlow2RenderingAction_FadeInFrontView: {
			break;
		}
		case kMxoViewFlow2RenderingAction_FadeInBackView: {
			break;
		}
		case kMxoViewFlow2RenderingAction_FadeOutFrontAndBackView: {
			[[action objectAtIndex:1] removeFromSuperview];
			[[action objectAtIndex:1] setAlpha:[(NSNumber *)[action objectAtIndex:2] floatValue]];
			[[action objectAtIndex:3] removeFromSuperview];
			[[action objectAtIndex:3] setAlpha:[(NSNumber *)[action objectAtIndex:4] floatValue]];
			break;
		}
		case kMxoViewFlow2RenderingAction_FadeOutFrontView: {
			[[action objectAtIndex:1] removeFromSuperview];
			[[action objectAtIndex:1] setAlpha:[(NSNumber *)[action objectAtIndex:2] floatValue]];
			break;
		}
		case kMxoViewFlow2RenderingAction_FadeOutBackView: {
			[[action objectAtIndex:1] removeFromSuperview];
			[[action objectAtIndex:1] setAlpha:[(NSNumber *)[action objectAtIndex:2] floatValue]];
			break;
		}
		default: {
			break;
		}
	}
}
- (void)_renderInitializeViewInViewWrapper:(MxoDoubleSidedView *)viewWrapper withAction:(NSMutableArray *)action {
	MxoViewFlow2RenderingAction a = (int)[(NSNumber *)[action objectAtIndex:0] unsignedIntegerValue];
	switch (a) {
		case kMxoViewFlow2RenderingAction_ReplaceFrontAndBackView: {
			[viewWrapper setHidden:NO];
			[self _transformForViewWrapper:viewWrapper];
			[viewWrapper addFrontSubview:[action objectAtIndex:3]]; [[action objectAtIndex:3] setAlpha:0.0f];
			[viewWrapper addBackSubview:[action objectAtIndex:7]]; [[action objectAtIndex:7] setAlpha:0.0f];
			break;
		}
		case kMxoViewFlow2RenderingAction_ReplaceFrontView: {
			[viewWrapper setHidden:NO];
			[self _transformForViewWrapper:viewWrapper];
			[viewWrapper addFrontSubview:[action objectAtIndex:3]]; [[action objectAtIndex:3] setAlpha:0.0f];
			break;
		}
		case kMxoViewFlow2RenderingAction_ReplaceBackView: {
			[viewWrapper setHidden:NO];
			[self _transformForViewWrapper:viewWrapper];
			[viewWrapper addBackSubview:[action objectAtIndex:3]]; [[action objectAtIndex:3] setAlpha:0.0f];
			break;
		}
		case kMxoViewFlow2RenderingAction_FadeInFrontAndBackView: {
			[viewWrapper setHidden:NO];
			[self _transformForViewWrapper:viewWrapper];
			[viewWrapper addFrontSubview:[action objectAtIndex:1]]; [[action objectAtIndex:1] setAlpha:0.0f];
			[viewWrapper addBackSubview:[action objectAtIndex:3]]; [[action objectAtIndex:3] setAlpha:0.0f];
			break;
		}
		case kMxoViewFlow2RenderingAction_FadeInFrontView: {
			[viewWrapper setHidden:NO];
			[self _transformForViewWrapper:viewWrapper];
			[viewWrapper addFrontSubview:[action objectAtIndex:1]]; [[action objectAtIndex:1] setAlpha:0.0f];
			break;
		}
		case kMxoViewFlow2RenderingAction_FadeInBackView: {
			[viewWrapper setHidden:NO];
			[self _transformForViewWrapper:viewWrapper];
			[viewWrapper addBackSubview:[action objectAtIndex:1]]; [[action objectAtIndex:1] setAlpha:0.0f];
			break;
		}
		case kMxoViewFlow2RenderingAction_FadeOutFrontAndBackView: {
			[viewWrapper setHidden:YES];
			break;
		}
		case kMxoViewFlow2RenderingAction_FadeOutFrontView: {
			[viewWrapper setHidden:YES];
			break;
		}
		case kMxoViewFlow2RenderingAction_FadeOutBackView: {
			[viewWrapper setHidden:YES];
			break;
		}
		default: {
			break;
		}
	}
}

- (void)_transformForViewWrapper:(MxoDoubleSidedView *)viewWrapper {
	if (!viewWrapper.isHidden) {
		CATransform3D t = CATransform3DIdentity;
		[viewWrapper.layer setTransform:t];
	}
}

- (void)_renderFadeInWithAction:(NSMutableArray *)action {
	MxoViewFlow2RenderingAction a = (int)[(NSNumber *)[action objectAtIndex:0] unsignedIntegerValue];
	switch (a) {
		case kMxoViewFlow2RenderingAction_ReplaceFrontAndBackView: {
			[[action objectAtIndex:3] setAlpha:[(NSNumber *)[action objectAtIndex:4] floatValue]];
			[[action objectAtIndex:7] setAlpha:[(NSNumber *)[action objectAtIndex:8] floatValue]];
			break;
		}
		case kMxoViewFlow2RenderingAction_ReplaceFrontView: {
			[[action objectAtIndex:3] setAlpha:[(NSNumber *)[action objectAtIndex:4] floatValue]];
			break;
		}
		case kMxoViewFlow2RenderingAction_ReplaceBackView: {
			[[action objectAtIndex:3] setAlpha:[(NSNumber *)[action objectAtIndex:4] floatValue]];
			break;
		}
		case kMxoViewFlow2RenderingAction_FadeInFrontAndBackView: {
			[[action objectAtIndex:1] setAlpha:[(NSNumber *)[action objectAtIndex:2] floatValue]];
			[[action objectAtIndex:3] setAlpha:[(NSNumber *)[action objectAtIndex:4] floatValue]];
			break;
		}
		case kMxoViewFlow2RenderingAction_FadeInFrontView: {
			[[action objectAtIndex:1] setAlpha:[(NSNumber *)[action objectAtIndex:2] floatValue]];
			break;
		}
		case kMxoViewFlow2RenderingAction_FadeInBackView: {
			[[action objectAtIndex:1] setAlpha:[(NSNumber *)[action objectAtIndex:2] floatValue]];
			break;
		}
		case kMxoViewFlow2RenderingAction_FadeOutFrontAndBackView: {
			break;
		}
		case kMxoViewFlow2RenderingAction_FadeOutFrontView: {
			break;
		}
		case kMxoViewFlow2RenderingAction_FadeOutBackView: {
			break;
		}
		default: {
			break;
		}
	}
}

- (void)_renderViewInViewWrapper:(MxoDoubleSidedView *)viewWrapper animated:(BOOL)animated completion:(void (^)(BOOL))completion {
	NSMutableArray __block *action = [self _renderingActionForViewWrapper:viewWrapper];
    [self _renderFadeOutWithAction:action];
    [self _renderRemoveFromSuperviewWithAction:action];
    [self _renderInitializeViewInViewWrapper:viewWrapper withAction:action];
    [self _renderFadeInWithAction:action];
}

- (void)flipView{
    _isFlipping = YES;
    [UIView animateWithDuration:0.25f
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.layer.transform = CATransform3DIdentity;
                         [self.layer setTransform:CATransform3DRotate(self.layer.transform, M_PI/2.0f, 0.0f, 1.0f, 0.0f)];
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.25f
                                               delay:0.0
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              [self.layer setTransform:CATransform3DRotate(self.layer.transform, M_PI/2.0f, 0.0f, 1.0f, 0.0f)];
                                          }
                                          completion:^(BOOL finished) {
                                              [self _renderViewInViewWrapper:self animated:NO completion:^(BOOL finished) {
                                                  _isFlipping = NO;
                                                  [self removeBackViews];
                                              }];
                                          }];
                     }];
    
}

- (void)flipViewToFront{
    [UIView animateWithDuration:0.25f
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [self.layer setTransform:CATransform3DRotate(self.layer.transform, -M_PI/2.0f, 0.0f, 1.0f, 0.0f)];
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.25f
                                               delay:0.0
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              [self.layer setTransform:CATransform3DRotate(self.layer.transform, -M_PI/2.0f, 0.0f, 1.0f, 0.0f)];
                                          }
                                          completion:^(BOOL finished) {
                                              [self _renderViewInViewWrapper:self animated:NO completion:^(BOOL finished) {
                                              }];
                                          }];
                     }];
}

+ (Class)layerClass {
	return [CATransformLayer class];
}

+ (UIView *)_transformForBackView:(UIView *)view {
	[view.layer setDoubleSided:YES];
	return view;
}

- (id)init {
	self = [super init];
	if (self) {
		[self _initWithBackFlippedHorizontally:NO];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		_frontViews = [aDecoder decodeObjectForKey:@"_frontViews"];
		_backViews = [aDecoder decodeObjectForKey:@"_backViews"];
		_backIsFlippedHorizontally = [aDecoder decodeBoolForKey:@"_backIsFlippedHorizontally"];
		_faceBack = [aDecoder decodeBoolForKey:@"_faceBack"];
	}
	return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:_frontViews forKey:@"_frontViews"];
	[aCoder encodeObject:_backViews forKey:@"_backViews"];
	[aCoder encodeBool:_backIsFlippedHorizontally forKey:@"_backIsFlippedHorizontally"];
	[aCoder encodeBool:_faceBack forKey:@"_faceBack"];
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self _initWithBackFlippedHorizontally:NO];
	}
	return self;
}
- (id)initWithFrame:(CGRect)frame backIsFlippedHorizontally:(BOOL)flipHorizontally {
	self = [super initWithFrame:frame];
	if (self) {
		[self _initWithBackFlippedHorizontally:flipHorizontally];
	}
	return self;
}

- (void)_initWithBackFlippedHorizontally:(BOOL)flipHorizontally {
	_frontViews = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height)];
    _frontViews.backgroundColor = [UIColor clearColor];
	[_frontViews.layer setDoubleSided:YES];
	_backViews = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height)];
    _backViews.backgroundColor = [UIColor clearColor];
	[_backViews.layer setDoubleSided:YES];
	_backIsFlippedHorizontally = flipHorizontally;
	[_backViews.layer setTransform:CATransform3DTranslate(CATransform3DRotate(CATransform3DIdentity, M_PI, (_backIsFlippedHorizontally ? 1.0f : 0.0f), (_backIsFlippedHorizontally ? 0.0f : 1.0f), 0.0f), 0.0f, 0.0f, 0.00022f)];
	[super addSubview:_backViews];
	[super addSubview:_frontViews];
	_faceBack = NO;
    
    _isFlipping = NO;
}

- (void)addSubview:(UIView *)view {
	[self addFrontSubview:view];
}
- (void)addFrontSubview:(UIView *)view {
	[_frontViews addSubview:view];
}
- (void)addBackSubview:(UIView *)view {
	[_backViews addSubview:view];
}

- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index {
	[self insertFrontSubview:view atIndex:index];
}
- (void)insertFrontSubview:(UIView *)view atIndex:(NSInteger)index {
	[_frontViews insertSubview:view atIndex:index];
}
- (void)insertBackSubview:(UIView *)view atIndex:(NSInteger)index {
	[_backViews insertSubview:view atIndex:index];
}

- (void)insertSubview:(UIView *)view aboveSubview:(UIView *)siblingSubview {
	[self insertFrontSubview:view aboveSubview:siblingSubview];
}
- (void)insertFrontSubview:(UIView *)view aboveSubview:(UIView *)siblingSubview {
	[_frontViews insertSubview:view aboveSubview:siblingSubview];
}
- (void)insertBackSubview:(UIView *)view aboveSubview:(UIView *)siblingSubview {
	[_backViews insertSubview:view aboveSubview:siblingSubview];
}

- (void)insertSubview:(UIView *)view belowSubview:(UIView *)siblingSubview {
	[self insertFrontSubview:view belowSubview:siblingSubview];
}
- (void)insertFrontSubview:(UIView *)view belowSubview:(UIView *)siblingSubview {
	[_frontViews insertSubview:view belowSubview:siblingSubview];
}
- (void)insertBackSubview:(UIView *)view belowSubview:(UIView *)siblingSubview {
	[_backViews insertSubview:view belowSubview:siblingSubview];
}

- (void)removeBackViews{
//    if (_isFlipping) return;
    [[_backViews subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (NSArray *)subviews {
	return [self frontSubviews];
}

- (NSArray *)frontSubviews {
	return _frontViews.subviews;
}
- (NSArray *)backSubviews {
	return _backViews.subviews;
}

- (CALayer *)frontLayer {
	return _frontViews.layer;
}

- (CALayer *)backLayer {
	return _backViews.layer;
}

@end
