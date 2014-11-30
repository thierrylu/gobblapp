//
//  FACellDish.h
//  FoodApp
//
//  Created by CHINH LE on 7/29/14.
//  Copyright (c) 2014 chinhlt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DLStarRatingControl.h"

@protocol FACellDishDelegate <NSObject>
@optional
-(void)handlePinchInGesture:(UIGestureRecognizer *)recognizer;

@end

@interface FACellDish : UICollectionViewCell{
    __strong IBOutlet UIView* _maskView;
    __strong IBOutlet UIImageView *_image;
    __strong IBOutlet UILabel* _label;
    __strong IBOutlet UILabel* _subLabel;
    __strong IBOutlet UIImageView* _heartImage;
    __strong IBOutlet UILabel* _countLikeLabel;
    DLStarRatingControl* _averRatingStar;
    
    NSObject<FACellDishDelegate> *_cellDelegate;
}
@property (nonatomic, strong) UIView* maskView;
@property (nonatomic, strong) UIImageView* image;
@property (nonatomic, strong) UILabel* label;
@property (nonatomic, strong) UILabel* subLabel;
@property (nonatomic, strong) UIImageView* heartImage;
@property (nonatomic, strong) UILabel* countLikeLabel;
@property (nonatomic, strong) DLStarRatingControl* averRatingStar;

@property (nonatomic, strong) NSNumber* remColum;
@property (nonatomic, strong) NSNumber* remSection;
@property (nonatomic, strong) NSNumber* remRow;

@property (nonatomic, strong) NSObject<FACellDishDelegate> *cellDelegate;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchIn;

@end
