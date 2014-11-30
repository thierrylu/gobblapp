//
//  RMTLocationDetailViewController.m
//  RateMyNight
//
//  Created by CHINH LE on 3/27/14.
//  Copyright (c) 2014 BrianLe. All rights reserved.
//

#import "RMTLocationDetailViewController.h"

@interface RMTLocationDetailViewController ()

@end

@implementation RMTLocationDetailViewController

@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)initLayoutCurrent{
    _lblTitle.text = @"Current Location";
    _lblTitle.frame = CGRectMake(_lblTitle.frame.origin.x, _lblTitle.frame.origin.y, _lblTitle.frame.size.width, _lblTitle.frame.size.height + 20);
    _lblTitle.font = [UIFont systemFontOfSize:16];
    _lblSubTitle.hidden = YES;
}

-(void)initLayout:(NSDictionary *)data{
    _lblTitle.text = [data objectForKey:@"title"];
    _lblSubTitle.text = [data objectForKey:@"message"];
    _lblTitle.font = [UIFont systemFontOfSize:14];
    _lblSubTitle.font = [UIFont systemFontOfSize:12];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)nextClub:(id)sender {
    [delegate touchNext];
}
@end
