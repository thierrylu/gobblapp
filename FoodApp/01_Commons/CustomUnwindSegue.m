//  Created by Phillipus on 20/09/2013.
//  Copyright (c) 2013 Dada Beatnik. All rights reserved.
//

#import "CustomUnwindSegue.h"
#import "FAHomeViewController.h"

@implementation CustomUnwindSegue

-(UIImage *)imageWithView:(UIView *)_viewDraw{
    CGRect rectt = CGRectMake(0, 0, _viewDraw.frame.size.width, _viewDraw.frame.size.height);
    UIGraphicsBeginImageContext(rectt.size);
    [_viewDraw.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return viewImage;
}

- (void)perform {
    UIViewController *sourceViewController = self.sourceViewController;
    FAHomeViewController *destinationViewController = (FAHomeViewController *)self.destinationViewController;
    
    //Custom method to create an UIImage from a UIView
    UIImageView* sourceView = [[UIImageView alloc] initWithImage:[self imageWithView:sourceViewController.view]];
    UIImageView* desView = [[UIImageView alloc] initWithImage:[self imageWithView:destinationViewController.view]];
    
    CGRect sourceFrame = sourceView.frame;
    if (self.isLeft == 1) {
        sourceFrame.origin.x = 0;
        sourceFrame.origin.y = 0;
    }
    else{
        sourceFrame.origin.x = sourceViewController.view.frame.size.width;
        sourceFrame.origin.y = sourceViewController.view.frame.size.height;
    }
    sourceFrame.size.width = sourceViewController.view.frame.size.width/2;
    sourceFrame.size.height = sourceViewController.view.frame.size.height/2;
    
    [sourceViewController.view addSubview:sourceView];
    
    CGRect destinationFrame = desView.frame;
    destinationFrame.origin.x = 0;
    destinationFrame.origin.y = 0;
    destinationFrame.size.width = destinationViewController.view.frame.size.width;
    destinationFrame.size.height = destinationViewController.view.frame.size.height;
    
    desView.frame = CGRectMake(0, -20, destinationViewController.view.frame.size.width*2, destinationViewController.view.frame.size.width*2);
    desView.alpha = 0.0;
    [sourceViewController.view addSubview:desView];
    
//    [sourceViewController.view addSubview:sourceView];
    
    // Add view to super view temporarily
    [sourceViewController.view.superview insertSubview:destinationViewController.view atIndex:0];
    
    [destinationViewController.scrollSelect stopScrollingDriver];
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         // Shrink!
                         sourceView.frame = sourceFrame;
                         sourceView.alpha = 1.0;
                         
                         desView.frame = destinationFrame;
                         desView.alpha = 1.0;
                     }
                     completion:^(BOOL finished){
//                         [sourceView removeFromSuperview];
                         [destinationViewController.view removeFromSuperview]; // remove from temp super view
                         [sourceViewController dismissViewControllerAnimated:NO completion:^{
                                [destinationViewController.scrollSelect startScrollingDriver];
                         }]; // dismiss VC
                     }];
}

@end
