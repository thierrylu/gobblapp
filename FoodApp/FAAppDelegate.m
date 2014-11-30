//
//  FAAppDelegate.m
//  FoodApp
//
//  Created by CHINH LE on 6/9/14.
//  Copyright (c) 2014 chinhlt. All rights reserved.
//

#import "FAAppDelegate.h"
#import "FlipSquaresNavigationController.h"
#import "FALoginViewController.h"
#import "FAHomeViewController.h"

#import "LABase64.h"

@implementation FAAppDelegate

- (void)setMaskTo:(UIView*)view byRoundingCorners:(UIRectCorner)corners angleCorner:(float)angle
{
    UIBezierPath *rounded = [UIBezierPath bezierPathWithRoundedRect:view.bounds
                                                  byRoundingCorners:corners
                                                        cornerRadii:CGSizeMake(angle, angle)];
    CAShapeLayer *shape = [[CAShapeLayer alloc] init];
    [shape setPath:rounded.CGPath];
    view.layer.mask = shape;
}

- (void)setBorderTo:(UIView*)view byRoundingCorners:(CGRect)rect color:(UIColor *)color{
    CALayer *layerBorder = [CALayer layer];
    layerBorder.frame = rect;
    layerBorder.backgroundColor = color.CGColor;
    [view.layer addSublayer:layerBorder];
}

-(void)notification_LocationService{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"firstStartLocation"]) {
        if (_locationManager.locationStatus == kCLAuthorizationStatusDenied) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"firstStartLocation"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"To turn on Location Services and get more accurate results, please do the following: Go to iPhone settings > Tap Privacy > Tap Location Services > Set Gobbl to ON." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
    }
}

-(void)requestDidFinish:(ASIHTTPRequest *)request{
    NSString *theJSON = [request responseString];
    NSLog(@"requestDidFinish:%@", theJSON);
    
   
    
}

-(void)requestDidFail:(ASIHTTPRequest *)request{
    NSString *theJSON = [request responseString];
    NSLog(@"requestDidFail:%@", theJSON);
    
   
    
}

#pragma mark - Class's Private Methods
- (void)_networkReachabilityChanged:(NSNotification *)notification {
	NetworkStatus status = [_reachNetwork currentReachabilityStatus];
    if (status == kReachableViaWiFi) {
        if (!_haveNetwork) {
            
        }
        _haveNetwork = YES;
    }
    else{
        _haveNetwork = NO;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"haveNetworkNotification" object:nil];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    
//    ASIHTTPRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[@"http://www.high-learning.com/webservices/call.php" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
//    [request setDidFinishSelector:@selector(requestNewsDidFinish:)];
//    [request setDidFailSelector:@selector(requestNewsDidFail:)];
//    request.delegate = self;
//    [request setRequestMethod:@"POST"];
//    [request addRequestHeader:@"Content-Type" value:@"application/json"];
//    
//    //{"content":{"login":"test","pass":"test","secretkey":"test"},"function":"AUTHENTIFICATION"}
//    
//    NSDictionary *importantNumbers = @{
//                                       @"AUTHENTIFICATION" : @"function",
//                                       @{@"test" : @"login",@"test" : @"pass",@"test" : @"secretkey"} : @"content"
//                                       };
//    
//    SBJsonWriter *writerJSON = [[SBJsonWriter alloc] init];
//    NSString *jsonString = [writerJSON stringWithObject:importantNumbers];
//    
//    
//    jsonString = [jsonString base64Encoded];
//    NSMutableData *data = [[NSMutableData alloc] initWithData:[@"{\"content\":{\"login\":\"test\",\"pass\":\"test\",\"secretkey\":\"test\"},\"function\":\"AUTHENTIFICATION\"}" dataUsingEncoding:NSUTF8StringEncoding]];
//    [request setPostBody:data];
//    
//    [request startAsynchronous];
    
    // Override point for customization after application launch.
    
//    NSArray *vComp = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
//    if ([[vComp objectAtIndex:0] intValue] >= 7) {
//        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
//    }
//    else{
//        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
//    }
    
    _haveNetwork = NO;
    _reachNetwork = [Reachability reachabilityWithHostName:@"apple.com"];
    [_reachNetwork startNotifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_networkReachabilityChanged:) name:@"NetworkReachabilityChangedNotification" object:nil];
    
    _locationManager = [LocationManager locationManager];
    
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"enableLocation"]) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"enableLocation"];
    }
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"tempLogout"]) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"tempLogout"];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notification_LocationService) name:@"Notification_LocationService" object:nil];
    
    // Start location manager
    __autoreleasing NSNumber *enableLocation = [[NSUserDefaults standardUserDefaults] objectForKey:@"enableLocation"];
    if (enableLocation && [enableLocation boolValue]) {
        [_locationManager startLocation];
    }
    
    [FBLoginView class];
    [FBProfilePictureView class];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    // Override point for customization after application launch.
    

    
    _isLoggedIn = NO;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"_isLoggedIn"]) {
        _isLoggedIn = [[[NSUserDefaults standardUserDefaults] objectForKey:@"_isLoggedIn"] boolValue];
    }
    else {
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"_isLoggedIn"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
//    #if TARGET_IPHONE_SIMULATOR
    
    
    FAHomeViewController *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"Home"];
    UINavigationController *myNav = [[UINavigationController alloc] initWithRootViewController:viewController];
    [myNav setNavigationBarHidden:YES];
    
    self.window.rootViewController = myNav;
    
//    #else
    if (_isLoggedIn) {
        FAHomeViewController *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"Home"];
        
        FALoginViewController *loginViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"Login"];
        
        UINavigationController *myNav = [[UINavigationController alloc] initWithRootViewController:loginViewController];
        [myNav setNavigationBarHidden:YES];
        
        [loginViewController.navigationController pushViewController:viewController animated:NO];
        
        self.window.rootViewController = myNav;
    }
    else{
        FALoginViewController *loginViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"Login"];
        UINavigationController *myNav = [[UINavigationController alloc] initWithRootViewController:loginViewController];
        [myNav setNavigationBarHidden:YES];
        
        self.window.rootViewController = myNav;
    }
//    #endif
    
    
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

//- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
//    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
//    int status = [httpResponse statusCode];
//    NSLog(@"http status code: %d", status);
//    
//    
//}
//
//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
//    NSURLConnection *conn = [NSURLConnection connectionWithRequest:request delegate:self];
//    if (conn == nil) {
//        NSLog(@"cannot create connection");
//    }
//    return YES;
//}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    [MBProgressHUD hideAllHUDsForView:[kApplicationDelegate window] animated:NO];
    [MBProgressHUD showHUDAddedTo:[kApplicationDelegate window] animated:YES];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [MBProgressHUD hideHUDForView:[kApplicationDelegate window] animated:YES];
    
    BOOL isOK = NO;
    
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies])
    {
        NSString* domainName = [cookie domain];
        NSLog(@"domain:%@, value:%@, coookie:%@", domainName, cookie.value, cookie);
        NSRange domainRange = [domainName rangeOfString:urlReal];
        if(domainRange.length > 0)
        {
            isOK = YES;
            break;
        }
    }
    
    if ([[NSString stringWithFormat:@"%@", [[webView request] URL]] isEqualToString:urlReal]) {
        [webView removeFromSuperview];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"_isLoggedIn"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        FAHomeViewController *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"Home"];
        UINavigationController *myNav = [[UINavigationController alloc] initWithRootViewController:viewController];
        [myNav setNavigationBarHidden:YES];
        
        self.window.rootViewController = myNav;
    }
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [MBProgressHUD hideHUDForView:[kApplicationDelegate window] animated:YES];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    BOOL urlWasHandled = [FBAppCall handleOpenURL:url
                                sourceApplication:sourceApplication
                                  fallbackHandler:^(FBAppCall *call) {
                                      // incoming link processing goes here
                                  }];
    
    return urlWasHandled;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
