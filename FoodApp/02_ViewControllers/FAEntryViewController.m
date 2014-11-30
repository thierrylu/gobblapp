//
//  FAEntryViewController.m
//  FoodApp
//
//  Created by CHINH LE on 6/25/14.
//  Copyright (c) 2014 chinhlt. All rights reserved.
//

#import "FAEntryViewController.h"
#import "LocationManager.h"

@interface FAEntryViewController ()

@end

@implementation FAEntryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)leftBarButtonClicked{
    
    self.topBarItem.rightBarButtonItem = nil;
    
    if (self.viewComment.frame.origin.x == 0) {
        [self.txtComment resignFirstResponder];
        self.countCharCom.hidden = YES;
        
        self.lblCom.text = @"";
        self.lblCom.hidden = YES;
        self.btnOpenEditComment.hidden = YES;
        self.btnAddComment.hidden = NO;
        
        if (self.txtComment.text.length > 0) {
            self.lblCom.text = self.txtComment.text;
            self.lblCom.hidden = NO;
            self.btnOpenEditComment.hidden = NO;
            self.btnAddComment.hidden = YES;
        }
        
        [UIView animateWithDuration:0.35 animations:^{
            self.contentView.frame = CGRectMake(0, self.contentView.frame.origin.y, 320, self.contentView.frame.size.height);
            self.viewComment.frame = CGRectMake(320, self.viewComment.frame.origin.y, 320, self.viewComment.frame.size.height);
        } completion:^(BOOL finished) {
            
        }];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/drafts/%@", urlReal, [_dataItem objectForKey:@"_id"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        
        __weak typeof(ASIFormDataRequest *) weakSelf = request;
        
        [request setCompletionBlock:^{
            NSString *theJSON = [weakSelf responseString];
            NSLog(@"requestUpdateDishDidFinish:%@", theJSON);
            
            SBJsonParser *parser = [[SBJsonParser alloc] init];
            
            NSString *status = [[parser objectWithString:theJSON] objectForKey:@"status"];
            NSDictionary *data = [[parser objectWithString:theJSON] objectForKey:@"data"];
            
            if ([status isEqualToString:@"ok"] && _finalStep) {
                _currentStep++;
                self.topBarItem.title = @"";
                
                //        [UIView animateWithDuration:0.35 animations:^{
                //            self.resultView.frame = CGRectMake(0, self.resultView.frame.origin.y, self.resultView.frame.size.width, self.resultView.frame.size.height);
                //
                //        } completion:^(BOOL finished) {
                //
                //        }];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"loadDataAgainWhenUploaded" object:data userInfo:nil];
                
                
                
                @try {
                    [self.presentingViewController performSegueWithIdentifier:@"CustomUnwindSegue" sender:nil];
                }
                @catch (NSException *exception) {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
                @finally {
                    
                }
                
                //        [self.presentingViewController performSegueWithIdentifier:@"CustomUnwindSegue" sender:nil];
                
            }else if(_finalStep){
                //        _currentStep++;
                //        self.topBarItem.title = @"";
                //        [self.resultButton setImage:[UIImage imageNamed:@"icon_upload_fail.png"] forState:UIControlStateNormal];
                //        
                //        [UIView animateWithDuration:0.35 animations:^{
                //            self.resultView.frame = CGRectMake(0, self.resultView.frame.origin.y, self.resultView.frame.size.width, self.resultView.frame.size.height);
                //            
                //        } completion:^(BOOL finished) {
                //            
                //        }];
                
                
            }
        }];
        
        [request setFailedBlock:^{
            NSString *theJSON = [weakSelf responseString];
            NSLog(@"requestUpdateDishDidFail:%@", theJSON);
        }];
        
        [request setRequestMethod:@"PUT"];
        [request addRequestHeader:@"Content-Type" value:@"application/json"];
        ;
        
        SBJsonWriter *writerJSON = [[SBJsonWriter alloc] init];
        NSString *jsonString = [writerJSON stringWithObject:[NSMutableDictionary dictionaryWithObjectsAndKeys: self.txtComment.text, @"comment", nil]];
        
        NSMutableData *data = [[NSMutableData alloc] initWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
        [request setPostBody:data];
        
        if (cookie) {
            [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
        }
        
        [request startAsynchronous];
        
        return;
    }
    
    if (self.mapView.frame.origin.x == 0) {
        self.topBarItem.title = @"";
        
        UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(50, 0, self.view.frame.size.width - 100.0, 44.0)];
        titleView.backgroundColor = [UIColor clearColor];
        self.topBarItem.titleView = titleView;
        
        UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, titleView.frame.size.width, 20)];
        titleLbl.backgroundColor = [UIColor clearColor];
        titleLbl.textColor = [UIColor colorWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1.0];
        titleLbl.textAlignment = NSTextAlignmentCenter;
        titleLbl.text = self.dishLabel.text;
        titleLbl.font = [UIFont systemFontOfSize:18.0];
        titleLbl.adjustsFontSizeToFitWidth = YES;
        [titleView addSubview:titleLbl];
        
        UILabel *subtitleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, titleView.frame.size.width, 20)];
        subtitleLbl.backgroundColor = [UIColor clearColor];
        subtitleLbl.textColor = [UIColor colorWithRed:120.0/255 green:120.0/255 blue:120.0/255 alpha:1.0];
        subtitleLbl.textAlignment = NSTextAlignmentCenter;
        subtitleLbl.text = self.restaurantLabel.text;
        subtitleLbl.font = [UIFont systemFontOfSize:14.0];
        subtitleLbl.adjustsFontSizeToFitWidth = YES;
        [titleView addSubview:subtitleLbl];
        
        
        [UIView animateWithDuration:0.35 animations:^{
            self.mapView.frame = CGRectMake(self.view.frame.size.width, self.mapView.frame.origin.y, self.mapView.frame.size.width, self.mapView.frame.size.height);
            
        } completion:^(BOOL finished) {
            
        }];
        
        return;
    }
    
    [self.view findAndResignFirstResponder];
    
    searchingDish = NO;
    searchingRest = NO;
    
    [self.tblRestaurant reloadData];
    [self.tblDish reloadData];
    
    self.searchBar.text = @"";
    self.searchBarDish.text = @"";
    
    if (_currentStep == 1) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if(_currentStep == 2){
        _currentStep--;
        self.topBarItem.title = @"Where are you eating?";
        self.topBarItem.titleView = nil;
        
        _currentSelectRestaurant = -1;
        [_tblRestaurant reloadData];
        
        [UIView animateWithDuration:0.35 animations:^{
            self.tblRestaurant.frame = CGRectMake(60, 0, self.tblRestaurant.frame.size.width, self.tblRestaurant.frame.size.height);
            self.tblDish.frame = CGRectMake(self.view.frame.size.width, 0, self.tblDish.frame.size.width, self.tblDish.frame.size.height);
            self.searchBar.frame = CGRectMake(53, self.searchBar.frame.origin.y, self.searchBar.frame.size.width, self.searchBar.frame.size.height);
            self.searchBarDish.frame = CGRectMake(self.view.frame.size.width, self.searchBarDish.frame.origin.y, self.searchBarDish.frame.size.width, self.searchBarDish.frame.size.height);
        } completion:^(BOOL finished) {
            
        }];
    }
    else if(_currentStep == 3){
        _currentStep--;
        self.topBarItem.title = @"";
        
        UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(50, 0, self.view.frame.size.width - 100.0, 44.0)];
        titleView.backgroundColor = [UIColor clearColor];
        self.topBarItem.titleView = titleView;
        
        UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, titleView.frame.size.width, 25)];
        titleLbl.backgroundColor = [UIColor clearColor];
        titleLbl.textColor = [UIColor colorWithRed:96.0/255 green:99.0/255 blue:102.0/255 alpha:1.0];
        titleLbl.textAlignment = NSTextAlignmentCenter;
        titleLbl.text = @"What are you eating?";
        titleLbl.font = [UIFont systemFontOfSize:18.0];
        titleLbl.adjustsFontSizeToFitWidth = YES;
        [titleView addSubview:titleLbl];
        
        UILabel *subtitleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, titleView.frame.size.width, 20)];
        subtitleLbl.backgroundColor = [UIColor clearColor];
        subtitleLbl.textColor = [UIColor colorWithRed:111.0/255 green:111.0/255 blue:111.0/255 alpha:1.0];
        subtitleLbl.textAlignment = NSTextAlignmentCenter;
        subtitleLbl.text = [[arrRestaurant objectAtIndex:_currentSelectRestaurant] objectForKey:@"name"];
        subtitleLbl.font = [UIFont systemFontOfSize:11.0];
        subtitleLbl.adjustsFontSizeToFitWidth = YES;
        [titleView addSubview:subtitleLbl];
        
        _currentSelectedDish = -1;
        [_tblDish reloadData];
        
        [UIView animateWithDuration:0.35 animations:^{
            self.ratingView.frame = CGRectMake(320.0, self.ratingView.frame.origin.y, self.ratingView.frame.size.width, self.ratingView.frame.size.height);
            
            self.tblDish.frame = CGRectMake(60, 0, self.tblDish.frame.size.width, self.tblDish.frame.size.height);
            self.searchBarDish.frame = CGRectMake(60, self.searchBarDish.frame.origin.y, self.searchBarDish.frame.size.width, self.searchBarDish.frame.size.height);
            
        } completion:^(BOOL finished) {
            
        }];
    }
    else if (_currentStep == 4){
        self.topBarItem.title = @"";
        self.topBarItem.titleView = nil;
        
        _currentStep--;
        [UIView animateWithDuration:0.35 animations:^{
            self.ratingView.frame = CGRectMake(self.view.frame.size.width, self.ratingView.frame.origin.y, self.ratingView.frame.size.width, self.ratingView.frame.size.height);
            
            self.imvIcn1.alpha = 1.0;
            self.imvIcn2.alpha = 1.0;
            self.mapButton.alpha = 1.0;
            
            self.restaurantLabel.alpha = 1.0;
            self.dishLabel.alpha = 1.0;
            
        } completion:^(BOOL finished) {
            
        }];
    }
}

-(void)touchOnTag:(UIButton *)sender{
    for (UIButton *btn in self.tagScrollView.subviews) {
        btn.layer.borderWidth = 0.0;
    }
    
    if (sender.tag - 888 == arrTag.count) {
        txtTag.hidden = NO;
        [txtTag becomeFirstResponder];
        
        self.imvView.frame = CGRectMake(self.imvView.frame.origin.x, -80, self.imvView.frame.size.width, self.imvView.frame.size.height);
        self.ratingView.frame = CGRectMake(self.ratingView.frame.origin.x, 198, self.ratingView.frame.size.width, self.ratingView.frame.size.height);
        sender.hidden = YES;
    }
    else{
        _currentSelectedTag = sender.tag - 888;

        sender.layer.borderWidth = 2.0;
        sender.layer.borderColor = [UIColor whiteColor].CGColor;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == txtTag) {
        [textField resignFirstResponder];
        
        if (txtTag.text.length == 0) {
            txtTag.text = @"";
            
            self.imvView.frame = CGRectMake(self.imvView.frame.origin.x, 10, self.imvView.frame.size.width, self.imvView.frame.size.height);
            self.ratingView.frame = CGRectMake(self.ratingView.frame.origin.x, 278, self.ratingView.frame.size.width, self.ratingView.frame.size.height);
            
            txtTag.hidden = YES;
            
            [[self.tagScrollView viewWithTag:arrTag.count+888] setHidden:NO];
            return YES;
        }
        
        [arrTag addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:textField.text, @"name", nil]];
        
        txtTag.text = @"";
        
        self.imvView.frame = CGRectMake(self.imvView.frame.origin.x, 10, self.imvView.frame.size.width, self.imvView.frame.size.height);
        self.ratingView.frame = CGRectMake(self.ratingView.frame.origin.x, 278, self.ratingView.frame.size.width, self.ratingView.frame.size.height);
        
        int rowIndex = 0;
        int colIndex = 0;
        float posX = 0;
        for (int i=0; i < arrTag.count + 1; i++) {
            if (i == arrTag.count - 1) {
                UIButton *btnTag = [[UIButton alloc] initWithFrame:CGRectMake(colIndex * 77, rowIndex * 34, 67, 24)];
                btnTag.backgroundColor = [UIColor colorWithRed:79.0/255 green:195.0/255 blue:212.0/255 alpha:1.0];
                [btnTag setTitle:[[arrTag objectAtIndex:i] objectForKey:@"name"] forState:UIControlStateNormal];
                [btnTag setImage:nil forState:UIControlStateNormal];
                
                [btnTag setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                btnTag.tag = i + 888;
                btnTag.titleLabel.font = [UIFont systemFontOfSize:11.0];
                [btnTag addTarget:self action:@selector(touchOnTag:) forControlEvents:UIControlEventTouchUpInside];
                [self.tagScrollView addSubview:btnTag];
                
                btnTag.layer.borderWidth = 2.0;
                btnTag.layer.borderColor = [UIColor whiteColor].CGColor;
                
                _currentSelectedTag = arrTag.count - 1;
            }
            else if(i == arrTag.count){
                [[self.tagScrollView viewWithTag:i+888] setFrame:CGRectMake(colIndex * 77, rowIndex * 34, 67, 24)];
                [[self.tagScrollView viewWithTag:i+888] setHidden:NO];
                
                txtTag.hidden = YES;
                txtTag.frame = CGRectMake(colIndex * 77, rowIndex * 34, 67, 24);
                
                UIButton *btnTag = [[UIButton alloc] initWithFrame:CGRectMake(colIndex * 77, rowIndex * 34, 67, 24)];
                btnTag.backgroundColor = [UIColor clearColor];
                [btnTag setTitle:@"" forState:UIControlStateNormal];
                [btnTag setImage:[UIImage imageNamed:@"add.png"] forState:UIControlStateNormal];
                
                [btnTag setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                btnTag.tag = i + 888;
                btnTag.titleLabel.font = [UIFont systemFontOfSize:11.0];
                [btnTag addTarget:self action:@selector(touchOnTag:) forControlEvents:UIControlEventTouchUpInside];
                [self.tagScrollView addSubview:btnTag];
            }
            
            posX = colIndex * 77;
            
            rowIndex++;
            if (rowIndex > 1) {
                rowIndex = 0;
                colIndex++;
            }
        }
        
        NSLog(@"ff:%f", self.tagScrollView.contentOffset.x);
        
        if (self.tagScrollView.contentSize.width < posX + 100) {
            [self.tagScrollView setContentOffset:CGPointMake(self.tagScrollView.contentOffset.x + 80, 0) animated:YES];
        }
        
        self.tagScrollView.contentSize = CGSizeMake(posX + 100, self.tagScrollView.frame.size.height);
        
        return YES;
    }
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    currentRating = 2;
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                           UITextAttributeTextColor: [UIColor colorWithRed:96.0/255.0 green:99.0/255.0 blue:102.0/255.0 alpha:1.0],
                                                           UITextAttributeFont: [UIFont fontWithName:@"MyriadPro-Regular" size:16.0],
                                                           UITextAttributeTextShadowColor: [UIColor clearColor],
                                                           }];
    
    [self.topNavBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [self.topNavBar setBackgroundColor:[UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1.0]];
    
    UIBarButtonItem *itemLeft = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonClicked)];
    [itemLeft setTintColor:[UIColor whiteColor]];
    self.topBarItem.leftBarButtonItem = itemLeft;
    
    self.topBarItem.title = @"Where are you eating?";
    
    if (isIOS7) {
        [itemLeft setTintColor:[UIColor colorWithRed:120.0/255 green:120.0/255 blue:120.0/255 alpha:1.0]];
    }
    
    self.okButton.layer.cornerRadius = 25.0;
    
    _currentStep = 1;
    
    customNumberOfStars = [[DLStarRatingControl alloc] initWithFrame:CGRectMake(0, 95, 320, 40) andStars:5 isFractional:NO andScale:1.2];
    customNumberOfStars.backgroundColor = [UIColor clearColor];
    customNumberOfStars.rating = 2;
    customNumberOfStars.delegate = self;
    [self.ratingView addSubview:customNumberOfStars];
    
    int rowIndex = 0;
    int colIndex = 0;
    float posX = 0;
    
    arrTag = [[NSMutableArray alloc] init];
    for (int i = 0; i < 43; i++) {
        [arrTag addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Tag %d", i + 1], @"name", nil]];
    }
    
    _currentSelectedTag = 0;
    for (int i=0; i < arrTag.count + 1; i++) {
        UIButton *btnTag = [[UIButton alloc] initWithFrame:CGRectMake(colIndex * 77, rowIndex * 34, 67, 24)];
        
        if (i <= arrTag.count - 1) {
            btnTag.backgroundColor = [UIColor colorWithRed:79.0/255 green:195.0/255 blue:212.0/255 alpha:1.0];
            [btnTag setTitle:[[arrTag objectAtIndex:i] objectForKey:@"name"] forState:UIControlStateNormal];
            [btnTag setImage:nil forState:UIControlStateNormal];
        }
        else{
            btnTag.backgroundColor = [UIColor clearColor];
            [btnTag setTitle:@"" forState:UIControlStateNormal];
            [btnTag setImage:[UIImage imageNamed:@"add.png"] forState:UIControlStateNormal];
            
            txtTag = [[UITextField alloc] initWithFrame:CGRectMake(colIndex * 77, rowIndex * 34, 67, 24)];
            txtTag.backgroundColor = [UIColor whiteColor];
            txtTag.tag = 9999;
            txtTag.delegate = self;
            txtTag.hidden = YES;
            txtTag.textAlignment = NSTextAlignmentCenter;
            txtTag.returnKeyType = UIReturnKeyDone;
            txtTag.font = [UIFont systemFontOfSize:11.0];
            txtTag.textColor = [UIColor colorWithRed:96.0/255 green:99.0/255 blue:102.0/255 alpha:1.0];
            [self.tagScrollView addSubview:txtTag];
        }
        [btnTag setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btnTag.tag = i + 888;
        btnTag.titleLabel.font = [UIFont systemFontOfSize:11.0];
        [btnTag addTarget:self action:@selector(touchOnTag:) forControlEvents:UIControlEventTouchUpInside];
        [self.tagScrollView addSubview:btnTag];
        
        posX = colIndex * 77;
        
        rowIndex++;
        if (rowIndex > 1) {
            rowIndex = 0;
            colIndex++;
        }
        
        if (i == 0) {
            btnTag.layer.borderWidth = 2.0;
            btnTag.layer.borderColor = [UIColor whiteColor].CGColor;
        }
    }
    
    self.tagScrollView.contentSize = CGSizeMake(posX + 100, self.tagScrollView.frame.size.height);
    
//    arrRestaurant = [[NSMutableArray alloc] init];
//    [arrRestaurant addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"", @"name", nil]];
//    for (int i = 0; i < 20; i++) {
//        [arrRestaurant addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Restaurant %d", i + 1], @"name", nil]];
//    }
//    [arrRestaurant addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"", @"name", nil]];
    
//    arrDish = [[NSMutableArray alloc] init];
//    [arrDish addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"", @"name", nil]];
//    for (int i = 0; i < 30; i++) {
//        [arrDish addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Dish %d", i + 1], @"name", nil]];
//    }
//    [arrDish addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"", @"name", nil]];
    
    _currentSelectRestaurant = -1;
    _currentSelectedDish = -1;
    
    searchingRest = NO;
    searchingDish = NO;
    
    [self.tblRestaurant reloadData];
    [self.tblDish reloadData];
    
//    CAGradientLayer *maskLayerTable1 = [CAGradientLayer layer];
//    
//    CGColorRef outerColor = [UIColor colorWithWhite:1.0 alpha:0.0].CGColor;
//    CGColorRef innerColor = [UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
//    
//    maskLayerTable1.colors = [NSArray arrayWithObjects:(__bridge id)outerColor,
//                             (__bridge id)innerColor, (__bridge id)innerColor, (__bridge id)outerColor, nil];
//    maskLayerTable1.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0],
//                                [NSNumber numberWithFloat:0.05],
//                                [NSNumber numberWithFloat:0.8],
//                                [NSNumber numberWithFloat:1.0], nil];
//    
//    maskLayerTable1.bounds = CGRectMake(0, 0,
//                                       self.selectionView.frame.size.width,
//                                       self.selectionView.frame.size.height);
//    maskLayerTable1.anchorPoint = CGPointZero;
//    self.selectionView.layer.mask = maskLayerTable1;
    
    UITapGestureRecognizer *tapOnView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnView)];
    tapOnView.numberOfTapsRequired = 1;
    tapOnView.numberOfTouchesRequired = 1;
    tapOnView.delegate = self;
    tapOnView.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapOnView];
    
//    [self.tblRestaurant setContentInset:UIEdgeInsetsMake(-20, 0, 10, 0)];
//    [self.tblDish setContentInset:UIEdgeInsetsMake(-15, 0, 10, 0)];
    
    if (isIOS7) {
        for (UIView *view in [[self.searchBar.subviews objectAtIndex:0] subviews]){
            NSLog(@"view:%@", view);
            if ([view isKindOfClass: [UITextField class]]) {
                UITextField *tf = (UITextField *)view;
//                tf.delegate = self;
                tf.font = [UIFont fontWithName:@"MyriadPro-Regular" size:14.0];
                break;
            }
        }
        for (UIView *view in [[self.searchBarDish.subviews objectAtIndex:0] subviews]){
            NSLog(@"view:%@", view);
            if ([view isKindOfClass: [UITextField class]]) {
                UITextField *tf = (UITextField *)view;
//                tf.delegate = self;
                tf.font = [UIFont fontWithName:@"MyriadPro-Regular" size:14.0];
                break;
            }
        }
    }
    else{
        for (UIView *view in self.searchBar.subviews){
            NSLog(@"view:%@", view);
            if ([view isKindOfClass: [UITextField class]]) {
                UITextField *tf = (UITextField *)view;
                tf.delegate = self;
                tf.font = [UIFont fontWithName:@"MyriadPro-Regular" size:14.0];
                break;
            }
        }
        for (UIView *view in self.searchBarDish.subviews){
            NSLog(@"view:%@", view);
            if ([view isKindOfClass: [UITextField class]]) {
                UITextField *tf = (UITextField *)view;
                tf.delegate = self;
                tf.font = [UIFont fontWithName:@"MyriadPro-Regular" size:14.0];
                break;
            }
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
    
    _remCurrentSelectRestaurant = -1;
    _remCurrentSelectedDish = -1;
    
    self.lblCom.lineBreakMode = NSLineBreakByWordWrapping;
    
    //self.restaurantLabel.font = [UIFont fontWithName:@"MyriadPro-Regular" size:14.0];
    //self.dishLabel.font = [UIFont fontWithName:@"MyriadPro-Regular" size:14.0];
    self.ratingLabel.font = [UIFont fontWithName:@"Roboto-Bold" size:16.0];
    self.ratingLabel.text = @"Decent...";
    
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies])
    {
        NSString* domainName = [cookie domain];
        NSLog(@"domain:%@, value:%@", domainName, cookie.value);
        NSRange domainRange = [domainName rangeOfString:urlReal];
        if(domainRange.length > 0)
        {
            break;
        }
    }
    
    if (!cookie) {
        cookie = [NSHTTPCookie cookieWithProperties:[[[NSUserDefaults standardUserDefaults] objectForKey:@"goobCookie"] objectForKey:urlReal]];
    }
    
    _currentPageIndexRest = 1;
    
   ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/restaurants?[{\"$input\":\"\", \"lat\":%f,\"lng\":%f},{\"page\":%d}]", urlReal, [LocationManager locationManager].currentLocation.coordinate.latitude, [LocationManager locationManager].currentLocation.coordinate.longitude, (int)_currentPageIndexRest] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    __weak typeof(ASIFormDataRequest *) weakSelf = request;
    
    [request setCompletionBlock:^{
        NSString *theJSON = [weakSelf responseString];
        NSLog(@"requestRestDidFinish:%@", theJSON);
        
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        if (arrRestaurant && arrRestaurant.count > 0) {
            [arrRestaurant addObjectsFromArray:[[parser objectWithString:theJSON] objectForKey:@"data"]];
            if ([[[parser objectWithString:theJSON] objectForKey:@"data"] count] > 0) {
                _currentPageIndexRest++;
            }
        }
        else{
            SAFE_RELEASE_ARRAY(arrRestaurant);
            arrRestaurant = [[NSMutableArray alloc] initWithArray:[[parser objectWithString:theJSON] objectForKey:@"data"]];
            
            _currentPageIndexAutoComplete = 1;
            
            
            ASIFormDataRequest *requestD = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/dishes/autocomplete?[{\"$input\":\"\"},{\"limit\":500,\"page\":%d}]", urlReal, (int)_currentPageIndexAutoComplete] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            
            __weak typeof(ASIFormDataRequest *) weakSelf = requestD;
            
            [requestD setCompletionBlock:^{
                NSString *theJSON = [weakSelf responseString];
                NSLog(@"requestDishDidFinish:%@", theJSON);
                
                _isLoadingMore = NO;
                
                SBJsonParser *parser = [[SBJsonParser alloc] init];
                
                if (!arrDish) {
                    arrDish = [[NSMutableArray alloc] initWithArray:[[parser objectWithString:theJSON] objectForKey:@"data"]];
                }
                else{
                    NSMutableArray *tmp = [[parser objectWithString:theJSON] objectForKey:@"data"];
                    if (tmp.count > 0) {
                        [arrDish addObjectsFromArray:tmp];
                    }
                }
                
                
                [_tblDish reloadData];
            }];
            
            [requestD setFailedBlock:^{
                NSString *theJSON = [weakSelf responseString];
                NSLog(@"requestDishDidFail:%@", theJSON);
                _isLoadingMore = NO;
            }];
            
            [requestD setRequestMethod:@"GET"];
            [requestD addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
            
            [requestD setUseCookiePersistence:NO];
            [requestD setUseSessionPersistence:NO];
            if (cookie) {
                [requestD setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
            }
            
            [requestD addRequestHeader:@"Vary" value:@"Accept-Encoding"];
            [requestD addRequestHeader:@"X-Powered-By" value:@"Express"];
            [requestD startAsynchronous];
        }
        
        [_tblRestaurant reloadData];
        _isLoadingMore = NO;
    }];
    
    [request setFailedBlock:^{
        NSString *theJSON = [weakSelf responseString];
        NSLog(@"requestRestDidFail:%@", theJSON);
    }];
    
    
    [request setRequestMethod:@"GET"];
    [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    
    [request setUseCookiePersistence:NO];
    [request setUseSessionPersistence:NO];
    if (cookie) {
        [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
    }
    
    [request addRequestHeader:@"Vary" value:@"Accept-Encoding"];
    [request addRequestHeader:@"X-Powered-By" value:@"Express"];
    [request startAsynchronous];
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{UITextAttributeTextColor: [UIColor colorWithRed:96.0/255 green:99.0/255 blue:102.0/255 alpha:1.0], UITextAttributeFont: [UIFont systemFontOfSize:18.0], UITextAttributeTextShadowColor: [UIColor clearColor]}];
    
    _finalStep = NO;
    
    self.txtComment.textColor = [UIColor colorWithRed:96.0/255 green:99.0/255 blue:102.0/255 alpha:1.0];
    self.txtComment.font = [UIFont fontWithName:@"MyriadPro-Regular" size:16.0];
    
    _isLoadingMore = NO;
    
    self.btnAddComment.titleLabel.font = [UIFont fontWithName:@"Roboto-Bold" size:18.0];
    self.btnAddComment.imageEdgeInsets = UIEdgeInsetsMake(-15, 0, 0, 0);
}

-(void)newRating:(DLStarRatingControl *)control :(float)rating{
    if (rating == 1) {
        self.ratingLabel.text = @"I've had better...";
        currentRating = 1;
    }
    else if (rating == 2) {
        self.ratingLabel.text = @"Decent...";
        currentRating = 2;
    }
    else if (rating == 3) {
        self.ratingLabel.text = @"Hit the spot!";
        currentRating = 3;
    }
    else if (rating == 4) {
        self.ratingLabel.text = @"Lip-smacking!";
        currentRating = 4;
    }
    else if (rating == 5) {
        self.ratingLabel.text = @"Delectable!";
        currentRating = 5;
    }
    else if (rating == 0) {
        self.ratingLabel.text = @"";
        currentRating = 0;
    }
}

-(void)keyboardWillShow{
//    self.imvView.frame = CGRectMake(self.imvView.frame.origin.x, -100, self.imvView.frame.size.width, self.imvView.frame.size.height);
    if (_currentStep == 1) {
//        self.contentView.frame = CGRectMake(self.contentView.frame.origin.x, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
    }
    else if (_currentStep == 2) {
//        self.searchBarDish.frame = CGRectMake(self.searchBarDish.frame.origin.x, 100, self.searchBarDish.frame.size.width, self.searchBarDish.frame.size.height);
    }
//    self.selectionView.frame = CGRectMake(self.selectionView.frame.origin.x, 140, self.selectionView.frame.size.width, self.selectionView.frame.size.height);
    
    
}

-(void)keyboardWillHide{
//    self.imvView.frame = CGRectMake(self.imvView.frame.origin.x, 10, self.imvView.frame.size.width, self.imvView.frame.size.height);
//    if (_currentStep == 1) {
//        self.searchBar.frame = CGRectMake(self.searchBar.frame.origin.x, 210, self.searchBar.frame.size.width, self.searchBar.frame.size.height);
//    }
//    else if (_currentStep == 2) {
//        self.searchBarDish.frame = CGRectMake(self.searchBarDish.frame.origin.x, 210, self.searchBarDish.frame.size.width, self.searchBarDish.frame.size.height);
//    }
//    self.selectionView.frame = CGRectMake(self.selectionView.frame.origin.x, 258, self.selectionView.frame.size.width, self.selectionView.frame.size.height);
    
    if (_currentStep == 1) {
        if (self.searchBar.text.length == 0) {
            searchingRest = NO;
            [_tblRestaurant reloadData];
        }
    }
    else if (_currentStep == 2) {
        if (self.searchBarDish.text.length == 0) {
            searchingDish = NO;
            [_tblDish reloadData];
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if (touch.view == self.tblRestaurant || touch.view == self.tblDish || [touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    return YES;
}

-(void)tapOnView{
    [self.searchBar resignFirstResponder];
    [self.searchBarDish resignFirstResponder];
    
    self.tblRestaurant.scrollEnabled = YES;
    self.tblDish.scrollEnabled = YES;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    NSLog(@"user:%@", [[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] objectForKey:@"_id"]);
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/drafts", urlReal] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    __weak typeof(ASIFormDataRequest *) weakSelf = request;
    
    [request setCompletionBlock:^{
        NSString *theJSON = [weakSelf responseString];
        NSLog(@"requestUploadPhotoDidFinish:%@", theJSON);
        
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        _dataItem = [[NSMutableDictionary alloc] initWithDictionary:[[parser objectWithString:theJSON] objectForKey:@"data"]];
        
        [MBProgressHUD hideAllHUDsForView:[kApplicationDelegate window] animated:YES];
    }];
    
    [request setFailedBlock:^{
        NSString *theJSON = [weakSelf responseString];
        NSLog(@"requestUploadPhotoDidFail:%@", theJSON);
        
        [MBProgressHUD hideAllHUDsForView:[kApplicationDelegate window] animated:YES];
    }];

    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Content-Type" value:@"image/jpeg"];
    
    [request setUseCookiePersistence:NO];
    [request setUseSessionPersistence:NO];
    
    if (cookie) {
        [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
    }
    
    [request addRequestHeader:@"Vary" value:@"Accept-Encoding"];
    [request addRequestHeader:@"X-Powered-By" value:@"Express"];
    
    NSData *imageData = UIImageJPEGRepresentation(_imvFromCamera, 1.0);
    if (!imageData || imageData.length < 10240) {
        imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"samplefood.jpg"], 1.0);
    }
    
//    [request addPostValue:imageData forKey:@"image"];
    [request setData:imageData withFileName:@"photo.jpg" andContentType:@"image/jpeg" forKey:@"image"];
    
    
//    [request addData:imageData forKey:@"photo"];
//    [request addPostValue:[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] objectForKey:@"_id"] forKey:@"user"];
    
    [request startAsynchronous];
    
    [MBProgressHUD showHUDAddedTo:[kApplicationDelegate window] animated:YES];
    
    if (IS_IPHONE5) {
        _countCharCom.frame = CGRectMake(_countCharCom.frame.origin.x, 260, _countCharCom.frame.size.width, _countCharCom.frame.size.height);
    }
    else{
        _countCharCom.frame = CGRectMake(_countCharCom.frame.origin.x, 170, _countCharCom.frame.size.width, _countCharCom.frame.size.height);
    }
}


-(IBAction)keyPress:(UIButton *)sender{
    if (sender == self.okButton) {
        if (_currentStep == 1) {
            _currentStep++;
            self.topBarItem.title = @"";
            
            UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(50, 0, self.view.frame.size.width - 100.0, 44.0)];
            titleView.backgroundColor = [UIColor clearColor];
            self.topBarItem.titleView = titleView;
            
            UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, titleView.frame.size.width, 25)];
            titleLbl.backgroundColor = [UIColor clearColor];
            titleLbl.textColor = [UIColor colorWithRed:96.0/255 green:99.0/255 blue:102.0/255 alpha:1.0];
            titleLbl.textAlignment = NSTextAlignmentCenter;
            titleLbl.text = @"What are you eating?";
            titleLbl.font = [UIFont systemFontOfSize:18.0];
            titleLbl.adjustsFontSizeToFitWidth = YES;
            [titleView addSubview:titleLbl];
            
            UILabel *subtitleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, titleView.frame.size.width, 20)];
            subtitleLbl.backgroundColor = [UIColor clearColor];
            subtitleLbl.textColor = [UIColor colorWithRed:111.0/255 green:111.0/255 blue:111.0/255 alpha:1.0];
            subtitleLbl.textAlignment = NSTextAlignmentCenter;
            if (searchingRest) {
                subtitleLbl.text = [[arrSearchRest objectAtIndex:_currentSelectRestaurant] objectForKey:@"name"];
            }
            else{
                subtitleLbl.text = [[arrRestaurant objectAtIndex:_currentSelectRestaurant] objectForKey:@"name"];
            }
            
            subtitleLbl.font = [UIFont systemFontOfSize:11.0];
            subtitleLbl.adjustsFontSizeToFitWidth = YES;
            [titleView addSubview:subtitleLbl];
            
            [UIView animateWithDuration:0.35 animations:^{
                self.tblRestaurant.frame = CGRectMake(-self.view.frame.size.width, 0, self.tblRestaurant.frame.size.width, self.tblRestaurant.frame.size.height);
                self.tblDish.frame = CGRectMake(60, 0, self.tblDish.frame.size.width, self.tblDish.frame.size.height);
                self.searchBar.frame = CGRectMake(-self.view.frame.size.width, self.searchBar.frame.origin.y, self.searchBar.frame.size.width, self.searchBar.frame.size.height);
                self.searchBarDish.frame = CGRectMake(53, self.searchBarDish.frame.origin.y, self.searchBarDish.frame.size.width, self.searchBarDish.frame.size.height);
            } completion:^(BOOL finished) {
                
            }];
            
        }
        else if (_currentStep == 2) {
            if (_currentSelectedDish == -1 || _currentSelectRestaurant == -1) {
                return;
            }
            _currentStep++;
            
            self.topBarItem.title = @"How was it?";
            self.topBarItem.titleView = nil;
            
//            self.restaurantLabel.text = [[arrRestaurant objectAtIndex:_currentSelectRestaurant] objectForKey:@"name"];
//            self.dishLabel.text = [[arrDish objectAtIndex:_currentSelectedDish] objectForKey:@"name"];
//            
//            [UIView animateWithDuration:0.35 animations:^{
//                self.tblDish.frame = CGRectMake(-self.view.frame.size.width, 0, self.tblDish.frame.size.width, self.tblDish.frame.size.height);
//                self.searchBarDish.frame = CGRectMake(-self.view.frame.size.width, self.searchBarDish.frame.origin.y, self.searchBarDish.frame.size.width, self.searchBarDish.frame.size.height);
//                
//                self.imvIcn1.alpha = 1.0;
//                self.imvIcn2.alpha = 1.0;
//                self.mapButton.alpha = 1.0;
//                
//                self.restaurantLabel.alpha = 1.0;
//                self.dishLabel.alpha = 1.0;
//                
//            } completion:^(BOOL finished) {
//                
//            }];
            
//            UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(50, 0, self.view.frame.size.width - 100.0, 44.0)];
//            titleView.backgroundColor = [UIColor clearColor];
//            self.topBarItem.titleView = titleView;
//            
//            UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, titleView.frame.size.width, 30)];
//            titleLbl.backgroundColor = [UIColor clearColor];
//            titleLbl.textColor = [UIColor colorWithRed:96.0/255 green:99.0/255 blue:102.0/255 alpha:1.0];
//            titleLbl.textAlignment = NSTextAlignmentCenter;
//            titleLbl.text = self.dishLabel.text;
//            titleLbl.font = [UIFont systemFontOfSize:18.0];
//            titleLbl.adjustsFontSizeToFitWidth = YES;
//            [titleView addSubview:titleLbl];
//            
//            UILabel *subtitleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, titleView.frame.size.width, 20)];
//            subtitleLbl.backgroundColor = [UIColor clearColor];
//            subtitleLbl.textColor = [UIColor colorWithRed:111.0/255 green:111.0/255 blue:111.0/255 alpha:1.0];
//            subtitleLbl.textAlignment = NSTextAlignmentCenter;
//            subtitleLbl.text = self.restaurantLabel.text;
//            subtitleLbl.font = [UIFont systemFontOfSize:13.0];
//            subtitleLbl.adjustsFontSizeToFitWidth = YES;
//            [titleView addSubview:subtitleLbl];
            
            self.restaurantLabel.text = [[arrRestaurant objectAtIndex:_currentSelectRestaurant] objectForKey:@"name"];
            if (searchingDish) {
                self.dishLabel.text = [[arrSearchDish objectAtIndex:_currentSelectedDish] objectForKey:@"name"];
                self.dishLabelCom.text = [[arrSearchDish objectAtIndex:_currentSelectedDish] objectForKey:@"name"];
            }
            else{
                self.dishLabel.text = [[arrDish objectAtIndex:_currentSelectedDish] objectForKey:@"name"];
                self.dishLabelCom.text = [[arrDish objectAtIndex:_currentSelectedDish] objectForKey:@"name"];
            }
            
            if (searchingRest) {
                self.restaurantLabelCom.text = [[arrSearchRest objectAtIndex:_currentSelectRestaurant] objectForKey:@"name"];
                self.restaurantLabel.text = [[arrSearchRest objectAtIndex:_currentSelectRestaurant] objectForKey:@"name"];
            }
            else{
                self.restaurantLabelCom.text = [[arrRestaurant objectAtIndex:_currentSelectRestaurant] objectForKey:@"name"];
                self.restaurantLabel.text = [[arrRestaurant objectAtIndex:_currentSelectRestaurant] objectForKey:@"name"];
            }
            
            
            
            [UIView animateWithDuration:0.35 animations:^{
                self.ratingView.frame = CGRectMake(0, self.ratingView.frame.origin.y, self.ratingView.frame.size.width, self.ratingView.frame.size.height);
                
                self.imvIcn1.alpha = 0.0;
                self.imvIcn2.alpha = 0.0;
                self.mapButton.alpha = 0.0;
                
//                self.restaurantLabel.alpha = 0.0;
//                self.dishLabel.alpha = 0.0;
                
                self.tblDish.frame = CGRectMake(-self.view.frame.size.width, 0, self.tblDish.frame.size.width, self.tblDish.frame.size.height);
                self.searchBarDish.frame = CGRectMake(-self.view.frame.size.width, self.searchBarDish.frame.origin.y, self.searchBarDish.frame.size.width, self.searchBarDish.frame.size.height);
                
            } completion:^(BOOL finished) {
                
            }];
        }
        else if (_currentStep == 3) {
            
            _finalStep = YES;
            
            
            
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/api/0/drafts/%@", urlReal, [_dataItem objectForKey:@"_id"]]]];
            
            __weak typeof(ASIFormDataRequest *) weakSelf = request;
            
            [request setCompletionBlock:^{
                NSString *theJSON = [weakSelf responseString];
                NSLog(@"requestUpdateDishDidFinish:%@", theJSON);
                
                SBJsonParser *parser = [[SBJsonParser alloc] init];
                
                NSString *status = [[parser objectWithString:theJSON] objectForKey:@"status"];
                NSDictionary *data = [[parser objectWithString:theJSON] objectForKey:@"data"];
                
                if ([status isEqualToString:@"ok"] && _finalStep) {
                    _currentStep++;
                    self.topBarItem.title = @"";
                    
                    //        [UIView animateWithDuration:0.35 animations:^{
                    //            self.resultView.frame = CGRectMake(0, self.resultView.frame.origin.y, self.resultView.frame.size.width, self.resultView.frame.size.height);
                    //
                    //        } completion:^(BOOL finished) {
                    //
                    //        }];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadDataAgainWhenUploaded" object:data userInfo:nil];
                    
                    
                    
                    @try {
                        [self.presentingViewController performSegueWithIdentifier:@"CustomUnwindSegue" sender:nil];
                    }
                    @catch (NSException *exception) {
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    }
                    @finally {
                        
                    }
                    
                    //        [self.presentingViewController performSegueWithIdentifier:@"CustomUnwindSegue" sender:nil];
                    
                }else if(_finalStep){
                    //        _currentStep++;
                    //        self.topBarItem.title = @"";
                    //        [self.resultButton setImage:[UIImage imageNamed:@"icon_upload_fail.png"] forState:UIControlStateNormal];
                    //
                    //        [UIView animateWithDuration:0.35 animations:^{
                    //            self.resultView.frame = CGRectMake(0, self.resultView.frame.origin.y, self.resultView.frame.size.width, self.resultView.frame.size.height);
                    //
                    //        } completion:^(BOOL finished) {
                    //            
                    //        }];
                    
                    
                }
            }];
            
            [request setFailedBlock:^{
                NSString *theJSON = [weakSelf responseString];
                NSLog(@"requestUpdateDishDidFail:%@", theJSON);
            }];
            
            
            [request setRequestMethod:@"PUT"];
            [request addRequestHeader:@"Content-Type" value:@"application/json"];
            
            SBJsonWriter *writerJSON = [[SBJsonWriter alloc] init];
            NSString *jsonString = [writerJSON stringWithObject:[NSMutableDictionary dictionaryWithObjectsAndKeys: _txtComment.text, @"comment", [NSNumber numberWithInt:(int)currentRating], @"rating", [NSNumber numberWithBool:YES], @"published", nil]];
            
            NSMutableData *data = [[NSMutableData alloc] initWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
            [request setPostBody:data];
            
            if (cookie) {
                [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
            }
            
            [request startAsynchronous];
        }
    }
    else if(sender == self.mapButton){
        self.topBarItem.titleView = nil;
        self.topBarItem.title = self.restaurantLabel.text;
        [UIView animateWithDuration:0.35 animations:^{
            self.mapView.frame = CGRectMake(0, self.mapView.frame.origin.y, self.mapView.frame.size.width, self.mapView.frame.size.height);
            
        } completion:^(BOOL finished) {
            
        }];
    }
    else if(sender == self.resultButton){
        [self.presentingViewController performSegueWithIdentifier:@"CustomUnwindSegue" sender:sender];
    }
    else if(sender == self.btnAddComment || sender == self.btnOpenEditComment){
        self.countCharCom.hidden = NO;
        self.countCharCom.text = [NSString stringWithFormat:@"%d", (int)(140 - self.txtComment.text.length)];
        
        UIBarButtonItem *itemRight = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneInputText)];
        [itemRight setTintColor:[UIColor whiteColor]];
        self.topBarItem.rightBarButtonItem = itemRight;
        
        if (isIOS7) {
            [itemRight setTintColor:[UIColor colorWithRed:120.0/255 green:120.0/255 blue:120.0/255 alpha:1.0]];
        }
        
        [UIView animateWithDuration:0.35 animations:^{
            self.contentView.frame = CGRectMake(-320, self.contentView.frame.origin.y, 320, self.contentView.frame.size.height);
            self.viewComment.frame = CGRectMake(0, self.viewComment.frame.origin.y, 320, self.viewComment.frame.size.height);
        } completion:^(BOOL finished) {
            [self.txtComment becomeFirstResponder];
        }];
    }
}

-(void)doneInputText{
    self.topBarItem.rightBarButtonItem = nil;
    
    [self.txtComment resignFirstResponder];
    self.countCharCom.hidden = YES;
    
    self.lblCom.text = @"";
    self.lblCom.hidden = YES;
    self.btnOpenEditComment.hidden = YES;
    self.btnAddComment.hidden = NO;
    
    if (self.txtComment.text.length > 0) {
        self.lblCom.text = self.txtComment.text;
        self.lblCom.hidden = NO;
        self.btnOpenEditComment.hidden = NO;
        self.btnAddComment.hidden = YES;
    }
    
    [UIView animateWithDuration:0.35 animations:^{
        self.contentView.frame = CGRectMake(0, self.contentView.frame.origin.y, 320, self.contentView.frame.size.height);
        self.viewComment.frame = CGRectMake(320, self.viewComment.frame.origin.y, 320, self.viewComment.frame.size.height);
    } completion:^(BOOL finished) {
        
    }];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/drafts/%@", urlReal, [_dataItem objectForKey:@"_id"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    __weak typeof(ASIFormDataRequest *) weakSelf = request;
    
    [request setCompletionBlock:^{
        NSString *theJSON = [weakSelf responseString];
        NSLog(@"requestUpdateDishDidFinish:%@", theJSON);
        
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        NSString *status = [[parser objectWithString:theJSON] objectForKey:@"status"];
        NSDictionary *data = [[parser objectWithString:theJSON] objectForKey:@"data"];
        
        if ([status isEqualToString:@"ok"] && _finalStep) {
            _currentStep++;
            self.topBarItem.title = @"";
            
            //        [UIView animateWithDuration:0.35 animations:^{
            //            self.resultView.frame = CGRectMake(0, self.resultView.frame.origin.y, self.resultView.frame.size.width, self.resultView.frame.size.height);
            //
            //        } completion:^(BOOL finished) {
            //
            //        }];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loadDataAgainWhenUploaded" object:data userInfo:nil];
            
            
            
            @try {
                [self.presentingViewController performSegueWithIdentifier:@"CustomUnwindSegue" sender:nil];
            }
            @catch (NSException *exception) {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
            @finally {
                
            }
            
            //        [self.presentingViewController performSegueWithIdentifier:@"CustomUnwindSegue" sender:nil];
            
        }else if(_finalStep){
            //        _currentStep++;
            //        self.topBarItem.title = @"";
            //        [self.resultButton setImage:[UIImage imageNamed:@"icon_upload_fail.png"] forState:UIControlStateNormal];
            //
            //        [UIView animateWithDuration:0.35 animations:^{
            //            self.resultView.frame = CGRectMake(0, self.resultView.frame.origin.y, self.resultView.frame.size.width, self.resultView.frame.size.height);
            //
            //        } completion:^(BOOL finished) {
            //
            //        }];
            
            
        }
    }];
    
    [request setFailedBlock:^{
        NSString *theJSON = [weakSelf responseString];
        NSLog(@"requestUpdateDishDidFail:%@", theJSON);
    }];
    [request setRequestMethod:@"PUT"];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    ;
    
    SBJsonWriter *writerJSON = [[SBJsonWriter alloc] init];
    NSString *jsonString = [writerJSON stringWithObject:[NSMutableDictionary dictionaryWithObjectsAndKeys: self.txtComment.text, @"comment", nil]];
    
    NSMutableData *data = [[NSMutableData alloc] initWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setPostBody:data];
    
    if (cookie) {
        [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
    }
    
    [request startAsynchronous];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (textView == self.txtComment) {
        if (self.txtComment.text.length <= 140) {
            if (text.length == 0) {
                self.countCharCom.text = [NSString stringWithFormat:@"%d", (int)(140 - (self.txtComment.text.length - 1))];
            }
            else{
                if (self.txtComment.text.length == 140) {
                    return NO;
                }
                self.countCharCom.text = [NSString stringWithFormat:@"%d", (int)(140 - (self.txtComment.text.length + 1))];
            }
        }
        else{
            if (text.length == 0) {
                return YES;
            }
            return NO;
        }
    }
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma  UITableViewDataSource implementation
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tblRestaurant){
        if (searchingRest) return arrSearchRest.count;
        return arrRestaurant.count;
    }
    else if (tableView == self.tblDish) {
        if (searchingDish) return arrSearchDish.count;
        return arrDish.count;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 30.0;
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    UIView *vCell = nil;
    UILabel *lblTitle;
    UILabel *lblDistance;
    
    UIImageView *imvAddDish;
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        
        vCell = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tblRestaurant.frame.size.width, 30)];
        vCell.backgroundColor = [UIColor clearColor];
        vCell.tag = 1;
        [cell.contentView addSubview:vCell];
        
        lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.tblRestaurant.frame.size.width - 60, 30)];
        lblTitle.backgroundColor = [UIColor clearColor];
        lblTitle.textColor = [UIColor colorWithRed:96.0/255 green:99.0/255 blue:102.0/255 alpha:1.0];
        lblTitle.font = [UIFont fontWithName:@"MyriadPro-Regular" size:16.0];
        lblTitle.tag = 2;
        lblTitle.lineBreakMode = NSLineBreakByTruncatingTail;
        lblTitle.numberOfLines = 1;
        [vCell addSubview:lblTitle];
        
        lblDistance = [[UILabel alloc] initWithFrame:CGRectMake(self.tblRestaurant.frame.size.width - 60, 0, 50, 30)];
        lblDistance.backgroundColor = [UIColor clearColor];
        lblDistance.textColor = [UIColor colorWithRed:96.0/255 green:99.0/255 blue:102.0/255 alpha:1.0];
        lblDistance.font = [UIFont fontWithName:@"MyriadPro-Regular" size:10.0];
        lblDistance.textAlignment = NSTextAlignmentRight;
        lblDistance.tag = 3;
        [vCell addSubview:lblDistance];
        
        imvAddDish = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 20, 20)];
        imvAddDish.hidden = YES;
        imvAddDish.image = [UIImage imageNamed:@"add.png"];
        imvAddDish.contentMode = UIViewContentModeScaleAspectFit;
        imvAddDish.tag = 4;
        [vCell addSubview:imvAddDish];
    }
    
    if (!vCell) {
        vCell = [cell.contentView viewWithTag:1];
        lblTitle = (UILabel *)[vCell viewWithTag:2];
        lblDistance = (UILabel *)[vCell viewWithTag:3];
        imvAddDish = (UIImageView *)[vCell viewWithTag:4];
    }
    
    imvAddDish.hidden = YES;
    
    if (tableView == self.tblRestaurant) {
        NSDictionary *itemData = nil;
        if (searchingRest && arrSearchRest.count > 0 && indexPath.row <= arrSearchRest.count-1) itemData = [arrSearchRest objectAtIndex:indexPath.row];
        else itemData = [arrRestaurant objectAtIndex:indexPath.row];
        
        if (![itemData isKindOfClass:[NSString class]] && itemData) {
            CLLocationCoordinate2D coord;
            coord.latitude   = [[[[itemData objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"] doubleValue];
            coord.longitude  = [[[[itemData objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"] doubleValue];
            
            __autoreleasing CLLocation *location = [[CLLocation alloc] initWithCoordinate:coord
                                                                                 altitude:0.0
                                                                       horizontalAccuracy:0
                                                                         verticalAccuracy:0
                                                                                timestamp:[NSDate date]];
            
            
            __weak LocationManager *locationManager = [LocationManager locationManager];
            __weak CLLocation		  *currentLocation = [locationManager currentLocation];
            
            CLLocationDistance distance = [currentLocation distanceFromLocation:location];
            
            lblTitle.text = [itemData objectForKey:@"name"];
            lblDistance.text = [NSString stringWithFormat:@"%0.1fm", distance];
            lblDistance.hidden = NO;
        }
        
        
        if (indexPath.row == _currentSelectRestaurant) {
            vCell.backgroundColor = [UIColor colorWithRed:69.0/255 green:185.0/255 blue:203.0/255 alpha:1.0];
            lblTitle.textColor = [UIColor whiteColor];
            lblDistance.textColor = [UIColor whiteColor];
        }
        else{
            vCell.backgroundColor = [UIColor clearColor];
            lblTitle.textColor = [UIColor colorWithRed:100.0/255 green:100.0/255 blue:100.0/255 alpha:1.0];
            lblDistance.textColor = [UIColor colorWithRed:100.0/255 green:100.0/255 blue:100.0/255 alpha:1.0];
        }
        
        lblTitle.hidden = NO;
        lblDistance.hidden = NO;
    }
    else if (tableView == self.tblDish) {
        NSDictionary *itemData = nil;
        if (searchingDish && arrSearchDish.count > 0 && indexPath.row <= arrSearchDish.count-1) itemData = [arrSearchDish objectAtIndex:indexPath.row];
        else itemData = [arrDish objectAtIndex:indexPath.row];
        
        if (![itemData isKindOfClass:[NSString class]]) {
            lblTitle.text = [itemData objectForKey:@"name"];
        }
        
        lblDistance.hidden = YES;
        lblTitle.hidden = NO;
        
        lblTitle.frame = CGRectMake(10, 0, self.tblRestaurant.frame.size.width - 20, 30);
        
        if (indexPath.row == _currentSelectedDish) {
            vCell.backgroundColor = [UIColor colorWithRed:69.0/255 green:185.0/255 blue:203.0/255 alpha:1.0];
            lblTitle.textColor = [UIColor whiteColor];
        }
        else{
            vCell.backgroundColor = [UIColor clearColor];
            lblTitle.textColor = [UIColor colorWithRed:100.0/255 green:100.0/255 blue:100.0/255 alpha:1.0];
        }
    }
    
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tblRestaurant) {
//        NSInteger tmp = _currentSelectRestaurant;
        _currentSelectRestaurant = indexPath.row;
        [self.tblRestaurant reloadData];
//        [self.tblRestaurant reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:tmp inSection:0], [NSIndexPath indexPathForRow:_currentSelectRestaurant inSection:0], nil] withRowAnimation:UITableViewRowAnimationNone];
 
        if (searchingRest) {
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/api/0/drafts/%@", urlReal, [_dataItem objectForKey:@"_id"]]]];
            __weak typeof(ASIFormDataRequest *) weakSelf = request;
            
            [request setCompletionBlock:^{
                NSString *theJSON = [weakSelf responseString];
                NSLog(@"requestUpdateDishDidFinish:%@", theJSON);
                
                SBJsonParser *parser = [[SBJsonParser alloc] init];
                
                NSString *status = [[parser objectWithString:theJSON] objectForKey:@"status"];
                NSDictionary *data = [[parser objectWithString:theJSON] objectForKey:@"data"];
                
                if ([status isEqualToString:@"ok"] && _finalStep) {
                    _currentStep++;
                    self.topBarItem.title = @"";
                    
                    //        [UIView animateWithDuration:0.35 animations:^{
                    //            self.resultView.frame = CGRectMake(0, self.resultView.frame.origin.y, self.resultView.frame.size.width, self.resultView.frame.size.height);
                    //
                    //        } completion:^(BOOL finished) {
                    //
                    //        }];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadDataAgainWhenUploaded" object:data userInfo:nil];
                    
                    
                    
                    @try {
                        [self.presentingViewController performSegueWithIdentifier:@"CustomUnwindSegue" sender:nil];
                    }
                    @catch (NSException *exception) {
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    }
                    @finally {
                        
                    }
                    
                    //        [self.presentingViewController performSegueWithIdentifier:@"CustomUnwindSegue" sender:nil];
                    
                }else if(_finalStep){
                    //        _currentStep++;
                    //        self.topBarItem.title = @"";
                    //        [self.resultButton setImage:[UIImage imageNamed:@"icon_upload_fail.png"] forState:UIControlStateNormal];
                    //
                    //        [UIView animateWithDuration:0.35 animations:^{
                    //            self.resultView.frame = CGRectMake(0, self.resultView.frame.origin.y, self.resultView.frame.size.width, self.resultView.frame.size.height);
                    //
                    //        } completion:^(BOOL finished) {
                    //
                    //        }];
                    
                    
                }
            }];
            
            [request setFailedBlock:^{
                NSString *theJSON = [weakSelf responseString];
                NSLog(@"requestUpdateDishDidFail:%@", theJSON);
            }];
            [request setRequestMethod:@"PUT"];
            [request addRequestHeader:@"Content-Type" value:@"application/json"];
            
            SBJsonWriter *writerJSON = [[SBJsonWriter alloc] init];
            NSString *jsonString = [writerJSON stringWithObject:[NSMutableDictionary dictionaryWithObjectsAndKeys: [[arrSearchRest objectAtIndex:indexPath.row] objectForKey:@"_id"], @"restaurant", nil]];
            
            NSMutableData *data = [[NSMutableData alloc] initWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
            [request setPostBody:data];
            
            if (cookie) {
                [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
            }
            
            [request startAsynchronous];
        }
        else{
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/api/0/drafts/%@", urlReal, [_dataItem objectForKey:@"_id"]]]];
            __weak typeof(ASIFormDataRequest *) weakSelf = request;
            
            [request setCompletionBlock:^{
                NSString *theJSON = [weakSelf responseString];
                NSLog(@"requestUpdateDishDidFinish:%@", theJSON);
                
                SBJsonParser *parser = [[SBJsonParser alloc] init];
                
                NSString *status = [[parser objectWithString:theJSON] objectForKey:@"status"];
                NSDictionary *data = [[parser objectWithString:theJSON] objectForKey:@"data"];
                
                if ([status isEqualToString:@"ok"] && _finalStep) {
                    _currentStep++;
                    self.topBarItem.title = @"";
                    
                    //        [UIView animateWithDuration:0.35 animations:^{
                    //            self.resultView.frame = CGRectMake(0, self.resultView.frame.origin.y, self.resultView.frame.size.width, self.resultView.frame.size.height);
                    //
                    //        } completion:^(BOOL finished) {
                    //
                    //        }];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadDataAgainWhenUploaded" object:data userInfo:nil];
                    
                    
                    
                    @try {
                        [self.presentingViewController performSegueWithIdentifier:@"CustomUnwindSegue" sender:nil];
                    }
                    @catch (NSException *exception) {
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    }
                    @finally {
                        
                    }
                    
                    //        [self.presentingViewController performSegueWithIdentifier:@"CustomUnwindSegue" sender:nil];
                    
                }else if(_finalStep){
                    //        _currentStep++;
                    //        self.topBarItem.title = @"";
                    //        [self.resultButton setImage:[UIImage imageNamed:@"icon_upload_fail.png"] forState:UIControlStateNormal];
                    //
                    //        [UIView animateWithDuration:0.35 animations:^{
                    //            self.resultView.frame = CGRectMake(0, self.resultView.frame.origin.y, self.resultView.frame.size.width, self.resultView.frame.size.height);
                    //
                    //        } completion:^(BOOL finished) {
                    //
                    //        }];
                    
                    
                }
            }];
            
            [request setFailedBlock:^{
                NSString *theJSON = [weakSelf responseString];
                NSLog(@"requestUpdateDishDidFail:%@", theJSON);
            }];
            [request setRequestMethod:@"PUT"];
            [request addRequestHeader:@"Content-Type" value:@"application/json"];
            
            SBJsonWriter *writerJSON = [[SBJsonWriter alloc] init];
            NSString *jsonString = [writerJSON stringWithObject:[NSMutableDictionary dictionaryWithObjectsAndKeys: [[arrRestaurant objectAtIndex:indexPath.row] objectForKey:@"_id"], @"restaurant", nil]];
            
            NSMutableData *data = [[NSMutableData alloc] initWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
            [request setPostBody:data];
            
            if (cookie) {
                [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
            }
            
            [request startAsynchronous];
        }
        
        
        [self keyPress:self.okButton];
    }
    else if (tableView == self.tblDish) {
        if (searchingDish) {
            if (arrSearchDish.count == 1 && [[[arrSearchDish objectAtIndex:0] objectForKey:@"name"] rangeOfString:@"No match, press to add"].location!=NSNotFound) {
 
                _currentSelectedDish = indexPath.row;
                [self.tblDish reloadData];
                
                [MBProgressHUD showHUDAddedTo:[kApplicationDelegate window] animated:YES];
                
                ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/dishes", urlReal] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                
                __weak typeof(ASIFormDataRequest *) weakSelf = request;
                
                [request setCompletionBlock:^{
                    NSString *theJSON = [weakSelf responseString];
                    NSLog(@"requestAddNewDishDidFinish:%@", theJSON);
                    
                    SBJsonParser *parser = [[SBJsonParser alloc] init];
                    NSString *status = [[parser objectWithString:theJSON] objectForKey:@"status"];
                    
                    if ([status isEqualToString:@"ok"]) {
                        NSMutableDictionary *itemDish = [[NSMutableDictionary alloc] initWithDictionary:[[parser objectWithString:theJSON] objectForKey:@"data"]];
                        
                        [arrDish insertObject:itemDish atIndex:0];
                        self.searchBarDish.text = @"";
                        _currentSelectedDish = -1;
                        [self doneSearching_Clicked];
                        [_tblDish reloadData];
                    }
                    
                    [MBProgressHUD hideAllHUDsForView:[kApplicationDelegate window] animated:YES];
                }];
                
                [request setFailedBlock:^{
                    NSString *theJSON = [weakSelf responseString];
                    NSLog(@"requestAddNewDishDidFail:%@", theJSON);
                    
                    [MBProgressHUD hideAllHUDsForView:[kApplicationDelegate window] animated:YES];
                }];
                
                
                [request setRequestMethod:@"POST"];
                [request addRequestHeader:@"Content-Type" value:@"application/json"];
                
                SBJsonWriter *writerJSON = [[SBJsonWriter alloc] init];
                NSString *jsonString = [writerJSON stringWithObject:[NSMutableDictionary dictionaryWithObjectsAndKeys: self.searchBarDish.text, @"name", nil]];
                
                NSMutableData *data = [[NSMutableData alloc] initWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
                [request setPostBody:data];
                
                if (cookie) {
                    [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
                }
                
                [request startAsynchronous];
            }
            else{
//                NSInteger tmp = _currentSelectedDish;
                _currentSelectedDish = indexPath.row;
                [self.tblDish reloadData];
                
                [self keyPress:self.okButton];
//                [self.tblDish reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:tmp inSection:0], [NSIndexPath indexPathForRow:_currentSelectedDish inSection:0], nil] withRowAnimation:UITableViewRowAnimationNone];
                
                ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/drafts/%@", urlReal, [_dataItem objectForKey:@"_id"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                __weak typeof(ASIFormDataRequest *) weakSelf = request;
                
                [request setCompletionBlock:^{
                    NSString *theJSON = [weakSelf responseString];
                    NSLog(@"requestUpdateDishDidFinish:%@", theJSON);
                    
                    SBJsonParser *parser = [[SBJsonParser alloc] init];
                    
                    NSString *status = [[parser objectWithString:theJSON] objectForKey:@"status"];
                    NSDictionary *data = [[parser objectWithString:theJSON] objectForKey:@"data"];
                    
                    if ([status isEqualToString:@"ok"] && _finalStep) {
                        _currentStep++;
                        self.topBarItem.title = @"";
                        
                        //        [UIView animateWithDuration:0.35 animations:^{
                        //            self.resultView.frame = CGRectMake(0, self.resultView.frame.origin.y, self.resultView.frame.size.width, self.resultView.frame.size.height);
                        //
                        //        } completion:^(BOOL finished) {
                        //
                        //        }];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"loadDataAgainWhenUploaded" object:data userInfo:nil];
                        
                        
                        
                        @try {
                            [self.presentingViewController performSegueWithIdentifier:@"CustomUnwindSegue" sender:nil];
                        }
                        @catch (NSException *exception) {
                            [self.navigationController popToRootViewControllerAnimated:YES];
                        }
                        @finally {
                            
                        }
                        
                        //        [self.presentingViewController performSegueWithIdentifier:@"CustomUnwindSegue" sender:nil];
                        
                    }else if(_finalStep){
                        //        _currentStep++;
                        //        self.topBarItem.title = @"";
                        //        [self.resultButton setImage:[UIImage imageNamed:@"icon_upload_fail.png"] forState:UIControlStateNormal];
                        //
                        //        [UIView animateWithDuration:0.35 animations:^{
                        //            self.resultView.frame = CGRectMake(0, self.resultView.frame.origin.y, self.resultView.frame.size.width, self.resultView.frame.size.height);
                        //
                        //        } completion:^(BOOL finished) {
                        //
                        //        }];
                        
                        
                    }
                }];
                
                [request setFailedBlock:^{
                    NSString *theJSON = [weakSelf responseString];
                    NSLog(@"requestUpdateDishDidFail:%@", theJSON);
                }];
                [request setRequestMethod:@"PUT"];
                [request addRequestHeader:@"Content-Type" value:@"application/json"];
                
                SBJsonWriter *writerJSON = [[SBJsonWriter alloc] init];
                NSString *jsonString = [writerJSON stringWithObject:[NSMutableDictionary dictionaryWithObjectsAndKeys: [[arrSearchDish objectAtIndex:indexPath.row] objectForKey:@"_id"], @"dish", nil]];
                
                NSMutableData *data = [[NSMutableData alloc] initWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
                [request setPostBody:data];
                
                if (cookie) {
                    [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
                }
                
                [request startAsynchronous];
            }
        }
        else{
//            NSInteger tmp = _currentSelectedDish;
            _currentSelectedDish = indexPath.row;
            [self.tblDish reloadData];
            
            [self keyPress:self.okButton];
            
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/drafts/%@", urlReal, [_dataItem objectForKey:@"_id"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            __weak typeof(ASIFormDataRequest *) weakSelf = request;
            
            [request setCompletionBlock:^{
                NSString *theJSON = [weakSelf responseString];
                NSLog(@"requestUpdateDishDidFinish:%@", theJSON);
                
                SBJsonParser *parser = [[SBJsonParser alloc] init];
                
                NSString *status = [[parser objectWithString:theJSON] objectForKey:@"status"];
                NSDictionary *data = [[parser objectWithString:theJSON] objectForKey:@"data"];
                
                if ([status isEqualToString:@"ok"] && _finalStep) {
                    _currentStep++;
                    self.topBarItem.title = @"";
                    
                    //        [UIView animateWithDuration:0.35 animations:^{
                    //            self.resultView.frame = CGRectMake(0, self.resultView.frame.origin.y, self.resultView.frame.size.width, self.resultView.frame.size.height);
                    //
                    //        } completion:^(BOOL finished) {
                    //
                    //        }];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadDataAgainWhenUploaded" object:data userInfo:nil];
                    
                    
                    
                    @try {
                        [self.presentingViewController performSegueWithIdentifier:@"CustomUnwindSegue" sender:nil];
                    }
                    @catch (NSException *exception) {
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    }
                    @finally {
                        
                    }
                    
                    //        [self.presentingViewController performSegueWithIdentifier:@"CustomUnwindSegue" sender:nil];
                    
                }else if(_finalStep){
                    //        _currentStep++;
                    //        self.topBarItem.title = @"";
                    //        [self.resultButton setImage:[UIImage imageNamed:@"icon_upload_fail.png"] forState:UIControlStateNormal];
                    //
                    //        [UIView animateWithDuration:0.35 animations:^{
                    //            self.resultView.frame = CGRectMake(0, self.resultView.frame.origin.y, self.resultView.frame.size.width, self.resultView.frame.size.height);
                    //
                    //        } completion:^(BOOL finished) {
                    //
                    //        }];
                    
                    
                }
            }];
            
            [request setFailedBlock:^{
                NSString *theJSON = [weakSelf responseString];
                NSLog(@"requestUpdateDishDidFail:%@", theJSON);
            }];
            [request setRequestMethod:@"PUT"];
            [request addRequestHeader:@"Content-Type" value:@"application/json"];
            
            SBJsonWriter *writerJSON = [[SBJsonWriter alloc] init];
            NSString *jsonString = [writerJSON stringWithObject:[NSMutableDictionary dictionaryWithObjectsAndKeys: [[arrDish objectAtIndex:indexPath.row] objectForKey:@"_id"], @"dish", nil]];
            
            NSMutableData *data = [[NSMutableData alloc] initWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
            [request setPostBody:data];
            
            if (cookie) {
                [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
            }
            
            [request startAsynchronous];
            
//            [self.tblDish reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:tmp inSection:0], [NSIndexPath indexPathForRow:_currentSelectedDish inSection:0], nil] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    return YES;
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    if(searchingRest || searchingDish)
		return;
    
    if (_currentStep == 1) {
        searchingRest = YES;
        self.tblRestaurant.scrollEnabled = NO;
    }
    else if (_currentStep == 2) {
        searchingDish = YES;
        self.tblDish.scrollEnabled = NO;
    }
}
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    return YES;
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar{
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    if (_currentStep == 1) {
        [self.searchBar resignFirstResponder];
    }
    else if (_currentStep == 2) {
        [self.searchBarDish resignFirstResponder];
    }
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    return YES;
}

-(void)_sendRequestGetAuto{
    [timerInput invalidate];
    timerInput = nil;
    
    searchingDish = YES;
    self.tblDish.scrollEnabled = YES;
    
    SAFE_RELEASE_ARRAY(arrSearchDish);
    
    _currentPageIndexAutoComplete = 1;
    
    ASIHTTPRequest *requestDish = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/dishes/autocomplete?[{\"$input\":\"%@\"},{\"limit\":500,\"page\":%d}]", urlReal, self.searchBarDish.text, (int)_currentPageIndexAutoComplete] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    __weak typeof(ASIHTTPRequest *) weakSelf = requestDish;
    
    [requestDish setCompletionBlock:^{
        NSString *theJSON = [weakSelf responseString];
        NSLog(@"requestAutoCompleteDidFinish:%@", theJSON);
        
        self.tblDish.userInteractionEnabled = YES;
        
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        _isLoadingMore = NO;
        
        if (_currentPageIndexAutoComplete == 1) {
            SAFE_RELEASE_ARRAY(arrSearchDish);
        }
        if (!arrSearchDish) {
            arrSearchDish = [[NSMutableArray alloc] initWithArray:[[parser objectWithString:theJSON] objectForKey:@"data"]];
        }
        else{
            NSMutableArray *tmp = [[parser objectWithString:theJSON] objectForKey:@"data"];
            if (tmp.count > 0) {
                [arrSearchDish addObjectsFromArray:tmp];
            }
        }
        
        if (arrSearchDish.count == 0) {
            [arrSearchDish addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"No match, press to add", @"name", nil]];
        }
        
        [_tblDish reloadData];
    }];
    
    [requestDish setFailedBlock:^{
        NSString *theJSON = [weakSelf responseString];
        NSLog(@"requestAutoCompleteDidFail:%@", theJSON);
        
        self.tblDish.userInteractionEnabled = YES;
        _isLoadingMore = NO;
        
        SAFE_RELEASE_ARRAY(arrSearchDish);
        arrSearchDish = [[NSMutableArray alloc] init];
        
        [_tblDish reloadData];
    }];
    
    [requestDish setRequestMethod:@"GET"];
    [requestDish addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    
    [requestDish setUseCookiePersistence:NO];
    [requestDish setUseSessionPersistence:NO];
    if (cookie) {
        [requestDish setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
    }
    
    [requestDish addRequestHeader:@"Vary" value:@"Accept-Encoding"];
    [requestDish addRequestHeader:@"X-Powered-By" value:@"Express"];
    [requestDish startAsynchronous];
}

-(void)_sendRequestGetRest{
    [timerInput invalidate];
    timerInput = nil;
    
    searchingRest = YES;
    self.tblRestaurant.scrollEnabled = YES;
    
    SAFE_RELEASE_ARRAY(arrSearchRest);
    
    _currentPageIndexSearchRest = 1;
    
    ASIHTTPRequest *requestRest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/restaurants?[{\"$input\":\"%@\", \"lat\":%f,\"lng\":%f}, {\"page\":%d}]", urlReal, self.searchBar.text, [LocationManager locationManager].currentLocation.coordinate.latitude, [LocationManager locationManager].currentLocation.coordinate.longitude, (int)_currentPageIndexSearchRest] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    __weak typeof(ASIHTTPRequest *) weakSelf = requestRest;
    
    [requestRest setCompletionBlock:^{
        NSString *theJSON = [weakSelf responseString];
        NSLog(@"requestRestSearchDidFinish:%@", theJSON);
        
        _isLoadingMore = NO;
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        self.tblRestaurant.userInteractionEnabled = YES;
        
        if (arrSearchRest && arrSearchRest.count > 0) {
            [arrSearchRest addObjectsFromArray:[[parser objectWithString:theJSON] objectForKey:@"data"]];
            if ([[[parser objectWithString:theJSON] objectForKey:@"data"] count] > 0) {
                _currentPageIndexSearchRest++;
            }
        }
        else{
            SAFE_RELEASE_ARRAY(arrSearchRest);
            arrSearchRest = [[NSMutableArray alloc] initWithArray:[[parser objectWithString:theJSON] objectForKey:@"data"]];
        }
        
        
        [_tblRestaurant reloadData];
    }];
    
    [requestRest setFailedBlock:^{
        NSString *theJSON = [weakSelf responseString];
        NSLog(@"requestRestSearchDidFail:%@", theJSON);
        _isLoadingMore = NO;
    }];
    
    [requestRest setRequestMethod:@"GET"];
    [requestRest addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    
    [requestRest setUseCookiePersistence:NO];
    [requestRest setUseSessionPersistence:NO];
    if (cookie) {
        [requestRest setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
    }
    
    [requestRest addRequestHeader:@"Vary" value:@"Accept-Encoding"];
    [requestRest addRequestHeader:@"X-Powered-By" value:@"Express"];
    [requestRest startAsynchronous];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (_currentStep == 1) {
        SAFE_RELEASE_ARRAY(arrSearchRest);
        arrSearchRest = [[NSMutableArray alloc] init];
        if([searchText length] > 0) {
            
            
//            [self searchTableView];
            
            self.tblRestaurant.userInteractionEnabled = NO;
            
            [timerInput invalidate];
            timerInput = nil;
            
            timerInput = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(_sendRequestGetRest) userInfo:nil repeats:NO];
        }
        else {
            searchingRest = NO;
            [self.tblRestaurant reloadData];
            
//            self.tblRestaurant.scrollEnabled = NO;
        }
    }
    else if (_currentStep == 2) {
        SAFE_RELEASE_ARRAY(arrSearchDish);
        arrSearchDish = [[NSMutableArray alloc] init];
        if([searchText length] > 0) {
            
            self.tblDish.userInteractionEnabled = NO;
            
            [timerInput invalidate];
            timerInput = nil;
            
            timerInput = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(_sendRequestGetAuto) userInfo:nil repeats:NO];
            
            
            
//            [self searchTableView];
        }
        else {
            searchingDish = NO;
            [self.tblDish reloadData];
//            self.tblDish.scrollEnabled = NO;
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == self.tblDish && searchingDish) {
        CGFloat scrollPosition = scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y;
        if (scrollPosition < 40.0 && !_isLoadingMore) {
            if (arrSearchDish.count == 1 && [[[arrSearchDish objectAtIndex:0] objectForKey:@"name"] isEqualToString:@"No match, press to add"]) {
                return;
            }
            _currentPageIndexAutoComplete++;
            _isLoadingMore = YES;
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/dishes/autocomplete?[{\"$input\":\"%@\"},{\"limit\":500,\"page\":%d}]", urlReal, self.searchBar.text, (int)_currentPageIndexAutoComplete] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            
            __weak typeof(ASIFormDataRequest *) weakSelf = request;
            
            [request setCompletionBlock:^{
                NSString *theJSON = [weakSelf responseString];
                NSLog(@"requestAutoCompleteDidFinish:%@", theJSON);
                
                self.tblDish.userInteractionEnabled = YES;
                
                SBJsonParser *parser = [[SBJsonParser alloc] init];
                
                _isLoadingMore = NO;
                
                if (_currentPageIndexAutoComplete == 1) {
                    SAFE_RELEASE_ARRAY(arrSearchDish);
                }
                if (!arrSearchDish) {
                    arrSearchDish = [[NSMutableArray alloc] initWithArray:[[parser objectWithString:theJSON] objectForKey:@"data"]];
                }
                else{
                    NSMutableArray *tmp = [[parser objectWithString:theJSON] objectForKey:@"data"];
                    if (tmp.count > 0) {
                        [arrSearchDish addObjectsFromArray:tmp];
                    }
                }
                
                if (arrSearchDish.count == 0) {
                    [arrSearchDish addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"No match, press to add", @"name", nil]];
                }
                
                [_tblDish reloadData];
            }];
            
            [request setFailedBlock:^{
                NSString *theJSON = [weakSelf responseString];
                NSLog(@"requestAutoCompleteDidFail:%@", theJSON);
                
                self.tblDish.userInteractionEnabled = YES;
                _isLoadingMore = NO;
                
                SAFE_RELEASE_ARRAY(arrSearchDish);
                arrSearchDish = [[NSMutableArray alloc] init];
                
                [_tblDish reloadData];
            }];
            
            
            [request setRequestMethod:@"GET"];
            [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
            
            [request setUseCookiePersistence:NO];
            [request setUseSessionPersistence:NO];
            if (cookie) {
                [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
            }
            
            [request addRequestHeader:@"Vary" value:@"Accept-Encoding"];
            [request addRequestHeader:@"X-Powered-By" value:@"Express"];
            [request startAsynchronous];
        }
    }
    else if (scrollView == self.tblDish && !searchingDish) {
        CGFloat scrollPosition = scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y;
        if (scrollPosition < 40.0 && !_isLoadingMore) {
            _currentPageIndexAutoComplete++;
            _isLoadingMore = YES;
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/dishes/autocomplete?[{\"$input\":\"\"},{\"limit\":500,\"page\":%d}]", urlReal, (int)_currentPageIndexAutoComplete] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            
            __weak typeof(ASIFormDataRequest *) weakSelf = request;
            
            [request setCompletionBlock:^{
                NSString *theJSON = [weakSelf responseString];
                NSLog(@"requestDishDidFinish:%@", theJSON);
                
                _isLoadingMore = NO;
                
                SBJsonParser *parser = [[SBJsonParser alloc] init];
                
                if (!arrDish) {
                    arrDish = [[NSMutableArray alloc] initWithArray:[[parser objectWithString:theJSON] objectForKey:@"data"]];
                }
                else{
                    NSMutableArray *tmp = [[parser objectWithString:theJSON] objectForKey:@"data"];
                    if (tmp.count > 0) {
                        [arrDish addObjectsFromArray:tmp];
                    }
                }
                
                
                [_tblDish reloadData];
            }];
            
            [request setFailedBlock:^{
                NSString *theJSON = [weakSelf responseString];
                NSLog(@"requestDishDidFail:%@", theJSON);
                _isLoadingMore = NO;
            }];
            
            
            [request setRequestMethod:@"GET"];
            [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
            
            [request setUseCookiePersistence:NO];
            [request setUseSessionPersistence:NO];
            if (cookie) {
                [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
            }
            
            [request addRequestHeader:@"Vary" value:@"Accept-Encoding"];
            [request addRequestHeader:@"X-Powered-By" value:@"Express"];
            [request startAsynchronous];
        }
    }
    else if (scrollView == self.tblRestaurant && searchingRest) {
        CGFloat scrollPosition = scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y;
        if (scrollPosition < 40.0 && !_isLoadingMore) {
            _isLoadingMore = YES;
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/restaurants?[{\"$input\":\"%@\", \"lat\":%f,\"lng\":%f},{\"page\":%d}]", urlReal, self.searchBar.text, [LocationManager locationManager].currentLocation.coordinate.latitude, [LocationManager locationManager].currentLocation.coordinate.longitude, (int)_currentPageIndexSearchRest + 1] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            
            __weak typeof(ASIHTTPRequest *) weakSelf = request;
            
            [request setCompletionBlock:^{
                NSString *theJSON = [weakSelf responseString];
                NSLog(@"requestRestSearchDidFinish:%@", theJSON);
                
                _isLoadingMore = NO;
                SBJsonParser *parser = [[SBJsonParser alloc] init];
                
                self.tblRestaurant.userInteractionEnabled = YES;
                
                if (arrSearchRest && arrSearchRest.count > 0) {
                    [arrSearchRest addObjectsFromArray:[[parser objectWithString:theJSON] objectForKey:@"data"]];
                    if ([[[parser objectWithString:theJSON] objectForKey:@"data"] count] > 0) {
                        _currentPageIndexSearchRest++;
                    }
                }
                else{
                    SAFE_RELEASE_ARRAY(arrSearchRest);
                    arrSearchRest = [[NSMutableArray alloc] initWithArray:[[parser objectWithString:theJSON] objectForKey:@"data"]];
                }
                
                
                [_tblRestaurant reloadData];
            }];
            
            [request setFailedBlock:^{
                NSString *theJSON = [weakSelf responseString];
                NSLog(@"requestRestSearchDidFail:%@", theJSON);
                _isLoadingMore = NO;
            }];
            
//            [request setDidFinishSelector:@selector(requestRestSearchDidFinish:)];
//            [request setDidFailSelector:@selector(requestRestSearchDidFail:)];
//            request.delegate = self;
            
            [request setRequestMethod:@"GET"];
            [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
            
            [request setUseCookiePersistence:NO];
            [request setUseSessionPersistence:NO];
            if (cookie) {
                [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
            }
            
            [request addRequestHeader:@"Vary" value:@"Accept-Encoding"];
            [request addRequestHeader:@"X-Powered-By" value:@"Express"];
            [request startAsynchronous];
        }
    }
    else if (scrollView == self.tblRestaurant && !searchingDish) {
        CGFloat scrollPosition = scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y;
        if (scrollPosition < 40.0 && !_isLoadingMore) {
            _isLoadingMore = YES;
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/restaurants?[{\"$input\":\"\", \"lat\":%f,\"lng\":%f},{\"page\":%d}]", urlReal, [LocationManager locationManager].currentLocation.coordinate.latitude, [LocationManager locationManager].currentLocation.coordinate.longitude, (int)_currentPageIndexRest + 1] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            
            __weak typeof(ASIHTTPRequest *) weakSelf = request;
            
            [request setCompletionBlock:^{
                NSString *theJSON = [weakSelf responseString];
                NSLog(@"requestRestDidFinish:%@", theJSON);
                
                SBJsonParser *parser = [[SBJsonParser alloc] init];
                
                if (arrRestaurant && arrRestaurant.count > 0) {
                    [arrRestaurant addObjectsFromArray:[[parser objectWithString:theJSON] objectForKey:@"data"]];
                    if ([[[parser objectWithString:theJSON] objectForKey:@"data"] count] > 0) {
                        _currentPageIndexRest++;
                    }
                }
                else{
                    SAFE_RELEASE_ARRAY(arrRestaurant);
                    arrRestaurant = [[NSMutableArray alloc] initWithArray:[[parser objectWithString:theJSON] objectForKey:@"data"]];
                    
                    _currentPageIndexAutoComplete = 1;
                    
                    
                    ASIFormDataRequest *requestD = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/dishes/autocomplete?[{\"$input\":\"\"},{\"limit\":500,\"page\":%d}]", urlReal, (int)_currentPageIndexAutoComplete] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                    
                    __weak typeof(ASIFormDataRequest *) weakSelf = requestD;
                    
                    [requestD setCompletionBlock:^{
                        NSString *theJSON = [weakSelf responseString];
                        NSLog(@"requestDishDidFinish:%@", theJSON);
                        
                        _isLoadingMore = NO;
                        
                        SBJsonParser *parser = [[SBJsonParser alloc] init];
                        
                        if (!arrDish) {
                            arrDish = [[NSMutableArray alloc] initWithArray:[[parser objectWithString:theJSON] objectForKey:@"data"]];
                        }
                        else{
                            NSMutableArray *tmp = [[parser objectWithString:theJSON] objectForKey:@"data"];
                            if (tmp.count > 0) {
                                [arrDish addObjectsFromArray:tmp];
                            }
                        }
                        
                        
                        [_tblDish reloadData];
                    }];
                    
                    [requestD setFailedBlock:^{
                        NSString *theJSON = [weakSelf responseString];
                        NSLog(@"requestDishDidFail:%@", theJSON);
                        _isLoadingMore = NO;
                    }];
                    
                    [requestD setRequestMethod:@"GET"];
                    [requestD addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
                    
                    [requestD setUseCookiePersistence:NO];
                    [requestD setUseSessionPersistence:NO];
                    if (cookie) {
                        [requestD setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
                    }
                    
                    [requestD addRequestHeader:@"Vary" value:@"Accept-Encoding"];
                    [requestD addRequestHeader:@"X-Powered-By" value:@"Express"];
                    [requestD startAsynchronous];
                }
                
                [_tblRestaurant reloadData];
                _isLoadingMore = NO;
            }];
            
            [request setFailedBlock:^{
                NSString *theJSON = [weakSelf responseString];
                NSLog(@"requestRestDidFail:%@", theJSON);
            }];
            
//            [request setDidFinishSelector:@selector(requestRestDidFinish:)];
//            [request setDidFailSelector:@selector(requestRestDidFail:)];
//            request.delegate = self;
            
            [request setRequestMethod:@"GET"];
            [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
            
            [request setUseCookiePersistence:NO];
            [request setUseSessionPersistence:NO];
            if (cookie) {
                [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
            }
            
            [request addRequestHeader:@"Vary" value:@"Accept-Encoding"];
            [request addRequestHeader:@"X-Powered-By" value:@"Express"];
            [request startAsynchronous];
        }
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if (_currentStep == 1) {
        self.searchBar.text = @"";
    }
	else if (_currentStep == 2) {
        self.searchBarDish.text = @"";
    }
    
    [self doneSearching_Clicked];
    
    return NO;
}

-(void)doneSearching_Clicked{
    if (_currentStep == 1) {
        searchingRest = NO;
        
        if (_currentSelectRestaurant == -1) {
            _currentSelectRestaurant = _remCurrentSelectRestaurant;
        }
        
        self.tblRestaurant.scrollEnabled = YES;
        [self.tblRestaurant reloadData];
        [self.tblRestaurant setContentOffset:CGPointMake(0, 0) animated:NO];
    }
    else if (_currentStep == 2) {
        searchingDish = NO;
        
        if (_currentSelectedDish == -1) {
            _currentSelectedDish = _remCurrentSelectedDish;
        }
        
        self.tblDish.scrollEnabled = YES;
        [self.tblDish reloadData];
        [self.tblDish setContentOffset:CGPointMake(0, 0) animated:NO];
    }
}

-(void)searchTableView{
    if (_currentStep == 1) {
        searchingRest = YES;
        
        NSString *searchText = self.searchBar.text;
        if ([searchText isEqualToString:@""]) {
            searchingRest = YES;
            
            [self performSelector:@selector(doneSearching_Clicked) withObject:nil afterDelay: 0.1];
            return;
        }
        
        if (_currentSelectRestaurant != -1) {
            _remCurrentSelectRestaurant = _currentSelectRestaurant;
        }
        
        _currentSelectRestaurant = -1;
        
        SAFE_RELEASE_ARRAY(arrSearchRest);
        arrSearchRest = [[NSMutableArray alloc] initWithArray:arrRestaurant];
        
        if (![searchText isEqualToString:@""] && searchText!=nil) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
            [arrSearchRest filterUsingPredicate:predicate];
        }
        
        if (arrSearchRest.count > 0) {
        }
        
        [self.tblRestaurant reloadData];
    }
    else if (_currentStep == 2) {
        searchingDish = YES;
        
        NSString *searchText = self.searchBarDish.text;
        if ([searchText isEqualToString:@""]) {
            searchingDish = YES;
            
            [self performSelector:@selector(doneSearching_Clicked) withObject:nil afterDelay: 0.1];
            return;
        }
        
        if (_currentSelectedDish != -1) {
            _remCurrentSelectedDish = _currentSelectedDish;
        }
        
        _currentSelectedDish = -1;
        
        SAFE_RELEASE_ARRAY(arrSearchDish);
        arrSearchDish = [[NSMutableArray alloc] initWithArray:arrDish];
        
        
        
        if (![searchText isEqualToString:@""] && searchText!=nil) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
            [arrSearchDish filterUsingPredicate:predicate];
        }
        
        if (arrSearchDish.count > 0) {
            
        }
        else{
            [arrSearchDish addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"No match, press to add", @"name", nil]];
        }
        
        
        [self.tblDish reloadData];
    }
}

@end
