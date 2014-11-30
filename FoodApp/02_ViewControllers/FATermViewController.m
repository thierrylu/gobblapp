//
//  FATermViewController.m
//  FoodApp
//
//  Created by CHINH LE on 8/8/14.
//  Copyright (c) 2014 chinhlt. All rights reserved.
//

#import "FATermViewController.h"
#import "JCRBlurView.h"

@interface FATermViewController ()

@end

@implementation FATermViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(IBAction)keyPress:(id)sender{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.topNavBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [self.topNavBar setBackgroundColor:[UIColor clearColor]];

    UIBarButtonItem *itemRight = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"close.png"] style:UIBarButtonItemStylePlain target:self action:@selector(keyPress:)];
    [itemRight setTintColor:[UIColor whiteColor]];
    self.topBarItem.rightBarButtonItem = itemRight;
    
    if (isIOS7) {
        [itemRight setTintColor:[UIColor colorWithRed:120.0/255 green:120.0/255 blue:120.0/255 alpha:1.0]];
    }
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                           UITextAttributeTextColor: [UIColor colorWithRed:96.0/255.0 green:99.0/255.0 blue:102.0/255.0 alpha:1.0],
                                                           UITextAttributeFont: [UIFont fontWithName:@"MyriadPro-Regular" size:20.0],
                                                           UITextAttributeTextShadowColor: [UIColor clearColor],
                                                           }];
    
    [_termWebView setScalesPageToFit:YES];
    [_termWebView loadHTMLString:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TermsOfUse.html" ofType:nil] encoding:NSUTF8StringEncoding error:NULL] baseURL:nil];
    
    self.topBarItem.title = @"Term Of Use";
    
    if (isIOS7) {
    JCRBlurView *blurView = [JCRBlurView new];
    [blurView setTintColor:[UIColor whiteColor]];
    [blurView setFrame:CGRectMake(0.0f,0.0f, 320, 44.0 + addIOS7)];
    blurView.alpha = 0.98;
    [self.view addSubview:blurView];
    
    [self.view sendSubviewToBack:blurView];
    }
    [self.view sendSubviewToBack:_termWebView];
    
    _termWebView.scrollView.contentInset = UIEdgeInsetsMake(44.0 + addIOS7, 0, 0, 0);
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
