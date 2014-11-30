//
//  FAAppDelegate.h
//  FoodApp
//
//  Created by CHINH LE on 6/9/14.
//  Copyright (c) 2014 chinhlt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationManager.h"
#import "Reachability.h"

@interface FAAppDelegate : UIResponder <UIApplicationDelegate, UIWebViewDelegate>{
    __strong LocationManager	  *_locationManager;
    BOOL _isLoggedIn;
    
    Reachability *_reachNetwork;
    BOOL _haveNetwork;
    
    NSString *_userFBId;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) LocationManager	  *locationManager;
@property (readwrite, nonatomic) BOOL isLoggedIn;
@property (readonly, strong, nonatomic) Reachability *reachNetwork;
@property (strong, nonatomic) NSString *userFBId;

- (void)setMaskTo:(UIView*)view byRoundingCorners:(UIRectCorner)corners angleCorner:(float)angle;
- (void)setBorderTo:(UIView*)view byRoundingCorners:(CGRect)rect color:(UIColor *)color;

@end
