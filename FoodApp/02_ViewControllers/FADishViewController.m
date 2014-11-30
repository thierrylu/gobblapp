//
//  FADishViewController.m
//  FoodApp
//
//  Created by CHINH LE on 6/25/14.
//  Copyright (c) 2014 chinhlt. All rights reserved.
//

#import "FADishViewController.h"

@interface FADishViewController ()

@end

@implementation FADishViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self.backgroundTopImageView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"expda-launch-linen.png"]]];
//    [self.backgroundBottomImageView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"expda-launch-linen.png"]]];
    
    
    self.imageView.image = [UIImage imageNamed:[self.dictForData objectForKey:@"image"]];
    self.restaurantNameLabel.text = [self.dictForData objectForKey:@"title"];
    self.dishNameLabel.text = [self.dictForData objectForKey:@"subtitle"];
    self.likeLabel.text = [self.dictForData objectForKey:@"countLike"];
    self.rateLabel.text = [NSString stringWithFormat:@"%@ reviews", [self.dictForData objectForKey:@"countRate"]];
    
    [self animateOnEntry];
}

- (void) animateOnEntry
{
    //set initial frames
    self.backgroundTopImageView.alpha = 0;
    self.backgroundBottomImageView.alpha = 0;
    
    self.backgroundTopImageView.frame = CGRectMake(0, -self.backgroundTopImageView.frame.size.height, self.backgroundTopImageView.frame.size.width, self.backgroundTopImageView.frame.size.height);
    self.backgroundBottomImageView.frame = CGRectMake(0, self.view.frame.size.height, self.backgroundBottomImageView.frame.size.width, self.backgroundBottomImageView.frame.size.height);
    
    self.restaurantNameLabel.frame = CGRectMake(self.restaurantNameLabel.frame.origin.x, -100.0, self.restaurantNameLabel.frame.size.width, self.restaurantNameLabel.frame.size.height);
    self.dishNameLabel.frame = CGRectMake(self.dishNameLabel.frame.origin.x, -100.0, self.dishNameLabel.frame.size.width, self.dishNameLabel.frame.size.height);
    self.imageView.frame = CGRectMake(self.xOrigin, self.yOrigin + IMAGEVIEW_Y_ORIGIN, 50, 50);
    self.doneBtn.frame = CGRectMake(self.doneBtn.frame.origin.x, 0-self.doneBtn.frame.size.height-20, self.doneBtn.frame.size.width, self.doneBtn.frame.size.height);
    
    self.contentView.frame = CGRectMake(self.contentView.frame.origin.x, self.view.frame.size.height, self.contentView.frame.size.width, self.contentView.frame.size.height);
    
    //apply animation on ENTERING INTO THE VIEW
    [UIView animateWithDuration:0.4f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(void)
     {
         self.restaurantNameLabel.frame = CGRectMake(self.restaurantNameLabel.frame.origin.x, 20.0, self.restaurantNameLabel.frame.size.width, self.restaurantNameLabel.frame.size.height);
         self.dishNameLabel.frame = CGRectMake(self.dishNameLabel.frame.origin.x, 40.0, self.dishNameLabel.frame.size.width, self.dishNameLabel.frame.size.height);
         self.doneBtn.frame = CGRectMake(self.doneBtn.frame.origin.x, 20, self.doneBtn.frame.size.width, self.doneBtn.frame.size.height);
         
         self.backgroundTopImageView.frame = CGRectMake(0, 0, self.backgroundTopImageView.frame.size.width, self.backgroundTopImageView.frame.size.height);
         self.backgroundTopImageView.alpha = 1;
         
         self.backgroundBottomImageView.frame = CGRectMake(0, self.backgroundBottomImageView.frame.size.height, self.backgroundBottomImageView.frame.size.width, self.backgroundBottomImageView.frame.size.height);
         self.backgroundBottomImageView.alpha = 1;
         
         self.imageView.frame = CGRectMake(60, 76, self.imageView.frame.size.width * 4, self.imageView.frame.size.height * 4);
         
         self.contentView.frame = CGRectMake(self.contentView.frame.origin.x, 292.0, self.contentView.frame.size.width, self.contentView.frame.size.height);
     }
                     completion:NULL];
}

- (IBAction)doneBtnPressed:(id)sender
{
    //animation on EXIT FROM CURRENT VIEW
    [UIView animateWithDuration:0.4f animations:^
     {
         self.restaurantNameLabel.frame = CGRectMake(self.restaurantNameLabel.frame.origin.x, -100.0, self.restaurantNameLabel.frame.size.width, self.restaurantNameLabel.frame.size.height);
         self.dishNameLabel.frame = CGRectMake(self.dishNameLabel.frame.origin.x, -100.0, self.dishNameLabel.frame.size.width, self.dishNameLabel.frame.size.height);
         self.imageView.frame = CGRectMake(self.xOrigin, self.yOrigin + IMAGEVIEW_Y_ORIGIN, CGRectGetWidth(self.imageView.frame) / 2, CGRectGetHeight(self.imageView.frame) / 2);
         self.doneBtn.frame = CGRectMake(self.doneBtn.frame.origin.x, 0-self.doneBtn.frame.size.height-20, self.doneBtn.frame.size.width, self.doneBtn.frame.size.height);
         
         self.backgroundTopImageView.frame = CGRectMake(0, -self.backgroundTopImageView.frame.size.height, self.backgroundTopImageView.frame.size.width, self.backgroundTopImageView.frame.size.height);
         self.backgroundTopImageView.alpha = 0;
         
         self.backgroundBottomImageView.frame = CGRectMake(0, self.view.frame.size.height, self.backgroundBottomImageView.frame.size.width, self.backgroundBottomImageView.frame.size.height);
         self.backgroundBottomImageView.alpha = 0;
         
         self.contentView.frame = CGRectMake(self.contentView.frame.origin.x, self.view.frame.size.height, self.contentView.frame.size.width, self.contentView.frame.size.height);
     }
                     completion:^(BOOL finished)
     {
         [self.navigationController popViewControllerAnimated:NO];
     }
     ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
