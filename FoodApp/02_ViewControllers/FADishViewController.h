//
//  FADishViewController.h
//  FoodApp
//
//  Created by CHINH LE on 6/25/14.
//  Copyright (c) 2014 chinhlt. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MAIN_LABEL_Y_ORIGIN 0
#define IMAGEVIEW_Y_ORIGIN 15

@interface FADishViewController : UIViewController{
    
}

@property (retain, nonatomic) IBOutlet UILabel *restaurantNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *dishNameLabel;
@property (retain, nonatomic) IBOutlet UIView *contentView;
@property (retain, nonatomic) IBOutlet UILabel *likeLabel;
@property (retain, nonatomic) IBOutlet UILabel *rateLabel;

@property (retain, nonatomic) IBOutlet UIImageView *imageView;
@property (retain, nonatomic) IBOutlet UIButton *doneBtn;

@property (retain, nonatomic) IBOutlet UIImageView *backgroundTopImageView;
@property (retain, nonatomic) IBOutlet UIImageView *backgroundBottomImageView;

@property (readwrite, nonatomic) int yOrigin;
@property (readwrite, nonatomic) int xOrigin;
@property (retain, nonatomic) NSMutableDictionary *dictForData;

- (IBAction)doneBtnPressed:(id)sender;

@end
