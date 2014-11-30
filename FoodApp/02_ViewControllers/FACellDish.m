//
//  FACellDish.m
//  FoodApp
//
//  Created by CHINH LE on 7/29/14.
//  Copyright (c) 2014 chinhlt. All rights reserved.
//

#import "FACellDish.h"

@implementation FACellDish

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


-(void)awakeFromNib{
    
    self.image.contentMode = UIViewContentModeScaleAspectFit;
    
    self.label.frame = CGRectMake(5.0, 135.0, 135.0, 20.0);
    self.label.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.label setBackgroundColor:[UIColor clearColor]];
    [self.label setTextColor:[UIColor colorWithRed:96.0/255 green:99.0/255 blue:102.0/255 alpha:1.0]];
    [self.label setTextAlignment:NSTextAlignmentLeft];
    [self.label setFont:[UIFont fontWithName:@"Roboto-Light" size:11.0]];
    
    self.subLabel.frame = CGRectMake(5.0, 150.0, 135.0, 15.0);
    self.subLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.subLabel setBackgroundColor:[UIColor clearColor]];
    [self.subLabel setTextColor:[UIColor colorWithRed:202.0/255 green:193.0/255 blue:191.0/255 alpha:1.0]];
    [self.subLabel setTextAlignment:NSTextAlignmentLeft];
    [self.subLabel setFont:[UIFont fontWithName:@"Roboto-Light" size:8.0]];
    
    self.heartImage.frame = CGRectMake(5.0, 181.0, 10, 10);
    self.heartImage.image = [UIImage imageNamed:@"like.png"];
    self.heartImage.contentMode = UIViewContentModeScaleAspectFit;
    
    self.countLikeLabel.frame = CGRectMake(20.0, 175.0, 40.0, 20);
    self.countLikeLabel.textColor = [UIColor colorWithRed:120.0/255 green:120.0/255 blue:120.0/255 alpha:1.0];
    [self.countLikeLabel setFont:[UIFont fontWithName:@"Roboto-Light" size:12.0]];
    
    self.averRatingStar = [[DLStarRatingControl alloc] initWithFrame:CGRectMake(45.0, 175.0, 165.0 - 60.0, 20) andStars:5 isFractional:NO andScale:2.5];
    self.averRatingStar.backgroundColor = [UIColor clearColor];
    self.averRatingStar.rating = 2;
    self.averRatingStar.userInteractionEnabled = NO;
    [self addSubview:self.averRatingStar];
    
//    self.layer.shadowColor = [UIColor blackColor].CGColor;
//    self.layer.shadowOpacity = 0.7f;
//    self.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
//    self.layer.shadowRadius = 1.0f;
//    self.layer.masksToBounds = NO;
//    
//    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bounds];
//    self.layer.shadowPath = path.CGPath;
//    
//    [self.layer setRasterizationScale:[[UIScreen mainScreen] scale]];
//    [self.layer setShouldRasterize:YES];
    
//    UIPinchGestureRecognizer *pinchIn = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchInGesture:)];
//    [self addGestureRecognizer:pinchIn];
}

-(void)handlePinchInGesture:(UIGestureRecognizer *)recognizer{
    [self.cellDelegate handlePinchInGesture:recognizer];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
