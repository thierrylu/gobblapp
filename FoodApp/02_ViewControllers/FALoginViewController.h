//
//  FALoginViewController.h
//  FoodApp
//
//  Created by CHINH LE on 6/26/14.
//  Copyright (c) 2014 chinhlt. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FALoginViewController : UIViewController <FBLoginViewDelegate>{
    __weak IBOutlet UIImageView *_loginImvBgMask;
    __weak IBOutlet UIImageView *_loginImvBg;
    __weak IBOutlet UIImageView *_loginImvBg2;
    __weak IBOutlet UILabel *_lblConnect;
    UIButton *_loginButton;
    
    BOOL _isGoToHome;
    BOOL _isTouchOnButton;
    
    __weak IBOutlet UIButton *_btnConnect;
    FBLoginView *loginView;
}

-(IBAction)loginButtonClicked:(id)sender;

@end
