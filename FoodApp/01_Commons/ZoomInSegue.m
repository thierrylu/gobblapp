//
//  ZoomInSegue.m
//  FoodApp
//
//  Created by CHINH LE on 6/25/14.
//  Copyright (c) 2014 chinhlt. All rights reserved.
//

#import "ZoomInSegue.h"

@implementation ZoomInSegue

-(UIImage *)imageWithView:(UIView *)_viewDraw{
    CGRect rectt = CGRectMake(0, 0, _viewDraw.frame.size.width, _viewDraw.frame.size.height);
    UIGraphicsBeginImageContext(rectt.size);
    [_viewDraw.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return viewImage;
}

- (void)perform {
    UIViewController* source = (UIViewController *)self.sourceViewController;
    UIViewController* destination = (UIViewController *)self.destinationViewController;
    
    //Custom method to create an UIImage from a UIView
    UIImageView* sourceView = [[UIImageView alloc] initWithImage:[self imageWithView:source.view]];
    
    CGRect sourceFrame = sourceView.frame;
    sourceFrame.origin.x = 0;
    sourceFrame.origin.y = 0;
    sourceFrame.size.width = 0;
    sourceFrame.size.height = 0;
    
    [source.view addSubview:destination.view];
    [source.view addSubview:sourceView];
    
    [UIView animateWithDuration:1.0
                     animations:^{
                         sourceView.frame = sourceFrame;
                         sourceView.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         [sourceView removeFromSuperview];
                         [destination.view removeFromSuperview];
                         [source dismissViewControllerAnimated:NO completion:NULL];
                     }];
}

@end
