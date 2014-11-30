//
//  TWSpringyFlowLayout.m
//  CollectionView
//
//  Created by Terry Worona on 8/15/13.
//  Copyright (c) 2013 Terry Worona. All rights reserved.
//

#import "TWSpringyFlowLayout.h"

// Numerics
CGFloat const kTWSpringyFlowLayoutDefaultBounce = 500.0f;

@interface TWSpringyFlowLayout ()

@property (nonatomic, assign) CGFloat bounceFactor;

@end

@implementation TWSpringyFlowLayout{
	UIDynamicAnimator *_dynamicAnimator;
}

#pragma mark - Alloc/Init

- (id)initWithBounceFactor:(CGFloat)bounceFactor
{
	self = [super init];
	if (self)
	{
		_bounceFactor = bounceFactor;
	}
	return self;
}

- (id)init
{
	return [self initWithBounceFactor:kTWSpringyFlowLayoutDefaultBounce];
}

#pragma - Prepareness

- (void)prepareLayout
{
	[super prepareLayout];
	
	if (!_dynamicAnimator)
	{
        _canEffect = YES;
        
		_dynamicAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];

		CGSize contentSize = [self collectionViewContentSize];
		NSArray *items = [super layoutAttributesForElementsInRect:CGRectMake(0, 0, contentSize.width, contentSize.height)];
		
		for (UICollectionViewLayoutAttributes *item in items)
		{
			UIAttachmentBehavior *spring = [[UIAttachmentBehavior alloc] initWithItem:item attachedToAnchor:[item center]];
			spring.length = 0;
			spring.damping = 0.5;
			spring.frequency = 0.8;
			[_dynamicAnimator addBehavior:spring];
		}
	}
}

#pragma mark - Layout

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
	return [_dynamicAnimator itemsInRect:rect];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
	return [_dynamicAnimator layoutAttributesForCellAtIndexPath:indexPath];
}

-(void)removeAll{
    
//    for (UIAttachmentBehavior *spring in _dynamicAnimator.behaviors) {
//        spring.length = 0.0;
//        spring.damping = 0.5;
//        spring.frequency = 0.8;
//        UICollectionViewLayoutAttributes *item = [spring.items firstObject];
//        
//        [_dynamicAnimator updateItemUsingCurrentState:item];
//    }
//    
//    [self performSelector:@selector(loadAll) withObject:nil afterDelay:0.1];
    
}

-(void)loadAll{
    
    for (UIAttachmentBehavior *spring in _dynamicAnimator.behaviors) {
        spring.length = 0;
        spring.damping = 0.5;
        spring.frequency = 0.8;
        UICollectionViewLayoutAttributes *item = [spring.items firstObject];
        [_dynamicAnimator updateItemUsingCurrentState:item];
    }
}


- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
	UIScrollView *scrollView = self.collectionView;
	CGFloat scrollDelta = newBounds.origin.y - scrollView.bounds.origin.y;
	CGPoint touchLocation = [scrollView.panGestureRecognizer locationInView:scrollView];
	
	for (UIAttachmentBehavior *spring in _dynamicAnimator.behaviors)
	{
		
        
		if (_canEffect && [spring isKindOfClass:[UIAttachmentBehavior class]]) {
            CGPoint anchorPoint = spring.anchorPoint;
            CGFloat distanceFromTouch = fabsf(touchLocation.y - anchorPoint.y);
            CGFloat scrollResistance = distanceFromTouch / _bounceFactor; // higher the number, larger the bounce
            
            UICollectionViewLayoutAttributes *item = [spring.items firstObject];
            
            CGPoint center = item.center;
//            NSLog(@"vo1: %d", spring.items.count);
            
            center.y += scrollDelta * scrollResistance;
            item.center = CGPointMake(center.x, center.y);
            
//            NSLog(@"vo2: %f", item.center.y);
            
            [_dynamicAnimator updateItemUsingCurrentState:item];
        }
	}
	
	return YES;
}

@end
