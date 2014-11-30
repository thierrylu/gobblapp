//  Created by Phillipus on 19/09/2013.
//  Copyright (c) 2013 Dada Beatnik. All rights reserved.
//

#import "CustomSegue.h"
#import "FAHomeViewController.h"

@implementation CustomSegue

-(UIImage *)imageWithView:(UIView *)_viewDraw{
    CGRect rectt = CGRectMake(0, 0, _viewDraw.frame.size.width, _viewDraw.frame.size.height);
    UIGraphicsBeginImageContext(rectt.size);
    [_viewDraw.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return viewImage;
}

- (void)perform {
    FAHomeViewController *sourceViewController = (FAHomeViewController *)self.sourceViewController;
    UIViewController *destinationViewController = self.destinationViewController;
    
    //Custom method to create an UIImage from a UIView
    UIImageView* sourceView = [[UIImageView alloc] initWithImage:[self imageWithView:sourceViewController.view]];
    [sourceViewController.view addSubview:sourceView];
    
    UIImageView* desView = [[UIImageView alloc] initWithImage:[self imageWithView:destinationViewController.view]];
    
    CGRect sourceFrame = sourceView.frame;
    
    if (self.isLeft == 1) {
        sourceFrame.origin.x = 0;
        sourceFrame.origin.y = 0;
    }
    else{
        sourceFrame.origin.x = -sourceViewController.view.frame.size.width/2;
        sourceFrame.origin.y = -sourceViewController.view.frame.size.height/2;
    }
    
    sourceFrame.size.width = sourceViewController.view.frame.size.width*2;
    sourceFrame.size.height = sourceViewController.view.frame.size.height*2;
    
    CGRect destinationFrame = desView.frame;
    
    destinationFrame.origin.x = 0;
    destinationFrame.origin.y = 0;
    
    destinationFrame.size.width = destinationViewController.view.frame.size.width;
    destinationFrame.size.height = destinationViewController.view.frame.size.height;
    
    if (self.isLeft == 1) {
        desView.frame = CGRectMake(0, 0, destinationViewController.view.frame.size.width/2, destinationViewController.view.frame.size.height/2);
    }
    else{
        desView.frame = CGRectMake(destinationViewController.view.frame.size.width/2, destinationViewController.view.frame.size.height/2, destinationViewController.view.frame.size.width, destinationViewController.view.frame.size.height);
    }
    
    
    desView.alpha = 0.0;
    [sourceViewController.view addSubview:desView];
    
    sourceViewController.contentView.hidden = YES;
    
    
    // Transformation start scale
//    destinationViewController.view.transform = CGAffineTransformMakeScale(0.05, 0.05);
//    
//    // Store original centre point of the destination view
//    CGPoint originalCenter = destinationViewController.view.center;
//    // Set center to start point of the button
//    destinationViewController.view.center = self.originatingPoint;
    
    [UIView animateWithDuration:0.75
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         desView.frame = destinationFrame;
                         desView.alpha = 1.0;
                         sourceView.frame = sourceFrame;
                         sourceView.alpha = 0.0;
//                         sourceViewController.view.alpha = 0.0;
                         
                     }
                     completion:^(BOOL finished){
                         
                         
                         [destinationViewController.view removeFromSuperview]; // remove from temp super view
                         [sourceViewController presentViewController:destinationViewController animated:NO completion:^{
//                             sourceViewController.view.alpha = 1.0;
                             [sourceView removeFromSuperview];
                             [desView removeFromSuperview];
                             sourceViewController.contentView.hidden = NO;
                         }]; // present VC
                     }];
}

@end
