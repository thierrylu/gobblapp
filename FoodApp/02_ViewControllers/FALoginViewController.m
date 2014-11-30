//
//  FALoginViewController.m
//  FoodApp
//
//  Created by CHINH LE on 6/26/14.
//  Copyright (c) 2014 chinhlt. All rights reserved.
//

#import "FALoginViewController.h"
#import "FAHomeViewController.h"

@interface FALoginViewController ()

@end

@implementation FALoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
//    return;
    
    _isGoToHome = NO;
    
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"tempLogout"] boolValue]) {
        
//        [FBSession openActiveSessionWithPublishPermissions:@[@"publish_actions", @"publish_stream", @"friends_likes", @"read_stream"] defaultAudience:FBSessionDefaultAudienceEveryone allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
//            
//            
//        }];
//        
//        return;
        
        loginView = [[FBLoginView alloc] initWithReadPermissions:@[@"public_profile", @"email", @"user_friends", @"publish_actions", @"publish_stream", @"friends_likes", @"read_stream"]];
        loginView.delegate = self;
        // Align the button in the center horizontally
        
        loginView.frame = CGRectMake(126, _btnConnect.frame.origin.y, 72, 72);
        for (id obj in loginView.subviews)
        {
            if ([obj isKindOfClass:[UIButton class]])
            {
                UIButton * loginButton =  obj;
                UIImage *loginImage = [UIImage imageNamed:@"login_fb_icon.png"];
                [loginButton setBackgroundImage:loginImage forState:UIControlStateNormal];
                [loginButton setBackgroundImage:nil forState:UIControlStateSelected];
                [loginButton setBackgroundImage:nil forState:UIControlStateHighlighted];
                [loginButton sizeToFit];
                loginButton.alpha = 0.0;
                
                _loginButton = loginButton;
            }
            if ([obj isKindOfClass:[UILabel class]])
            {
                UILabel * loginLabel =  obj;
                loginLabel.text = @"";
                loginLabel.textAlignment = NSTextAlignmentCenter;
                loginLabel.frame = CGRectZero;
            }
        }
        [self.view addSubview:loginView];
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        _loginImvBg.frame = CGRectMake(_loginImvBg.frame.origin.x, 135, _loginImvBg.frame.size.width, _loginImvBg.frame.size.height);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.35 animations:^{
            _loginImvBg2.alpha = 1.0;
            if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"tempLogout"] boolValue]) {
                _loginButton.alpha = 1.0;
            }
            else{
                _btnConnect.alpha = 1.0;
            }
            _lblConnect.alpha = 1.0;
        } completion:^(BOOL finished) {
            
        }];
    }];
    
    if (![ASIHTTPRequest isNetworkReachable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Whoops! No Internet connection found. Please check your connection or try again later." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        _loginButton.enabled = NO;
    }
    
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    exit(0);
}

-(IBAction)loginButtonClicked:(id)sender{
    
    SAFE_RELEASE_VIEW(loginView);
    loginView = [[FBLoginView alloc] initWithReadPermissions:@[@"public_profile", @"email", @"user_friends", @"publish_actions", @"publish_stream", @"friends_likes", @"read_stream"]];
    loginView.delegate = self;
    // Align the button in the center horizontally
    
    loginView.frame = CGRectMake(126, 376, 72, 72);
    for (id obj in loginView.subviews)
    {
        if ([obj isKindOfClass:[UIButton class]])
        {
            UIButton * loginButton =  obj;
            UIImage *loginImage = [UIImage imageNamed:@"login_fb_icon.png"];
            [loginButton setBackgroundImage:loginImage forState:UIControlStateNormal];
            [loginButton setBackgroundImage:nil forState:UIControlStateSelected];
            [loginButton setBackgroundImage:nil forState:UIControlStateHighlighted];
            [loginButton sizeToFit];
            loginButton.alpha = 0.0;
            
            _loginButton = loginButton;
        }
        if ([obj isKindOfClass:[UILabel class]])
        {
            UILabel * loginLabel =  obj;
            loginLabel.text = @"";
            loginLabel.textAlignment = NSTextAlignmentCenter;
            loginLabel.frame = CGRectZero;
        }
    }
    [self.view addSubview:loginView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    UIWebView *web = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
//    [web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://gobbl.snapplab.com/auth/facebook"]]];
//    [self.view addSubview:web];
//    
//    return;
    
    
    _isGoToHome = NO;
    _isTouchOnButton = NO;
    
    _lblConnect.font = [UIFont fontWithName:@"Roboto-Condensed" size:20.0];
    
    
    
    
//    [[FBSession activeSession] requestNewPublishPermissions:@[@"public_profile", @"email", @"user_friends", @"publish_actions", @"publish_stream", @"friends_likes", @"read_stream"] defaultAudience:FBSessionDefaultAudienceFriends
//                                          completionHandler:^(FBSession *session,NSError *error){
//                                              
//                                              
//                                              
//                                              
//                                          }];
    
//    FBSession* session = [FBSession activeSession];
//    
//    if ([session isOpen]) {
//        // Open session with public_profile (required) and user_birthday read permissions
//        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"email", @"user_friends", @"publish_actions", @"publish_stream", @"friends_likes", @"read_stream"]
//                                           allowLoginUI:YES
//                                      completionHandler:
//         ^(FBSession *session, FBSessionState state, NSError *error) {
//             __block NSString *alertText;
//             __block NSString *alertTitle;
//             if (!error){
//                 // If the session was opened successfully
//                 if (state == FBSessionStateOpen){
//                     // Your code here
//                     
//                 } else {
//                     // There was an error, handle it
//                     if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
//                         // Error requires people using an app to make an action outside of the app to recover
//                         // The SDK will provide an error message that we have to show the user
//                         alertTitle = @"Something went wrong";
//                         alertText = [FBErrorUtility userMessageForError:error];
//                         [[[UIAlertView alloc] initWithTitle:alertTitle
//                                                     message:alertText
//                                                    delegate:self
//                                           cancelButtonTitle:@"OK!"
//                                           otherButtonTitles:nil] show];
//                         
//                     } else {
//                         // If the user cancelled login
//                         if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
//                             alertTitle = @"Login cancelled";
//                             alertText = @"Your birthday will not be entered in our calendar because you didn't grant the permission.";
//                             [[[UIAlertView alloc] initWithTitle:alertTitle
//                                                         message:alertText
//                                                        delegate:self
//                                               cancelButtonTitle:@"OK!"
//                                               otherButtonTitles:nil] show];
//                             
//                         } else {
//                             // For simplicity, in this sample, for all other errors we show a generic message
//                             // You can read more about how to handle other errors in our Handling errors guide
//                             // https://developers.facebook.com/docs/ios/errors/
//                             NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"]
//                                                                objectForKey:@"body"]
//                                                               objectForKey:@"error"];
//                             alertTitle = @"Something went wrong";
//                             alertText = [NSString stringWithFormat:@"Please retry. \nIf the problem persists contact us and mention this error code: %@",[errorInformation objectForKey:@"message"]];
//                             [[[UIAlertView alloc] initWithTitle:alertTitle
//                                                         message:alertText
//                                                        delegate:self
//                                               cancelButtonTitle:@"OK!"
//                                               otherButtonTitles:nil] show];
//                         }
//                     }
//                 }
//             }
//         }];
//    }
}

// This method will be called when the user information has been fetched
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    
    NSLog(@"LOGIN OK");
    
    if ([user objectForKey:@"id"]) {
        [kApplicationDelegate setUserFBId:[user objectForKey:@"id"]];
    }
    
    
//    [[FBSession activeSession] requestNewPublishPermissions:@[@"public_profile", @"email", @"user_friends", @"publish_actions", @"publish_stream", @"friends_likes", @"read_stream"] defaultAudience:FBSessionDefaultAudienceFriends
//                                          completionHandler:^(FBSession *session,NSError *error){
//                                              
//                                              
//                                              
//                                              
//                                          }];
    
    if ([[FBSession activeSession] isOpen]) {
        [MBProgressHUD showHUDAddedTo:[kApplicationDelegate window] animated:YES];
        
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/auth/facebook", urlReal] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        
        __weak typeof(ASIHTTPRequest *) weakSelf = request;
        
        [request setCompletionBlock:^{
            [self requestLoginDidFinish:weakSelf];
        }];
        
        [request setFailedBlock:^{
            [self requestLoginDidFail:weakSelf];
        }];
        
//        [request setDidFinishSelector:@selector(requestLoginDidFinish:)];
//        [request setDidFailSelector:@selector(requestLoginDidFail:)];
//        request.delegate = self;
        
        [request setRequestMethod:@"GET"];
        [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
        
//        [request setUseCookiePersistence:YES];
//        [request setUseSessionPersistence:YES];
//
//        [request addRequestHeader:@"Vary" value:@"Accept-Encoding"];
//        [request addRequestHeader:@"X-Powered-By" value:@"Express"];
        
//        [request setShouldRedirect:NO];
        
        [request startAsynchronous];
    }
    
}

-(void)requestLoginDidFail:(ASIHTTPRequest *)request{
    NSString *theJSON = [request responseString];
    NSLog(@"requestDidFinish:%@", theJSON);
    
    [MBProgressHUD hideAllHUDsForView:[kApplicationDelegate window] animated:YES];
}

-(void)requestLoginDidFinish:(ASIHTTPRequest *)request{
    NSLog(@"requestDidFinish:%d", request.responseStatusCode);
    
    
    
    if(request.responseStatusCode == 200 && !_isGoToHome)
    {
//        [[UIApplication sharedApplication] openURL:request.url];
        
        [MBProgressHUD hideAllHUDsForView:[kApplicationDelegate window] animated:YES];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"_isLoggedIn"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSHTTPCookie *cookie;
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
        
//        NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
//                                    urlReal, NSHTTPCookieOriginURL,
//                                    @"connect.sid", NSHTTPCookieName,
//                                    @"s%3ArXmxIugq1kEdNmW_2WRvHbzRSC1AWjkl.cUMAlHK7KyFEeg46QjTFwz5Z66EvxU%2BV3npvQCm7tF4", NSHTTPCookieValue,
//                                    nil];
        
//        NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
//                                    urlReal, NSHTTPCookieDomain,
//                                    @"/", NSHTTPCookiePath,  // IMPORTANT!
//                                    @"connect.sid", NSHTTPCookieName,
//                                    @"s%3AgSbe6s-H5yuLu45nUPyvelGov47DIGk4.xImuQ3el%2FJXjmHrSPC742aCIPA%2Fcu4HBWsxX%2F0rgKmk", NSHTTPCookieValue,
//                                    nil];
//        
//        NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:properties];
        
        //s%3ArXmxIugq1kEdNmW_2WRvHbzRSC1AWjkl.cUMAlHK7KyFEeg46QjTFwz5Z66EvxU%2BV3npvQCm7tF4
        NSMutableDictionary* cookieDictionary = [[NSMutableDictionary alloc] init];
        [cookieDictionary setValue:cookie.properties forKey:urlReal];
        
        [[NSUserDefaults standardUserDefaults] setObject:cookieDictionary forKey:@"goobCookie"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        
        ASIHTTPRequest *requestUser = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/users/me", urlReal] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        
        __weak typeof(ASIHTTPRequest *) weakSelf = requestUser;
        
        [requestUser setCompletionBlock:^{
            [self requestUserMeDidFinish:weakSelf];
        }];
        
        [requestUser setFailedBlock:^{
            [self requestUserMeDidFail:weakSelf];
        }];
        
//        [requestUser setDidFinishSelector:@selector(requestUserMeDidFinish:)];
//        [requestUser setDidFailSelector:@selector(requestUserMeDidFail:)];
//        requestUser.delegate = self;
        
        [requestUser setRequestMethod:@"GET"];
        [requestUser addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
        
        [requestUser setUseCookiePersistence:NO];
        [requestUser setUseSessionPersistence:NO];
        
        if (cookie) {
            [requestUser setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
        }
        
        [requestUser addRequestHeader:@"Vary" value:@"Accept-Encoding"];
        [requestUser addRequestHeader:@"X-Powered-By" value:@"Express"];
        [requestUser startAsynchronous];
        
        
        
        
    }
    else if(request.responseStatusCode == 500){
//        [MBProgressHUD showHUDAddedTo:[kApplicationDelegate window] animated:YES];
        
        
        ASIHTTPRequest *requestL = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/auth/facebook", urlReal] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        
        __weak typeof(ASIHTTPRequest *) weakSelf = requestL;
        
        [requestL setCompletionBlock:^{
            [self requestLoginDidFinish:weakSelf];
        }];
        
        [requestL setFailedBlock:^{
            [self requestLoginDidFail:weakSelf];
        }];
        
//        [requestL setDidFinishSelector:@selector(requestLoginDidFinish:)];
//        [requestL setDidFailSelector:@selector(requestLoginDidFail:)];
//        requestL.delegate = self;
        [requestL setRequestMethod:@"GET"];
        [requestL addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
        [requestL startAsynchronous];
    }
}

-(void)requestUserMeDidFinish:(ASIHTTPRequest *)request{
    NSString *theJSON = [request responseString];
    NSLog(@"requestUserMeDidFinish:%@", theJSON);
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *userData = [[NSDictionary alloc] initWithDictionary:[[parser objectWithString:theJSON] objectForKey:@"data"]];
    [[NSUserDefaults standardUserDefaults] setObject:userData forKey:@"userData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (!_isGoToHome) {
        _isGoToHome = YES;
        
        [MBProgressHUD hideAllHUDsForView:[kApplicationDelegate window] animated:YES];
        
        SAFE_RELEASE_VIEW(loginView);
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"tempLogout"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        FAHomeViewController *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"Home"];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

-(void)requestUserMeDidFail:(ASIHTTPRequest *)request{
    NSLog(@"requestUserMeDidFail:%d", request.responseStatusCode);
    
//    [MBProgressHUD showHUDAddedTo:[kApplicationDelegate window] animated:YES];
    
    
    ASIHTTPRequest *requestLogout = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/deauth", urlReal] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
//    __weak typeof(ASIHTTPRequest *) weakSelf = requestLogout;
    
    [requestLogout setCompletionBlock:^{
        ASIHTTPRequest *requestL = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/auth/facebook", urlReal] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        
        __weak typeof(ASIHTTPRequest *) weakSelf = requestL;
        
        [requestL setCompletionBlock:^{
            [self requestLoginDidFinish:weakSelf];
        }];
        
        [requestL setFailedBlock:^{
            [self requestLoginDidFail:weakSelf];
        }];
        
        //    [requestL setDidFinishSelector:@selector(requestLoginDidFinish:)];
        //    [requestL setDidFailSelector:@selector(requestLoginDidFail:)];
        //    requestL.delegate = self;
        
        [requestL setRequestMethod:@"GET"];
        [requestL addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
        [requestL startAsynchronous];
    }];
    
    [requestLogout setFailedBlock:^{
        
    }];
    
    //        [requestLogout setDidFinishSelector:@selector(requestLogoutDidFinish:)];
    //        [requestLogout setDidFailSelector:@selector(requestLogoutDidFail:)];
    //        requestLogout.delegate = self;
    
    [requestLogout setRequestMethod:@"GET"];
    [requestLogout addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    
    [requestLogout setUseCookiePersistence:NO];
    [requestLogout setUseSessionPersistence:NO];
    
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:[[[NSUserDefaults standardUserDefaults] objectForKey:@"goobCookie"] objectForKey:urlReal]];
    
    if (cookie) {
        [requestLogout setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
    }
    
    [requestLogout addRequestHeader:@"Vary" value:@"Accept-Encoding"];
    [requestLogout addRequestHeader:@"X-Powered-By" value:@"Express"];
    [requestLogout startAsynchronous];
    
    
    
    
    
}

// Logged-in user experience
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    
    NSLog(@"LOGIN AS");
}

// Logged-out user experience
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    NSLog(@"LOGOUT");
    _isTouchOnButton = NO;
}

// Handle possible errors that can occur during login
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSString *alertMessage, *alertTitle;
    
    // If the user should perform an action outside of you app to recover,
    // the SDK will provide a message for the user, you just need to surface it.
    // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
        
        // This code will handle session closures that happen outside of the app
        // You can take a look at our error handling guide to know more about it
        // https://developers.facebook.com/docs/ios/errors
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
        
        // If the user has cancelled a login, we will do nothing.
        // You can also choose to show the user a message if cancelling login will result in
        // the user not being able to complete a task they had initiated in your app
        // (like accessing FB-stored information or posting to Facebook)
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
//        alertTitle  = @"Something went wrong";
//        alertMessage = @"Please try again later.";
        
        // For simplicity, this sample handles other errors with a generic message
        // You can checkout our error handling guide for more detailed information
        // https://developers.facebook.com/docs/ios/errors
    } else {
        alertTitle  = @"Something went wrong";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
