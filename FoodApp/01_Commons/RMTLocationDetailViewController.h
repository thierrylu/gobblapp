//
//  RMTLocationDetailViewController.h
//  RateMyNight
//
//  Created by CHINH LE on 3/27/14.
//  Copyright (c) 2014 BrianLe. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RMTLocationDetailViewDelegate <NSObject>
@optional
-(void)touchNext;

@end

@interface RMTLocationDetailViewController : UIViewController{
    
    __weak IBOutlet UILabel *_lblTitle;
    __weak IBOutlet UILabel *_lblSubTitle;
    
    id<RMTLocationDetailViewDelegate> delegate;
}

@property (nonatomic, strong) id<RMTLocationDetailViewDelegate> delegate;
@property (nonatomic, weak) IBOutlet UILabel *lblTitle;
@property (nonatomic, weak) IBOutlet UILabel *lblSubTitle;

- (IBAction)nextClub:(id)sender;
-(void)initLayout:(NSDictionary *)data;
-(void)initLayoutCurrent;

@end
