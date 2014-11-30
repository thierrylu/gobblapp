//
//  FAHomeViewController.m
//  FoodApp
//
//  Created by CHINH LE on 6/9/14.
//  Copyright (c) 2014 chinhlt. All rights reserved.
//

#import "FAHomeViewController.h"
#import "ZoomInSegue.h"
#import "ZoomOutSegue.h"
#import "CustomSegue.h"
#import "CustomUnwindSegue.h"

#import "FACameraViewController.h"
#import "FADishViewController.h"

#import "JCRBlurView.h"

#import "FATermViewController.h"
#import "FAAboutViewController.h"

#import "ASINetworkQueue.h"

#import "MyLocation.h"


#define METERS_PER_MILE 1000.0

@interface FAHomeViewController ()

@end

@implementation FAHomeViewController

// Prepare for the segue going forward
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue isKindOfClass:[CustomSegue class]] && [segue.destinationViewController isKindOfClass:[FACameraViewController class]]) {
        ((CustomSegue *)segue).originatingPoint = _cameraButton.center;
        ((CustomSegue *)segue).isLeft = 1;
    }
    else if([segue isKindOfClass:[CustomSegue class]] && [segue.destinationViewController isKindOfClass:[FADishViewController class]]) {
        ((CustomSegue *)segue).originatingPoint = _cameraButton.center;
        ((CustomSegue *)segue).isLeft = 2;
    }
}

- (IBAction)unwindFromViewController:(UIStoryboardSegue *)sender {
    
}

// We need to over-ride this method from UIViewController to provide a custom segue for unwinding
- (UIStoryboardSegue *)segueForUnwindingToViewController:(UIViewController *)toViewController fromViewController:(UIViewController *)fromViewController identifier:(NSString *)identifier {
    // Instantiate a new CustomUnwindSegue
    CustomUnwindSegue *segue = [[CustomUnwindSegue alloc] initWithIdentifier:identifier source:fromViewController destination:toViewController];
    if([fromViewController isKindOfClass:[FACameraViewController class]]) {
        ((CustomUnwindSegue *)segue).isLeft = 1;
    }
    else if([fromViewController isKindOfClass:[FADishViewController class]]) {
        ((CustomUnwindSegue *)segue).isLeft = 2;
    }
    return segue;
}

-(void)requestDataDidFinish:(ASIHTTPRequest *)request{
    NSString *theJSON = [request responseString];
    NSLog(@"requestDataDidFinish:%@", theJSON);
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    
    SAFE_RELEASE_ARRAY(_arrDataNews);
    _arrDataNews = [[NSMutableArray alloc] initWithArray:[[parser objectWithString:theJSON] objectForKey:@"data"]];
    
    if (_arrDataNews.count > 0) {
        NSMutableArray *tmp = [[NSMutableArray alloc] init];
        NSInteger countItem = 20;
        if (_arrNews.count < 20) {
            countItem = _arrNews.count;
        }
        for (int i=0; i<countItem; i++) {
            NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithDictionary:[_arrNews objectAtIndex:i]];
            [item removeObjectForKey:@"likeData"];
            [item removeObjectForKey:@"dishData"];
            [item removeObjectForKey:@"restData"];
            [tmp addObject:item];
        }
        
        
        
        if ((![tmp isEqual:_arrDataNews] && self.detailView.alpha == 0.0 && self.searchView.frame.origin.x != 0 && !_isOpeningDetail && _arrDataNews.count > 0) || _isInsertNewDish) {
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 5, 30, 30)];
            [btn setImage:[UIImage imageNamed:@"refresh_icon.png"] forState:UIControlStateNormal];
            btn.imageView.contentMode = UIViewContentModeScaleAspectFit;
            btn.tag = 999;
            [btn addTarget:self action:@selector(loadNewData) forControlEvents:UIControlEventTouchUpInside];
            _topBarItem.titleView = btn;
        }
        
        _isInsertNewDish = NO;
        if (_isOpeningDetail) {
            _isOpeningDetail = NO;
        }
    }
}

-(void)requestDataDidFail:(ASIHTTPRequest *)request{
    NSString *theJSON = [request responseString];
    NSLog(@"requestDataDidFail:%@", theJSON);
    
    if (![ASIHTTPRequest isNetworkReachable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Whoops! No Internet connection found. Please check your connection or try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

-(void)loadNewData{
    if (_isLoadingMore) return;
    
    _topBarItem.titleView = nil;
    
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:[kApplicationDelegate window] animated:YES];
    HUD.labelText = @"Refreshing...";
    HUD.detailsLabelText = @"Please wait";
    
    currentSnapNewsPageIndex = 0;
    currentSnapTrendingPageIndex = 0;
    
    NSMutableArray *arr1 = [[NSMutableArray alloc] init];
    for (int i=0; i<_arrNews.count; i++) {
        [arr1 addObject:[NSIndexPath indexPathForItem:i inSection:0]];
    }
    
    NSMutableArray *arr2 = [[NSMutableArray alloc] init];
    for (int i=0; i<_arrTrends.count; i++) {
        [arr2 addObject:[NSIndexPath indexPathForItem:i inSection:0]];
    }
    
    
    SAFE_RELEASE_ARRAY(_arrNews);
    SAFE_RELEASE_ARRAY(_arrTrends);
    
    if (_leftCollectionView.contentOffset.y > _leftCollectionView.frame.size.height) {
        [_leftCollectionView setContentOffset:CGPointMake(0, 0) animated:NO];
    }
    
    if (_rightCollectionView.contentOffset.y > _rightCollectionView.frame.size.height) {
        [_rightCollectionView setContentOffset:CGPointMake(0, 0) animated:NO];
    }
    
    
    ASIHTTPRequest *requestN = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/snaps/new?[{\"lat\":%f,\"lng\":%f}, {\"page\":%d}]", urlReal, [LocationManager locationManager].currentLocation.coordinate.latitude, [LocationManager locationManager].currentLocation.coordinate.longitude, (int)currentSnapNewsPageIndex+1] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    __weak typeof(ASIHTTPRequest *) weakSelf1 = requestN;
    
    [requestN setCompletionBlock:^{
        [self requestNewsDidFinish:weakSelf1];
    }];
    
    [requestN setFailedBlock:^{
        [self requestNewsDidFail:weakSelf1];
    }];
    
//    [requestN setDidFinishSelector:@selector(requestNewsDidFinish:)];
//    [requestN setDidFailSelector:@selector(requestNewsDidFail:)];
//    requestN.delegate = self;
    
    [requestN setRequestMethod:@"GET"];
    [requestN addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    
    [requestN setUseCookiePersistence:NO];
    [requestN setUseSessionPersistence:NO];
    
    if (cookie) {
        [requestN setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
    }
    
    [requestN addRequestHeader:@"Vary" value:@"Accept-Encoding"];
    [requestN addRequestHeader:@"X-Powered-By" value:@"Express"];
    [requestN startAsynchronous];
    
    ASIHTTPRequest *requestT = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/snaps/trending?[{\"lat\":%f,\"lng\":%f}, {\"page\":%d}]", urlReal, [LocationManager locationManager].currentLocation.coordinate.latitude, [LocationManager locationManager].currentLocation.coordinate.longitude, (int)currentSnapTrendingPageIndex+1] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    __weak typeof(ASIHTTPRequest *) weakSelf2 = requestT;
    
    [requestT setCompletionBlock:^{
        [self requestTrendingDidFinish:weakSelf2];
    }];
    
    [requestT setFailedBlock:^{
        [self requestTrendingDidFail:weakSelf2];
    }];
    
//    [requestT setDidFinishSelector:@selector(requestTrendingDidFinish:)];
//    [requestT setDidFailSelector:@selector(requestTrendingDidFail:)];
//    requestT.delegate = self;
    
    [requestT setRequestMethod:@"GET"];
    [requestT addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    
    [requestT setUseCookiePersistence:NO];
    [requestT setUseSessionPersistence:NO];
    
    if (cookie) {
        [requestT setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
    }
    
    [requestT addRequestHeader:@"Vary" value:@"Accept-Encoding"];
    [requestT addRequestHeader:@"X-Powered-By" value:@"Express"];
    [requestT startAsynchronous];
}



-(void)enAbleScroll1{
    _isLoadingMore = NO;
    _leftCollectionView.scrollEnabled = YES;
}

-(void)enAbleScroll2{
    _isLoadingMore = NO;
    _rightCollectionView.scrollEnabled = YES;
}

-(void)checkAndLogout401:(int)statusCode{
    NSLog(@"request code:%d", statusCode);
    if (statusCode == 401) {
        
        [MBProgressHUD showHUDAddedTo:[kApplicationDelegate window] animated:YES];
        
        ASIHTTPRequest *requestLogout = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/deauth", urlReal] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        
        __weak typeof(ASIHTTPRequest *) weakSelf = requestLogout;
        
        [requestLogout setCompletionBlock:^{
            [self requestLogoutDidFinish:weakSelf];
        }];
        
        [requestLogout setFailedBlock:^{
            [self requestLogoutDidFail:weakSelf];
        }];
        
        //        [requestLogout setDidFinishSelector:@selector(requestLogoutDidFinish:)];
        //        [requestLogout setDidFailSelector:@selector(requestLogoutDidFail:)];
        //        requestLogout.delegate = self;
        
        [requestLogout setRequestMethod:@"GET"];
        [requestLogout addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
        
        [requestLogout setUseCookiePersistence:NO];
        [requestLogout setUseSessionPersistence:NO];
        
        if (cookie) {
            [requestLogout setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
        }
        
        [requestLogout addRequestHeader:@"Vary" value:@"Accept-Encoding"];
        [requestLogout addRequestHeader:@"X-Powered-By" value:@"Express"];
        [requestLogout startAsynchronous];
        
        return;
    }
}

-(void)requestNewsDidFinish:(ASIHTTPRequest *)request{
    
    NSString *theJSON = [request responseString];
    NSLog(@"requestNewsDidFinish:%@", theJSON);
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    
    
    NSInteger countCurrentNewItems = currentSnapNewsPageIndex*20;
    
    BOOL _flagHave = NO;
    _isLoadingMore = YES;
//    _isLoadingMore = NO;
    if (!_arrNews) {
//        _arrTrends = [[NSMutableArray alloc] init];
//        [_leftCollectionView reloadData];
        
        _flagHave = YES;
        _arrNews = [[NSMutableArray alloc] initWithArray:[[parser objectWithString:theJSON] objectForKey:@"data"]];
        currentSnapNewsPageIndex++;
        
        
    }
    else{
        NSInteger tmpCount = _arrNews.count;
        [_arrNews addObjectsFromArray:[[parser objectWithString:theJSON] objectForKey:@"data"]];
        if (tmpCount < _arrNews.count) {
            _flagHave = YES;
            currentSnapNewsPageIndex++;
        }
    }
    [self performSelector:@selector(enAbleScroll1) withObject:nil afterDelay:0.5];
    if (_flagHave) {
        [_leftCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([FACellDish class]) bundle:nil]
              forCellWithReuseIdentifier:NSStringFromClass([FACellDish class])];
        

        if (_arrNews.count > 0) {
            [_leftCollectionView reloadData];
        }
        else{
            _isLoadingMore = NO;
        }
        
        [self.contentView bringSubviewToFront:_vShowNew];
        
        [UIView animateWithDuration:1.0 animations:^{
            _vShowNew.alpha = 0.0;
        }];

        ASINetworkQueue *queue = [[ASINetworkQueue alloc] init];
        queue.delegate = self;
        
        ASINetworkQueue *queueDish = [[ASINetworkQueue alloc] init];
        queueDish.delegate = self;
        
        ASINetworkQueue *queueLikes = [[ASINetworkQueue alloc] init];
        queueLikes.delegate = self;
        
        for (NSInteger i=countCurrentNewItems; i<_arrNews.count; i++) {
            if ([[[_arrNews objectAtIndex:i] allKeys] containsObject:@"restaurant"]) {
                ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/restaurants/%@", urlReal, [[_arrNews objectAtIndex:i] objectForKey:@"restaurant"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                
                __weak typeof(ASIHTTPRequest *) weakSelf = request;
                
                [request setCompletionBlock:^{
                    [self requestRestaurantDidFinish:weakSelf];
                }];
                
                [request setFailedBlock:^{
                    [self requestRestaurantDidFail:weakSelf];
                }];
                
//                [request setDidFinishSelector:@selector(requestRestaurantDidFinish:)];
//                [request setDidFailSelector:@selector(requestRestaurantDidFail:)];
//                request.delegate = self;
                
                [request setRequestMethod:@"GET"];
                [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
                
                [request setUseCookiePersistence:NO];
                [request setUseSessionPersistence:NO];
                
                if (cookie) {
                    [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
                }
                
                [request addRequestHeader:@"Vary" value:@"Accept-Encoding"];
                [request addRequestHeader:@"X-Powered-By" value:@"Express"];
                [queue addOperation:request];
            }
            if ([[[_arrNews objectAtIndex:i] allKeys] containsObject:@"dish"]) {
                ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/dishes/%@", urlReal, [[_arrNews objectAtIndex:i] objectForKey:@"dish"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                
                __weak typeof(ASIHTTPRequest *) weakSelf = request;
                
                [request setCompletionBlock:^{
                    [self requestDishDidFinish:weakSelf];
                }];
                
                [request setFailedBlock:^{
                    [self requestDishDidFail:weakSelf];
                }];
                
//                [request setDidFinishSelector:@selector(requestDishDidFinish:)];
//                [request setDidFailSelector:@selector(requestDishDidFail:)];
//                request.delegate = self;
                
                [request setRequestMethod:@"GET"];
                [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
                
                [request setUseCookiePersistence:NO];
                [request setUseSessionPersistence:NO];
                
                if (cookie) {
                    [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
                }
                
                [request addRequestHeader:@"Vary" value:@"Accept-Encoding"];
                [request addRequestHeader:@"X-Powered-By" value:@"Express"];
                [queueDish addOperation:request];
            }
            
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/snaps/%@/likes", urlReal, [[_arrNews objectAtIndex:i] objectForKey:@"_id"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            
            __weak typeof(ASIHTTPRequest *) weakSelf = request;
            
            [request setCompletionBlock:^{
                [self requestLoadLikeDidFinish:weakSelf];
            }];
            
            [request setFailedBlock:^{
                [self requestLoadLikeDidFail:weakSelf];
            }];
            
//            [request setDidFinishSelector:@selector(requestLoadLikeDidFinish:)];
//            [request setDidFailSelector:@selector(requestLoadLikeDidFail:)];
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
            [queueLikes addOperation:request];
        }
        
        [queue setQueueDidFinishSelector:@selector(queueDidFinish:)];
        
        if (queue.operations.count > 0) {
            [queue go];
        }
        
        [queueDish setQueueDidFinishSelector:@selector(queueDishDidFinish:)];
        
        if (queueDish.operations.count > 0) {
            [queueDish go];
        }
        
        [queueLikes setQueueDidFinishSelector:@selector(queueLikesDidFinish:)];
        
        if (queueLikes.operations.count > 0) {
            [queueLikes go];
        }
    }
    
    [MBProgressHUD hideAllHUDsForView:[kApplicationDelegate window] animated:YES];
    
}

-(void)requestNewsDidFail:(ASIHTTPRequest *)request{
    NSString *theJSON = [request responseString];
    NSLog(@"requestNewsDidFail:%@", theJSON);
    
    [MBProgressHUD hideAllHUDsForView:[kApplicationDelegate window] animated:YES];
    
    
    
    _isLoadingMore = NO;
    _leftCollectionView.scrollEnabled = YES;
    
    [self checkAndLogout401:request.responseStatusCode];
    
    if (![ASIHTTPRequest isNetworkReachable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Whoops! No Internet connection found. Please check your connection or try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    else{
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"tempLogout"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        FBSession* session = [FBSession activeSession];
        //        [session closeAndClearTokenInformation];
        [session close];
        [FBSession setActiveSession:nil];
        
        NSHTTPCookie *cookieG;
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (cookieG in [storage cookies])
        {
            NSString* domainName = [cookieG domain];
            NSLog(@"domain:%@, value:%@", domainName, cookieG.value);
            NSRange domainRange = [domainName rangeOfString:urlReal];
            if(domainRange.length > 0)
            {
                [storage deleteCookie:cookieG];
            }
        }
        
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"_isLoggedIn"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}


-(void)requestTrendingDidFinish:(ASIHTTPRequest *)request{
    NSString *theJSON = [request responseString];
    NSLog(@"requestTrendingDidFinish:%@", theJSON);
    
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    
    NSInteger countCurrentTrendingItems = currentSnapTrendingPageIndex*20;
    
    BOOL _flagHave = NO;
    _isLoadingMore = YES;
//    _isLoadingMore = NO;
    if (!_arrTrends) {
//        _arrNews = [[NSMutableArray alloc] init];
//        [_rightCollectionView reloadData];
        
        _flagHave = YES;
        _arrTrends = [[NSMutableArray alloc] initWithArray:[[parser objectWithString:theJSON] objectForKey:@"data"]];
        currentSnapTrendingPageIndex++;
    }
    else{
        NSInteger tmpCount = _arrTrends.count;
        [_arrTrends addObjectsFromArray:[[parser objectWithString:theJSON] objectForKey:@"data"]];
        if (tmpCount < _arrTrends.count) {
            _flagHave = YES;
            currentSnapTrendingPageIndex++;
        }
    }
    [self performSelector:@selector(enAbleScroll2) withObject:nil afterDelay:1.5];
    if (_flagHave) {
        
        [_rightCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([FACellDish class]) bundle:nil]
              forCellWithReuseIdentifier:NSStringFromClass([FACellDish class])];
        
        if (_arrTrends.count > 0) {
            [_rightCollectionView reloadData];
        }
        else{
            _isLoadingMore = NO;
        }
        
       
        [self.contentView bringSubviewToFront:_vShowTrending];
        
        [UIView animateWithDuration:1.0 animations:^{
            _vShowTrending.alpha = 0.0;
        }];
        
        ASINetworkQueue *queue = [[ASINetworkQueue alloc] init];
        queue.delegate = self;
        
        ASINetworkQueue *queueDish = [[ASINetworkQueue alloc] init];
        queueDish.delegate = self;
        
        ASINetworkQueue *queueLikes = [[ASINetworkQueue alloc] init];
        queueLikes.delegate = self;
        
        for (NSInteger i=countCurrentTrendingItems; i<_arrTrends.count; i++) {
            if ([[[_arrTrends objectAtIndex:i] allKeys] containsObject:@"restaurant"]) {
                ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/restaurants/%@", urlReal, [[_arrTrends objectAtIndex:i] objectForKey:@"restaurant"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                
                __weak typeof(ASIHTTPRequest *) weakSelf = request;
                
                [request setCompletionBlock:^{
                    [self requestRestaurantDidFinish:weakSelf];
                }];
                
                [request setFailedBlock:^{
                    [self requestRestaurantDidFail:weakSelf];
                }];
                
//                [request setDidFinishSelector:@selector(requestRestaurantDidFinish:)];
//                [request setDidFailSelector:@selector(requestRestaurantDidFail:)];
//                request.delegate = self;
                
                [request setRequestMethod:@"GET"];
                [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
                
                [request setUseCookiePersistence:NO];
                [request setUseSessionPersistence:NO];
                
                if (cookie) {
                    [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
                }
                
                [request addRequestHeader:@"Vary" value:@"Accept-Encoding"];
                [request addRequestHeader:@"X-Powered-By" value:@"Express"];
                [queue addOperation:request];
            }
            if ([[[_arrTrends objectAtIndex:i] allKeys] containsObject:@"dish"]) {
                ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/dishes/%@", urlReal, [[_arrTrends objectAtIndex:i] objectForKey:@"dish"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                
                __weak typeof(ASIHTTPRequest *) weakSelf = request;
                
                [request setCompletionBlock:^{
                    [self requestDishDidFinish:weakSelf];
                }];
                
                [request setFailedBlock:^{
                    [self requestDishDidFail:weakSelf];
                }];
                
//                [request setDidFinishSelector:@selector(requestDishDidFinish:)];
//                [request setDidFailSelector:@selector(requestDishDidFail:)];
//                request.delegate = self;
                
                [request setRequestMethod:@"GET"];
                [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
                
                [request setUseCookiePersistence:NO];
                [request setUseSessionPersistence:NO];
                
                if (cookie) {
                    [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
                }
                
                [request addRequestHeader:@"Vary" value:@"Accept-Encoding"];
                [request addRequestHeader:@"X-Powered-By" value:@"Express"];
                [queueDish addOperation:request];
            }
            
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/snaps/%@/likes", urlReal, [[_arrTrends objectAtIndex:i] objectForKey:@"_id"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            
            __weak typeof(ASIHTTPRequest *) weakSelf = request;
            
            [request setCompletionBlock:^{
                [self requestLoadLikeDidFinish:weakSelf];
            }];
            
            [request setFailedBlock:^{
                [self requestLoadLikeDidFail:weakSelf];
            }];
            
//            [request setDidFinishSelector:@selector(requestLoadLikeDidFinish:)];
//            [request setDidFailSelector:@selector(requestLoadLikeDidFail:)];
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
            [queueLikes addOperation:request];
        }
        
        [queue setQueueDidFinishSelector:@selector(queueDidFinish:)];
        
        if (queue.operations.count > 0) {
            [queue go];
        }
        
        [queueDish setQueueDidFinishSelector:@selector(queueDishDidFinish:)];
        
        if (queueDish.operations.count > 0) {
            [queueDish go];
        }
        
        [queueLikes setQueueDidFinishSelector:@selector(queueLikesDidFinish:)];
        
        if (queueLikes.operations.count > 0) {
            [queueLikes go];
        }
    }
    
    [MBProgressHUD hideAllHUDsForView:[kApplicationDelegate window] animated:YES];
}


-(void)requestTrendingDidFail:(ASIHTTPRequest *)request{
    NSString *theJSON = [request responseString];
    NSLog(@"requestTrendingDidFail:%@", theJSON);
    
    [MBProgressHUD hideAllHUDsForView:[kApplicationDelegate window] animated:YES];
    
    _isLoadingMore = NO;
    _rightCollectionView.scrollEnabled = YES;
    
    [self checkAndLogout401:request.responseStatusCode];
    
    if (![ASIHTTPRequest isNetworkReachable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Whoops! No Internet connection found. Please check your connection or try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

-(void)delayLoadData:(NSTimer *)tIndex{
    NSInteger index = [tIndex.userInfo integerValue];
    
    NSMutableDictionary *itemData = nil;
    if (_isOpenRightSide) {
        itemData = [_arrTrends objectAtIndex:index];
        
    }
    else{
        itemData = [_arrNews objectAtIndex:index];
    }
    
    SAFE_RELEASE_ARRAY(_arrLikes);
    _arrLikes = [[NSMutableArray alloc] initWithArray:[itemData objectForKey:@"likeData"]];
    
    if (_arrLikes.count == 1) {
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/users/%@", urlReal, [[_arrLikes objectAtIndex:0] objectForKey:@"createdBy"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        
        __weak typeof(ASIHTTPRequest *) weakSelf = request;
        
        [request setCompletionBlock:^{
            [self request1UserLikeDidFinish:weakSelf];
        }];
        
        [request setFailedBlock:^{
            [self request1UserLikeDidFail:weakSelf];
        }];
        
//        [request setDidFinishSelector:@selector(request1UserLikeDidFinish:)];
//        [request setDidFailSelector:@selector(request1UserLikeDidFail:)];
//        request.delegate = self;
        
        
        [request setRequestMethod:@"GET"];
        [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
        
        [request setUseCookiePersistence:NO];
        [request setUseSessionPersistence:NO];
        
        if (cookie) {
            [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
        }
        
        [request addRequestHeader:@"Vary" value:@"Accept-Encoding"];
        [request addRequestHeader:@"X-Powered-By" value:@"Express"];
        
        [request addRequestHeader:@"snapIndex" value:[NSString stringWithFormat:@"%d", (int)index]];
        
        [request startAsynchronous];
    }
    else if (_arrLikes.count > 1) {
        [_arrLikes sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:NO]]];
        
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/users/%@", urlReal, [[_arrLikes objectAtIndex:0] objectForKey:@"createdBy"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        
        __weak typeof(ASIHTTPRequest *) weakSelf = request;
        
        [request setCompletionBlock:^{
            [self request1UserLikeDidFinish:weakSelf];
        }];
        
        [request setFailedBlock:^{
            [self request1UserLikeDidFail:weakSelf];
        }];
        
//        [request setDidFinishSelector:@selector(request1UserLikeDidFinish:)];
//        [request setDidFailSelector:@selector(request1UserLikeDidFail:)];
//        request.delegate = self;
        
        
        [request setRequestMethod:@"GET"];
        [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
        
        [request setUseCookiePersistence:NO];
        [request setUseSessionPersistence:NO];
        
        if (cookie) {
            [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
        }
        
        [request addRequestHeader:@"Vary" value:@"Accept-Encoding"];
        [request addRequestHeader:@"X-Powered-By" value:@"Express"];
        
        [request addRequestHeader:@"snapIndex" value:[NSString stringWithFormat:@"%d", (int)index]];
        
        [request startAsynchronous];
        
        ASINetworkQueue *queueUserLike = [[ASINetworkQueue alloc] init];
        queueUserLike.delegate = self;
        [queueUserLike setQueueDidFinishSelector:@selector(queueUserLikeDidFinished:)];
        NSInteger countL = _arrLikes.count;
        if (countL > 4) {
            countL = 4;
        }
        for (NSInteger j=1; j<countL; j++) {
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/users/%@", urlReal, [[_arrLikes objectAtIndex:j] objectForKey:@"createdBy"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            
            __weak typeof(ASIHTTPRequest *) weakSelf = request;
            
            [request setCompletionBlock:^{
                [self requestUserLikeDidFinish:weakSelf];
            }];
            
            [request setFailedBlock:^{
                [self requestUserLikeDidFail:weakSelf];
            }];
            
//            [request setDidFinishSelector:@selector(requestUserLikeDidFinish:)];
//            [request setDidFailSelector:@selector(requestUserLikeDidFail:)];
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
            
            [request addRequestHeader:@"snapIndex" value:[NSString stringWithFormat:@"%d", (int)index]];
            
            [queueUserLike addOperation:request];
        }
        
        if (queueUserLike.operationCount > 0) {
            [queueUserLike go];
        }
    }
    
    if (_isOpenRightSide) {
        NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithDictionary:[_arrTrends objectAtIndex:_currentIndex]];
        if ([[item allKeys] containsObject:@"restData"]) {
            UIViewController *controller = [viewControllerArray objectAtIndex:_currentIndex];
            if ([controller isKindOfClass:[NSNull class]]) return;
            MxoDoubleSidedView *vGr = (MxoDoubleSidedView *)[controller.view viewWithTag:1111 + _currentIndex];
            if (doubleSide) {
                vGr = doubleSide;
            }
            if (vGr) {
                UIView *vFront = [[vGr frontSubviews] objectAtIndex:0];
                [(UIButton *)[vFront viewWithTag:2] setTitle:[[[_arrTrends objectAtIndex:_currentIndex] objectForKey:@"restData"] objectForKey:@"name"] forState:UIControlStateNormal];
            }
        }
    }
    else{
        NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithDictionary:[_arrNews objectAtIndex:_currentIndex]];
        if ([[item allKeys] containsObject:@"restData"]) {
            UIViewController *controller = [viewControllerArray objectAtIndex:_currentIndex];
            if ([controller isKindOfClass:[NSNull class]]) return;
            MxoDoubleSidedView *vGr = (MxoDoubleSidedView *)[controller.view viewWithTag:1111 + _currentIndex];
            if (doubleSide) {
                vGr = doubleSide;
            }
            if (vGr) {
                UIView *vFront = [[vGr frontSubviews] objectAtIndex:0];
                [(UIButton *)[vFront viewWithTag:2] setTitle:[[[_arrNews objectAtIndex:_currentIndex] objectForKey:@"restData"] objectForKey:@"name"] forState:UIControlStateNormal];
            }
        }
    }
    
    if (_isOpenRightSide) {
        NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithDictionary:[_arrTrends objectAtIndex:_currentIndex]];
        if ([[item allKeys] containsObject:@"dishData"]) {
            UIViewController *controller = [viewControllerArray objectAtIndex:_currentIndex];
            if ([controller isKindOfClass:[NSNull class]]) return;
            MxoDoubleSidedView *vGr = (MxoDoubleSidedView *)[controller.view viewWithTag:1111 + _currentIndex];
            if (doubleSide) {
                vGr = doubleSide;
            }
            if (vGr) {
                UIView *vFront = [[vGr frontSubviews] objectAtIndex:0];
                [(UILabel *)[vFront viewWithTag:1] setText:[[[_arrTrends objectAtIndex:_currentIndex] objectForKey:@"dishData"] objectForKey:@"name"]];
            }
        }
    }
    else{
        NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithDictionary:[_arrNews objectAtIndex:_currentIndex]];
        if ([[item allKeys] containsObject:@"dishData"]) {
            UIViewController *controller = [viewControllerArray objectAtIndex:_currentIndex];
            if ([controller isKindOfClass:[NSNull class]]) return;
            MxoDoubleSidedView *vGr = (MxoDoubleSidedView *)[controller.view viewWithTag:1111 + _currentIndex];
            if (doubleSide) {
                vGr = doubleSide;
            }
            if (vGr) {
                UIView *vFront = [[vGr frontSubviews] objectAtIndex:0];
                [(UILabel *)[vFront viewWithTag:1] setText:[[[_arrNews objectAtIndex:_currentIndex] objectForKey:@"dishData"] objectForKey:@"name"]];
            }
        }
    }
    
    NSInteger countTotalLike = 0;
    
    if ([[itemData allKeys] containsObject:@"likeData"]) {
        countTotalLike = [[itemData objectForKey:@"likeData"] count];
        if ([[itemData objectForKey:@"likeData"] count] == 0) {
            countTotalLike = 0;
        }
    }
    else{
        countTotalLike = 0;
    }
    
    if (countTotalLike > 0) {
        UIViewController *controller = [viewControllerArray objectAtIndex:_currentIndex];
        if ([controller isKindOfClass:[NSNull class]]) return;
        MxoDoubleSidedView *vGr = (MxoDoubleSidedView *)[controller.view viewWithTag:1111 + _currentIndex];
        if (doubleSide) {
            vGr = doubleSide;
        }
        if (vGr) {
            UIView *vFront = [[vGr frontSubviews] objectAtIndex:0];
            
            float posY = 265 + 73;
            if (!IS_IPHONE5) {
                posY = 245 + 60;
            }
            
            UIButton *imvHeart = [[UIButton alloc] initWithFrame:CGRectMake(35, posY, 23, 22)];
            [imvHeart setImage:[UIImage imageNamed:@"big_heart.png"] forState:UIControlStateNormal];
            imvHeart.tag = 9;
            [vFront addSubview:imvHeart];
            
            UILabel *countLike = [[UILabel alloc] initWithFrame:CGRectMake(66, posY, 51, 22)];
            countLike.backgroundColor = [UIColor clearColor];
            [countLike setTextColor:[UIColor colorWithRed:96.0/255 green:99.0/255 blue:102.0/255 alpha:1.0]];
            [countLike setFont:[UIFont fontWithName:@"Roboto-Light" size:24.0]];
            countLike.text = [NSString stringWithFormat:@"%d", (int)countTotalLike];
            countLike.tag = 10;
            [vFront addSubview:countLike];
            
            UILabel *namesLike = [[UILabel alloc] initWithFrame:CGRectMake(20, posY + 57, 249, 20)];
            namesLike.backgroundColor = [UIColor clearColor];
            [namesLike setTextColor:[UIColor colorWithRed:96.0/255 green:99.0/255 blue:102.0/255 alpha:1.0]];
            [namesLike setFont:[UIFont fontWithName:@"Roboto-Regular" size:9.0]];
            namesLike.text = @"";
            namesLike.tag = 11;
            [vFront addSubview:namesLike];
            
            UIImageView *imvLikePerson1 = [[UIImageView alloc] initWithFrame:CGRectMake(20, posY + 35, 20, 20)];
            imvLikePerson1.backgroundColor = [UIColor clearColor];
            imvLikePerson1.layer.cornerRadius = 10.0;
            imvLikePerson1.tag = 12;
            [vFront addSubview:imvLikePerson1];
            
            UIImageView *imvLikePerson2 = [[UIImageView alloc] initWithFrame:CGRectMake(45, posY + 35, 20, 20)];
            imvLikePerson2.backgroundColor = [UIColor clearColor];
            imvLikePerson2.layer.cornerRadius= 10.0;
            imvLikePerson2.tag = 13;
            [vFront addSubview:imvLikePerson2];
            
            UIImageView *imvLikePerson3 = [[UIImageView alloc] initWithFrame:CGRectMake(70, posY + 35, 20, 20)];
            imvLikePerson3.backgroundColor = [UIColor clearColor];
            imvLikePerson3.layer.cornerRadius= 10.0;
            imvLikePerson3.tag = 14;
            [vFront addSubview:imvLikePerson3];
            
            UIImageView *imvLikePersonMore = [[UIImageView alloc] initWithFrame:CGRectMake(97, posY + 35 + 8, 15, 4)];
            imvLikePersonMore.image = [UIImage imageNamed:@"3dot.png"];
            imvLikePersonMore.tag = 15;
            [vFront addSubview:imvLikePersonMore];
            
            SAFE_RELEASE_ARRAY(_arrLikes);
            _arrLikes = [[NSMutableArray alloc] initWithArray:[itemData objectForKey:@"likeData"]];
            
            BOOL flagMyHadLiked = NO;
            for (int j=0; j<_arrLikes.count; j++) {
                if ([[[_arrLikes objectAtIndex:j] objectForKey:@"createdBy"] isEqualToString:[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] objectForKey:@"_id"]]) {
                    flagMyHadLiked = YES;
                    break;
                }
            }
            
            if (!flagMyHadLiked) {
                [imvHeart setImage:[UIImage imageNamed:@"heart.png"] forState:UIControlStateNormal];
                [imvHeart addTarget:self action:@selector(likeDish:) forControlEvents:UIControlEventTouchUpInside];
            }
            else{
                [imvHeart setImage:[UIImage imageNamed:@"big_heart.png"] forState:UIControlStateNormal];
                [imvHeart addTarget:self action:@selector(unlikeDish:) forControlEvents:UIControlEventTouchUpInside];
            }
            
            if (countTotalLike == 1) {
                imvLikePerson2.hidden = YES;
                imvLikePerson3.hidden = YES;
                imvLikePersonMore.hidden = YES;
            }
            else if (countTotalLike == 2) {
                imvLikePerson2.hidden = NO;
                imvLikePerson3.hidden = YES;
                imvLikePersonMore.hidden = YES;
            }
            else if (countTotalLike == 3) {
                imvLikePerson2.hidden = NO;
                imvLikePerson3.hidden = NO;
                imvLikePersonMore.hidden = YES;
            }
            else if (countTotalLike > 3) {
                imvLikePerson2.hidden = NO;
                imvLikePerson3.hidden = NO;
                imvLikePersonMore.hidden = NO;
            }
        }
    }
}

- (UIViewController *) controllerAtIndex:(NSInteger) index {
    if (index > viewControllerArray.count || index < 0) return nil;
    id res = [viewControllerArray objectAtIndex:index];
    if (res == [NSNull null]) {
        UIViewController *contr = [[UIViewController alloc] init];
        contr.view.frame = CGRectMake(0, 44.0 + addIOS7, 320.0, self.detailView.frame.size.height);
        
        MxoDoubleSidedView *vGr = [[MxoDoubleSidedView alloc] initWithFrame:CGRectMake(22, 0, (320.0 - 44.0), self.detailView.frame.size.height)];
        vGr.backgroundColor = [UIColor whiteColor];
        vGr.tag = 1111 + index;
        [_scrollList addSubview:vGr];
        
        
        NSMutableDictionary *itemData = nil;
        if (_isOpenRightSide) {
            itemData = [_arrTrends objectAtIndex:index];
            
        }
        else{
            itemData = [_arrNews objectAtIndex:index];
        }
        
        _currentItemDishData = itemData;
        NSInteger countTotalLike = 0;
        
        if ([[_currentItemDishData allKeys] containsObject:@"likeData"]) {
            countTotalLike = [[_currentItemDishData objectForKey:@"likeData"] count];
            if ([[_currentItemDishData objectForKey:@"likeData"] count] == 0) {
                countTotalLike = 0;
            }
        }
        else{
            countTotalLike = 0;
        }
        
        UIView *vFront = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (320.0 - 44.0), self.detailView.frame.size.height)];
        vFront.backgroundColor = [UIColor whiteColor];
        [vGr addFrontSubview:vFront];
        
        UIImageView *imvDetail = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 276, 245)];
        imvDetail.image = [UIImage imageWithContentsOfFile:[pathDir stringByAppendingPathComponent:[[[itemData objectForKey:@"image"] componentsSeparatedByString:@"/"] lastObject]]];
        imvDetail.contentMode = UIViewContentModeScaleAspectFit;
        [vFront addSubview:imvDetail];
        
        float posY = 265;
        if (!IS_IPHONE5) {
            posY = 245;
        }
        
        UILabel *lblDish = [[UILabel alloc] initWithFrame:CGRectMake(20, posY, 236, 30)];
        lblDish.backgroundColor = [UIColor clearColor];
        [lblDish setTextColor:[UIColor colorWithRed:96.0/255 green:99.0/255 blue:102.0/255 alpha:1.0]];
        [lblDish setFont:[UIFont fontWithName:@"Roboto-Light" size:20.0]];
        lblDish.text = @"Dish Name";
        if ([[itemData allKeys] containsObject:@"dishData"]) {
            lblDish.text = [[itemData objectForKey:@"dishData"] objectForKey:@"name"];
        }
        lblDish.lineBreakMode = NSLineBreakByTruncatingTail;
        lblDish.tag = 1;
        [vFront addSubview:lblDish];
        
        UIButton *btnRestaurantName = [[UIButton alloc] initWithFrame:CGRectMake(20, posY + 25, 249, 30)];
        btnRestaurantName.backgroundColor = [UIColor clearColor];
        [btnRestaurantName setTitleColor:[UIColor colorWithRed:202.0/255 green:193.0/255 blue:191.0/255 alpha:1.0] forState:UIControlStateNormal];
        [btnRestaurantName.titleLabel setFont:[UIFont fontWithName:@"Roboto-Light" size:24.0]];
        [btnRestaurantName setTitle:@"Restaurant" forState:UIControlStateNormal];
        if ([[itemData allKeys] containsObject:@"restData"]) {
            [btnRestaurantName setTitle:[[itemData objectForKey:@"restData"] objectForKey:@"name"] forState:UIControlStateNormal];
        }
        btnRestaurantName.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [btnRestaurantName addTarget:self action:@selector(flipCardToBack:) forControlEvents:UIControlEventTouchUpInside];
        btnRestaurantName.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        btnRestaurantName.tag = 2;
        [vFront addSubview:btnRestaurantName];
        
        if (countTotalLike > 0) {
            
            posY = 265 + 73;
            if (!IS_IPHONE5) {
                posY = 245 + 60;
            }
            
            [[vFront viewWithTag:9] removeFromSuperview];
            [[vFront viewWithTag:10] removeFromSuperview];
            [[vFront viewWithTag:11] removeFromSuperview];
            [[vFront viewWithTag:12] removeFromSuperview];
            [[vFront viewWithTag:13] removeFromSuperview];
            [[vFront viewWithTag:14] removeFromSuperview];
            [[vFront viewWithTag:15] removeFromSuperview];
            [[vFront viewWithTag:16] removeFromSuperview];
            
            UIButton *imvHeart = [[UIButton alloc] initWithFrame:CGRectMake(35, posY, 23, 22)];
            [imvHeart setImage:[UIImage imageNamed:@"big_heart.png"] forState:UIControlStateNormal];
            imvHeart.tag = 9;
            [vFront addSubview:imvHeart];
            
            UILabel *countLike = [[UILabel alloc] initWithFrame:CGRectMake(66, posY, 51, 22)];
            countLike.backgroundColor = [UIColor clearColor];
            [countLike setTextColor:[UIColor colorWithRed:96.0/255 green:99.0/255 blue:102.0/255 alpha:1.0]];
            [countLike setFont:[UIFont fontWithName:@"Roboto-Light" size:24.0]];
            countLike.text = [NSString stringWithFormat:@"%d", (int)countTotalLike];
            countLike.tag = 10;
            [vFront addSubview:countLike];
            
            UILabel *namesLike = [[UILabel alloc] initWithFrame:CGRectMake(20, posY + 57, 249, 20)];
            namesLike.backgroundColor = [UIColor clearColor];
            [namesLike setTextColor:[UIColor colorWithRed:96.0/255 green:99.0/255 blue:102.0/255 alpha:1.0]];
            [namesLike setFont:[UIFont fontWithName:@"Roboto-Regular" size:9.0]];
            namesLike.text = @"";
            namesLike.tag = 11;
            [vFront addSubview:namesLike];
            
            UIImageView *imvLikePerson1 = [[UIImageView alloc] initWithFrame:CGRectMake(20, posY + 35, 20, 20)];
            imvLikePerson1.backgroundColor = [UIColor clearColor];
            imvLikePerson1.layer.cornerRadius = 10.0;
            imvLikePerson1.tag = 12;
            [vFront addSubview:imvLikePerson1];
            
            UIImageView *imvLikePerson2 = [[UIImageView alloc] initWithFrame:CGRectMake(45, posY + 35, 20, 20)];
            imvLikePerson2.backgroundColor = [UIColor clearColor];
            imvLikePerson2.layer.cornerRadius= 10.0;
            imvLikePerson2.tag = 13;
            [vFront addSubview:imvLikePerson2];
            
            UIImageView *imvLikePerson3 = [[UIImageView alloc] initWithFrame:CGRectMake(70, posY + 35, 20, 20)];
            imvLikePerson3.backgroundColor = [UIColor clearColor];
            imvLikePerson3.layer.cornerRadius= 10.0;
            imvLikePerson3.tag = 14;
            [vFront addSubview:imvLikePerson3];
            
            UIImageView *imvLikePersonMore = [[UIImageView alloc] initWithFrame:CGRectMake(97, posY + 35 + 8, 15, 4)];
            imvLikePersonMore.image = [UIImage imageNamed:@"3dot.png"];
            imvLikePersonMore.tag = 15;
            [vFront addSubview:imvLikePersonMore];
            
            SAFE_RELEASE_ARRAY(_arrLikes);
            _arrLikes = [[NSMutableArray alloc] initWithArray:[itemData objectForKey:@"likeData"]];
            
            BOOL flagMyHadLiked = NO;
            for (int j=0; j<_arrLikes.count; j++) {
                if ([[[_arrLikes objectAtIndex:j] objectForKey:@"createdBy"] isEqualToString:[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] objectForKey:@"_id"]]) {
                    flagMyHadLiked = YES;
                    break;
                }
            }
            
            if (!flagMyHadLiked) {
                [imvHeart setImage:[UIImage imageNamed:@"heart.png"] forState:UIControlStateNormal];
                [imvHeart addTarget:self action:@selector(likeDish:) forControlEvents:UIControlEventTouchUpInside];
            }
            else{
                [imvHeart setImage:[UIImage imageNamed:@"big_heart.png"] forState:UIControlStateNormal];
                [imvHeart addTarget:self action:@selector(unlikeDish:) forControlEvents:UIControlEventTouchUpInside];
            }
            
//            _flagWillLoadData = YES;
            [_timerDownloadData invalidate];
            _timerDownloadData = nil;
            _timerDownloadData = [NSTimer scheduledTimerWithTimeInterval:0.75 target:self selector:@selector(delayLoadData:) userInfo:[NSNumber numberWithInt:(int)_currentIndex] repeats:NO];
            
            if (countTotalLike == 1) {
                imvLikePerson2.hidden = YES;
                imvLikePerson3.hidden = YES;
                imvLikePersonMore.hidden = YES;
            }
            else if (countTotalLike == 2) {
                imvLikePerson2.hidden = NO;
                imvLikePerson3.hidden = YES;
                imvLikePersonMore.hidden = YES;
            }
            else if (countTotalLike == 3) {
                imvLikePerson2.hidden = NO;
                imvLikePerson3.hidden = NO;
                imvLikePersonMore.hidden = YES;
            }
            else if (countTotalLike > 3) {
                imvLikePerson2.hidden = NO;
                imvLikePerson3.hidden = NO;
                imvLikePersonMore.hidden = NO;
            }
        }
        else {
            float posY = 265 + 73;
            if (!IS_IPHONE5) {
                posY = 245 + 60;
            }
            
            UIButton *imvHeart = [[UIButton alloc] initWithFrame:CGRectMake(35, posY, 23, 22)];
            [imvHeart setImage:[UIImage imageNamed:@"heart.png"] forState:UIControlStateNormal];
            imvHeart.tag = 9;
            [imvHeart addTarget:self action:@selector(likeDish:) forControlEvents:UIControlEventTouchUpInside];
            [vFront addSubview:imvHeart];
        }
        
        
        UILabel *uploadedBy = [[UILabel alloc] initWithFrame:CGRectMake(20, vFront.frame.size.height - 20, 249, 20)];
        uploadedBy.backgroundColor = [UIColor clearColor];
        [uploadedBy setTextColor:[UIColor colorWithRed:202.0/255 green:193.0/255 blue:191.0/255 alpha:1.0]];
        [uploadedBy setFont:[UIFont fontWithName:@"Roboto-Regular" size:9.0]];
        uploadedBy.text = @"Uploaded on July 13th, 2014";
        uploadedBy.text = [NSString stringWithFormat:@"Uploaded on %@", [itemData objectForKey:@"createdAt"]];
        uploadedBy.textAlignment = NSTextAlignmentRight;
        [vFront addSubview:uploadedBy];
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd"];
        [df setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[itemData objectForKey:@"createdAt"] longLongValue]/1000];
        
        [df setDateFormat:@"MMMM dd ### yyyy"];
        uploadedBy.text = [[df stringFromDate:date] stringByReplacingOccurrencesOfString:@"###" withString:@","];
        
        NSCalendar *calender = [NSCalendar currentCalendar];
        [calender setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
        NSDateComponents *dateComponent = [calender components:(NSWeekOfYearCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
        
        if (dateComponent.day == 1 || dateComponent.day == 21 || dateComponent.day == 31 || dateComponent.day == 2 || dateComponent.day == 22 || dateComponent.day == 3 || dateComponent.day == 23) {
            uploadedBy.text = [uploadedBy.text stringByReplacingOccurrencesOfString:@" 1 " withString:@" 1st "];
            uploadedBy.text = [uploadedBy.text stringByReplacingOccurrencesOfString:@" 21 " withString:@" 21st "];
            uploadedBy.text = [uploadedBy.text stringByReplacingOccurrencesOfString:@" 31 " withString:@" 31st "];
            
            uploadedBy.text = [uploadedBy.text stringByReplacingOccurrencesOfString:@" 2 " withString:@" 2nd "];
            uploadedBy.text = [uploadedBy.text stringByReplacingOccurrencesOfString:@" 22 " withString:@" 22nd "];
            
            uploadedBy.text = [uploadedBy.text stringByReplacingOccurrencesOfString:@" 3 " withString:@" 3rd "];
            uploadedBy.text = [uploadedBy.text stringByReplacingOccurrencesOfString:@" 23 " withString:@" 23rd "];
        }
        else{
            uploadedBy.text = [uploadedBy.text stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@" %02d ", (int)dateComponent.day] withString:[NSString stringWithFormat:@" %02dth ", (int)dateComponent.day]];
        }
        
        uploadedBy.text = [NSString stringWithFormat:@"Uploaded on %@", uploadedBy.text];
        
        [contr.view addSubview:vGr];
        
        [viewControllerArray replaceObjectAtIndex:index withObject:contr];
        return contr;
    }
    return res;
}

-(void)queueDidFinish:(ASINetworkQueue *)queue{
    if (queue.operations.count > 0) {
        [queue go];
    }
}

-(void)queueDishDidFinish:(ASINetworkQueue *)queue{
    if (queue.operations.count > 0) {
        [queue go];
    }
}

-(void)queueLikesDidFinish:(ASINetworkQueue *)queue{
    if (queue.operations.count > 0) {
        [queue go];
    }
}

-(void)requestRestaurantDidFinish:(ASIHTTPRequest *)request{
    NSString *theJSON = [request responseString];
//    NSLog(@"requestRestaurantDidFinish:%@", theJSON);
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    
    NSDictionary *restData = [[parser objectWithString:theJSON] objectForKey:@"data"];
    
    for (int i=0; i<_arrNews.count; i++) {
        NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithDictionary:[_arrNews objectAtIndex:i]];
        if ([[item allKeys] containsObject:@"restaurant"]) {
            if ([[item objectForKey:@"restaurant"] isEqualToString:[restData objectForKey:@"_id"]]) {
                [item setObject:restData forKey:@"restData"];
                [_arrNews replaceObjectAtIndex:i withObject:item];
                
                FACellDish *cell = (FACellDish *)[_leftCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                cell.subLabel.text = [[[_arrNews objectAtIndex:i] objectForKey:@"restData"] objectForKey:@"name"];
                
            }
        }
    }
    
    for (int i=0; i<_arrTrends.count; i++) {
        NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithDictionary:[_arrTrends objectAtIndex:i]];
        if ([[item allKeys] containsObject:@"restaurant"]) {
            if ([[item objectForKey:@"restaurant"] isEqualToString:[restData objectForKey:@"_id"]]) {
                [item setObject:restData forKey:@"restData"];
                [_arrTrends replaceObjectAtIndex:i withObject:item];
                
                FACellDish *cell = (FACellDish *)[_rightCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                cell.subLabel.text = [[[_arrTrends objectAtIndex:i] objectForKey:@"restData"] objectForKey:@"name"];
            }
        }
    }
    
    for (int i=0; i<_arrGallerySearch.count; i++) {
        NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithDictionary:[_arrGallerySearch objectAtIndex:i]];
        if ([[item allKeys] containsObject:@"restaurant"]) {
            if ([[item objectForKey:@"restaurant"] isEqualToString:[restData objectForKey:@"_id"]]) {
                [item setObject:restData forKey:@"restData"];
                [_arrGallerySearch replaceObjectAtIndex:i withObject:item];
                
            }
        }
    }
    
    if (_isOpenRightSide) {
        NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithDictionary:[_arrTrends objectAtIndex:_currentIndex]];
        if ([[item allKeys] containsObject:@"restData"]) {
            UIViewController *controller = [viewControllerArray objectAtIndex:_currentIndex];
            if ([controller isKindOfClass:[NSNull class]]) return;
            MxoDoubleSidedView *vGr = (MxoDoubleSidedView *)[controller.view viewWithTag:1111 + _currentIndex];
            if (doubleSide) {
                vGr = doubleSide;
            }
            if (vGr) {
                UIView *vFront = [[vGr frontSubviews] objectAtIndex:0];
                [(UIButton *)[vFront viewWithTag:2] setTitle:[[[_arrTrends objectAtIndex:_currentIndex] objectForKey:@"restData"] objectForKey:@"name"] forState:UIControlStateNormal];
            }
        }
    }
    else{
        NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithDictionary:[_arrNews objectAtIndex:_currentIndex]];
        if ([[item allKeys] containsObject:@"restData"]) {
            UIViewController *controller = [viewControllerArray objectAtIndex:_currentIndex];
            if ([controller isKindOfClass:[NSNull class]]) return;
            MxoDoubleSidedView *vGr = (MxoDoubleSidedView *)[controller.view viewWithTag:1111 + _currentIndex];
            if (doubleSide) {
                vGr = doubleSide;
            }
            if (vGr) {
                UIView *vFront = [[vGr frontSubviews] objectAtIndex:0];
                [(UIButton *)[vFront viewWithTag:2] setTitle:[[[_arrNews objectAtIndex:_currentIndex] objectForKey:@"restData"] objectForKey:@"name"] forState:UIControlStateNormal];
            }
        }
    }
    
    
}

-(void)requestRestaurantDidFail:(ASIHTTPRequest *)request{
    NSString *theJSON = [request responseString];
    NSLog(@"requestRestaurantDidFail:%@", theJSON);
    
    [self checkAndLogout401:request.responseStatusCode];
}

-(void)requestDishDidFinish:(ASIHTTPRequest *)request{
    NSString *theJSON = [request responseString];
//    NSLog(@"requestDishDidFinish:%@", theJSON);
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    
    NSDictionary *dishData = [[parser objectWithString:theJSON] objectForKey:@"data"];
    
    for (int i=0; i<_arrNews.count; i++) {
        NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithDictionary:[_arrNews objectAtIndex:i]];
        if ([[item allKeys] containsObject:@"dish"]) {
            if ([[item objectForKey:@"dish"] isEqualToString:[dishData objectForKey:@"_id"]]) {
                [item setObject:dishData forKey:@"dishData"];
                [_arrNews replaceObjectAtIndex:i withObject:item];
                
                FACellDish *cell = (FACellDish *)[_leftCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                cell.label.text = [[[_arrNews objectAtIndex:i] objectForKey:@"dishData"] objectForKey:@"name"];
            }
        }
    }

    for (int i=0; i<_arrTrends.count; i++) {
        NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithDictionary:[_arrTrends objectAtIndex:i]];
        if ([[item allKeys] containsObject:@"dish"]) {
            if ([[item objectForKey:@"dish"] isEqualToString:[dishData objectForKey:@"_id"]]) {
                [item setObject:dishData forKey:@"dishData"];
                [_arrTrends replaceObjectAtIndex:i withObject:item];
                
                FACellDish *cell = (FACellDish *)[_rightCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                cell.label.text = [[[_arrTrends objectAtIndex:i] objectForKey:@"dishData"] objectForKey:@"name"];
            }
        }
    }
    
    
    for (int i=0; i<_arrGallerySearch.count; i++) {
        NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithDictionary:[_arrGallerySearch objectAtIndex:i]];
        if ([[item allKeys] containsObject:@"dish"]) {
            if ([[item objectForKey:@"dish"] isEqualToString:[dishData objectForKey:@"_id"]]) {
                [item setObject:dishData forKey:@"dishData"];
                [_arrGallerySearch replaceObjectAtIndex:i withObject:item];
            }
        }
    }
    
    if (_isOpenRightSide) {
        NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithDictionary:[_arrTrends objectAtIndex:_currentIndex]];
        if ([[item allKeys] containsObject:@"dishData"]) {
            UIViewController *controller = [viewControllerArray objectAtIndex:_currentIndex];
            if ([controller isKindOfClass:[NSNull class]]) return;
            MxoDoubleSidedView *vGr = (MxoDoubleSidedView *)[controller.view viewWithTag:1111 + _currentIndex];
            if (doubleSide) {
                vGr = doubleSide;
            }
            if (vGr) {
                UIView *vFront = [[vGr frontSubviews] objectAtIndex:0];
                [(UILabel *)[vFront viewWithTag:1] setText:[[[_arrTrends objectAtIndex:_currentIndex] objectForKey:@"dishData"] objectForKey:@"name"]];
            }
        }
    }
    else{
        NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithDictionary:[_arrNews objectAtIndex:_currentIndex]];
        if ([[item allKeys] containsObject:@"dishData"]) {
            UIViewController *controller = [viewControllerArray objectAtIndex:_currentIndex];
            if ([controller isKindOfClass:[NSNull class]]) return;
            MxoDoubleSidedView *vGr = (MxoDoubleSidedView *)[controller.view viewWithTag:1111 + _currentIndex];
            if (doubleSide) {
                vGr = doubleSide;
            }
            if (vGr) {
                UIView *vFront = [[vGr frontSubviews] objectAtIndex:0];
                [(UILabel *)[vFront viewWithTag:1] setText:[[[_arrNews objectAtIndex:_currentIndex] objectForKey:@"dishData"] objectForKey:@"name"]];
            }
        }
    }
}

-(void)requestDishDidFail:(ASIHTTPRequest *)request{
    NSString *theJSON = [request responseString];
    NSLog(@"requestDishDidFail:%@", theJSON);
    
    [self checkAndLogout401:request.responseStatusCode];
}

-(void)requestLoadLikeDidFinish:(ASIHTTPRequest *)request{
    NSString *theJSON = [request responseString];
//    NSLog(@"requestLoadLikeDidFinish:%@", theJSON);
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    
    NSMutableArray *likeData = [[parser objectWithString:theJSON] objectForKey:@"data"];
    NSString *_id = [[[[NSString stringWithFormat:@"%@", [request url]] stringByReplacingOccurrencesOfString:@"/likes" withString:@""] componentsSeparatedByString:@"/"] lastObject];
    
    for (NSInteger i=likeData.count-1; i>=0; i--) {
        if (![[[likeData objectAtIndex:i] allKeys] containsObject:@"createdBy"]) {
            [likeData removeObjectAtIndex:i];
        }
    }
    
    for (NSInteger i=0; i<_arrNews.count; i++) {
        NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithDictionary:[_arrNews objectAtIndex:i]];
        if ([[item objectForKey:@"_id"] isEqualToString:_id] && likeData) {
            [item setObject:likeData forKey:@"likeData"];
            [_arrNews replaceObjectAtIndex:i withObject:item];
            
            FACellDish *cell = (FACellDish *)[_leftCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            
            cell.heartImage.hidden = NO;
            cell.countLikeLabel.hidden = NO;
            cell.countLikeLabel.text = [NSString stringWithFormat:@"%d", (int)[[[_arrNews objectAtIndex:i] objectForKey:@"likeData"] count]];
            
            if ([[[_arrNews objectAtIndex:i] objectForKey:@"likeData"] count] == 0) {
                cell.countLikeLabel.hidden = YES;
                cell.heartImage.hidden = YES;
            }
            
            BOOL _flagHaveMyLike = NO;
            NSMutableArray *tmp = [[_arrNews objectAtIndex:i] objectForKey:@"likeData"];
            for (int i=0; i < tmp.count; i++) {
                if ([[[tmp objectAtIndex:i] objectForKey:@"createdBy"] isEqualToString:[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] objectForKey:@"_id"]]) {
                    _flagHaveMyLike = YES;
                    break;
                }
            }
            
            if (_flagHaveMyLike) {
                cell.heartImage.image = [UIImage imageNamed:@"big_heart.png"];
            }
            else{
                cell.heartImage.image = [UIImage imageNamed:@"heart.png"];
            }
        }
    }
    
    for (int i=0; i<_arrTrends.count; i++) {
        
        NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithDictionary:[_arrTrends objectAtIndex:i]];
        if ([[item objectForKey:@"_id"] isEqualToString:_id] && likeData) {
            [item setObject:likeData forKey:@"likeData"];
            [_arrTrends replaceObjectAtIndex:i withObject:item];
            
            FACellDish *cell = (FACellDish *)[_rightCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            
            cell.heartImage.hidden = NO;
            cell.countLikeLabel.hidden = NO;
            cell.countLikeLabel.text = [NSString stringWithFormat:@"%d", (int)[[[_arrTrends objectAtIndex:i] objectForKey:@"likeData"] count]];
            
            if ([[[_arrTrends objectAtIndex:i] objectForKey:@"likeData"] count] == 0) {
                cell.countLikeLabel.hidden = YES;
                cell.heartImage.hidden = YES;
            }
            
            BOOL _flagHaveMyLike = NO;
            NSMutableArray *tmp = [[_arrTrends objectAtIndex:i] objectForKey:@"likeData"];
            for (int i=0; i < tmp.count; i++) {
                if ([[[tmp objectAtIndex:i] objectForKey:@"createdBy"] isEqualToString:[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] objectForKey:@"_id"]]) {
                    _flagHaveMyLike = YES;
                    break;
                }
            }
            
            if (_flagHaveMyLike) {
                cell.heartImage.image = [UIImage imageNamed:@"big_heart.png"];
            }
            else{
                cell.heartImage.image = [UIImage imageNamed:@"heart.png"];
            }
        }
    }
    
    for (int i=0; i<_arrGallerySearch.count; i++) {
        NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithDictionary:[_arrGallerySearch objectAtIndex:i]];
        if ([[item objectForKey:@"_id"] isEqualToString:_id] && likeData) {
            [item setObject:likeData forKey:@"likeData"];
            [_arrGallerySearch replaceObjectAtIndex:i withObject:item];
        }
    }
    
    NSMutableDictionary *itemData = nil;
    if (_isOpenRightSide) {
        itemData = [_arrTrends objectAtIndex:_currentIndex];
        
    }
    else{
        itemData = [_arrNews objectAtIndex:_currentIndex];
    }
    
    NSInteger countTotalLike = 0;
    
    if ([[itemData allKeys] containsObject:@"likeData"]) {
        countTotalLike = [[itemData objectForKey:@"likeData"] count];
        if ([[itemData objectForKey:@"likeData"] count] == 0) {
            countTotalLike = 0;
        }
    }
    else{
        countTotalLike = 0;
    }
    
    if (countTotalLike > 0) {
        UIViewController *controller = [viewControllerArray objectAtIndex:_currentIndex];
        if ([controller isKindOfClass:[NSNull class]]) return;
        MxoDoubleSidedView *vGr = (MxoDoubleSidedView *)[controller.view viewWithTag:1111 + _currentIndex];
        if (doubleSide) {
            vGr = doubleSide;
        }
        if (vGr) {
            UIView *vFront = [[vGr frontSubviews] objectAtIndex:0];
            if ([vFront viewWithTag:10]) {

                ((UILabel *)[vFront viewWithTag:10]).text = [NSString stringWithFormat:@"%d", (int)countTotalLike];
                
                
//                UIImageView *imvLikePerson1 = (UIImageView *)[vFront viewWithTag:12];
                UIImageView *imvLikePerson2 = (UIImageView *)[vFront viewWithTag:13];
                UIImageView *imvLikePerson3 = (UIImageView *)[vFront viewWithTag:14];
                UIImageView *imvLikePersonMore = (UIImageView *)[vFront viewWithTag:15];
                
                SAFE_RELEASE_ARRAY(_arrLikes);
                _arrLikes = [[NSMutableArray alloc] initWithArray:[itemData objectForKey:@"likeData"]];
                
                BOOL flagMyHadLiked = NO;
                for (int j=0; j<_arrLikes.count; j++) {
                    if ([[[_arrLikes objectAtIndex:j] objectForKey:@"createdBy"] isEqualToString:[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] objectForKey:@"_id"]]) {
                        flagMyHadLiked = YES;
                        break;
                    }
                }
                
                if (!flagMyHadLiked) {
                    [(UIButton *)[vFront viewWithTag:9] setImage:[UIImage imageNamed:@"heart.png"] forState:UIControlStateNormal];
                    [(UIButton *)[vFront viewWithTag:9] addTarget:self action:@selector(likeDish:) forControlEvents:UIControlEventTouchUpInside];
                }
                else{
                    [(UIButton *)[vFront viewWithTag:9] setImage:[UIImage imageNamed:@"big_heart.png"] forState:UIControlStateNormal];
                    [(UIButton *)[vFront viewWithTag:9] addTarget:self action:@selector(unlikeDish:) forControlEvents:UIControlEventTouchUpInside];
                }
                
                [_timerDownloadData invalidate];
                _timerDownloadData = nil;
                _timerDownloadData = [NSTimer scheduledTimerWithTimeInterval:0.75 target:self selector:@selector(delayLoadData:) userInfo:[NSNumber numberWithInt:(int)_currentIndex] repeats:NO];
                
                if (countTotalLike == 1) {
                    imvLikePerson2.hidden = YES;
                    imvLikePerson3.hidden = YES;
                    imvLikePersonMore.hidden = YES;
                }
                else if (countTotalLike == 2) {
                    imvLikePerson2.hidden = NO;
                    imvLikePerson3.hidden = YES;
                    imvLikePersonMore.hidden = YES;
                }
                else if (countTotalLike == 3) {
                    imvLikePerson2.hidden = NO;
                    imvLikePerson3.hidden = NO;
                    imvLikePersonMore.hidden = YES;
                }
                else if (countTotalLike > 3) {
                    imvLikePerson2.hidden = NO;
                    imvLikePerson3.hidden = NO;
                    imvLikePersonMore.hidden = NO;
                }
            }
            
        }
    }
}

-(void)requestLoadLikeDidFail:(ASIHTTPRequest *)request{
    NSString *theJSON = [request responseString];
    NSLog(@"requestLoadLikeDidFail:%@", theJSON);
    
    [self checkAndLogout401:request.responseStatusCode];
}

//Top bar button clicked
//Menu bar
-(void)menuBarButtonClicked{
    
    if (_resultSearchView.frame.origin.x == 0.0){
        
        self.topBarItem.leftBarButtonItem = nil;
        self.topBarItem.rightBarButtonItem = nil;
        
        
        [UIView animateWithDuration:0.35 animations:^{
            _resultSearchView.frame = CGRectMake(320, _resultSearchView.frame.origin.y, _resultSearchView.frame.size.width, _resultSearchView.frame.size.height);
        } completion:^(BOOL finished) {
            
        }];
        
        SAFE_RELEASE_ARRAY(_arrGallerySearch);
        
        return;
    }
    
    if (_arrGallerySearch && _arrGallerySearch.count > 0){
        
        self.topBarItem.rightBarButtonItem = nil;

//        [imvZoom setHidden:NO];
        
//        CGAffineTransform t = CGAffineTransformMakeScale(1.0, 1.0);
        
        [UIView animateWithDuration:0.35 animations:^{
            _resultSearchView.frame = CGRectMake(0, _resultSearchView.frame.origin.y, 320, _resultSearchView.frame.size.height);
            
//            imvZoom.transform = t;
//            imvZoom.center = remPoint;
            self.detailView.alpha = 0.0;
            self.searchView.alpha = 1.0;
            
            self.cameraButton.alpha = 1.0;
            
        } completion:^(BOOL finished) {
            
//            imvZoom.hidden = YES;
//            
//            [_arrGallerySearch removeObjectAtIndex:0];
//            
//            [_searchGalleryView removeImageAtIndex:0 animated:YES];
//            [_searchGalleryView layoutSubviews];
//            
//            if (_searchGalleryView.imageViews.count == 0) {
//                SAFE_RELEASE_VIEW(_searchGalleryView);
//            }
//            
//            if (_arrGallerySearch.count > 0) {
//            }
//            else{
//                _lblSearchDishName.text = @"Oops, you reach the end! Try something else";
//                _lblSearchDishName.adjustsFontSizeToFitWidth = YES;
//            }
            
            
        }];
        
        return;
    }
    
    if (_flagGotoDetailOnNotMatch){
        _flagGotoDetailOnNotMatch = NO;
        self.topBarItem.leftBarButtonItem = nil;
        self.topBarItem.rightBarButtonItem = nil;
        
      
        [UIView animateWithDuration:0.35 animations:^{
            self.searchView.frame = CGRectMake(0, self.searchView.frame.origin.y, 320, self.searchView.frame.size.height);
            
            self.detailView.alpha = 0.0;
            self.searchView.alpha = 1.0;
            
            self.cameraButton.alpha = 1.0;
            
        } completion:^(BOOL finished) {
            
//            _currentIndex++;
//            
//            [_galleryView removeImageAtIndex:0 animated:YES];
//            [_galleryView layoutSubviews];
//            
//            if (_galleryView.imageViews.count == 0) {
//                SAFE_RELEASE_VIEW(_galleryView);
//                _lblResultSearch.center = self.view.center;
//                _lblResultSearch.text = @"Oops, you have reached the end. Please try searching for something else!";
//            }
        }];
        
        return;
    }
    
    _flagGotoDetailOnHaveMatch = NO;
    
    if (self.searchView.frame.origin.x == 0.0){
        if (self.detailView.alpha == 1.0) {
            
            UIBarButtonItem *itemLeft = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_icon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(menuBarButtonClicked)];
            [itemLeft setTintColor:[UIColor whiteColor]];
            self.topBarItem.leftBarButtonItem = itemLeft;
            
            
            UIBarButtonItem *itemRight = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search_bar.png"] style:UIBarButtonItemStylePlain target:self action:@selector(searchBarButtonClicked)];
            [itemRight setTintColor:[UIColor whiteColor]];
            self.topBarItem.rightBarButtonItem = itemRight;
            
            if (isIOS7) {
                [itemLeft setTintColor:[UIColor colorWithRed:120.0/255 green:120.0/255 blue:120.0/255 alpha:1.0]];
                [itemRight setTintColor:[UIColor colorWithRed:120.0/255 green:120.0/255 blue:120.0/255 alpha:1.0]];
            }
            
            [UIView animateWithDuration:0.35 animations:^{
                self.searchView.frame = CGRectMake(320, self.searchView.frame.origin.y, self.searchView.frame.size.width, self.searchView.frame.size.height);
            } completion:^(BOOL finished) {
                
            }];
            
        }
        else{
            [self searchBarButtonClicked];
        }
        
        return;
    }
    
    if (self.detailView.alpha == 1.0){
        SAFE_RELEASE_ARRAY(tmpArrData);
        
        UIBarButtonItem *itemLeft = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu.png"] style:UIBarButtonItemStylePlain target:self action:@selector(menuBarButtonClicked)];
        [itemLeft setTintColor:[UIColor whiteColor]];
        self.topBarItem.leftBarButtonItem = itemLeft;
        if (isIOS7) {
            [itemLeft setTintColor:[UIColor colorWithRed:120.0/255 green:120.0/255 blue:120.0/255 alpha:1.0]];
        }
        
        
        
        NSInteger index = _currentIndex;
        
        if (_isOpenRightSide) {
            _isLoadingMore = YES;
            
            [UIView animateWithDuration:0.0 animations:^{
                [_rightCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
            } completion:^(BOOL finished) {
                imvZoom.image = [UIImage imageWithContentsOfFile:[pathDir stringByAppendingPathComponent:[[[[_arrTrends objectAtIndex:index] objectForKey:@"image"] componentsSeparatedByString:@"/"] lastObject]]];
                
                FACellDish *cell = (FACellDish *)[_rightCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
                CGRect frame = CGRectMake(cell.image.frame.origin.x,
                                          cell.frame.origin.y  - _rightCollectionView.contentOffset.y,
                                          imvZoom.frame.size.width,
                                          imvZoom.frame.size.height);
                
                remPoint = CGPointMake(_rightCollectionView.frame.origin.x + 4 + cell.image.frame.size.width/2, frame.origin.y + self.contentView.frame.origin.y  + cell.image.frame.size.height/2);
                
                [imvZoom setHidden:NO];
                
                CGAffineTransform t = CGAffineTransformMakeScale(1.0, 1.0);
                
                [UIView animateWithDuration:0.35 animations:^{
                    self.contentView.frame = CGRectMake(0, self.contentView.frame.origin.y, self.contentView.frame.size.width, self.contentView.frame.size.height);
                    
                    imvZoom.transform = t;
                    imvZoom.center = remPoint;
                    self.detailView.alpha = 0.0;
                    
                    self.cameraButton.alpha = 1.0;
                    
                } completion:^(BOOL finished) {
                    SAFE_RELEASE_VIEW(_scrollList);
                    imvZoom.hidden = YES;
                    _isLoadingMore = NO;
                }];
            }];
            
            
            
            
        }
        else{
            _isLoadingMore = YES;
            
            [UIView animateWithDuration:0.0 animations:^{
                [_leftCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
            } completion:^(BOOL finished) {
                imvZoom.image = [UIImage imageWithContentsOfFile:[pathDir stringByAppendingPathComponent:[[[[_arrNews objectAtIndex:index] objectForKey:@"image"] componentsSeparatedByString:@"/"] lastObject]]];
                
                FACellDish *cell = (FACellDish *)[_leftCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
                CGRect frame = CGRectMake(cell.image.frame.origin.x,
                                          cell.frame.origin.y  - _leftCollectionView.contentOffset.y,
                                          imvZoom.frame.size.width,
                                          imvZoom.frame.size.height);
                
                remPoint = CGPointMake(_leftCollectionView.frame.origin.x + 4 + cell.image.frame.size.width/2, frame.origin.y + self.contentView.frame.origin.y  + cell.image.frame.size.height/2);
                
                [imvZoom setHidden:NO];
                
                CGAffineTransform t = CGAffineTransformMakeScale(1.0, 1.0);
                
                [UIView animateWithDuration:0.35 animations:^{
                    self.contentView.frame = CGRectMake(0, self.contentView.frame.origin.y, self.contentView.frame.size.width, self.contentView.frame.size.height);
                    
                    imvZoom.transform = t;
                    imvZoom.center = remPoint;
                    self.detailView.alpha = 0.0;
                    
                    self.cameraButton.alpha = 1.0;
                    
                } completion:^(BOOL finished) {
                    SAFE_RELEASE_VIEW(_scrollList);
                    imvZoom.hidden = YES;
                    _isLoadingMore = NO;
                }];
            }];
            
//            [_leftCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
//            
//            imvZoom.image = [UIImage imageWithContentsOfFile:[pathDir stringByAppendingPathComponent:[[[[_arrNews objectAtIndex:index] objectForKey:@"image"] componentsSeparatedByString:@"/"] lastObject]]];
//            
//            FACellDish *cell = (FACellDish *)[_leftCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
//            CGRect frame = CGRectMake(cell.image.frame.origin.x,
//                                      cell.frame.origin.y  - _leftCollectionView.contentOffset.y,
//                                      imvZoom.frame.size.width,
//                                      imvZoom.frame.size.height);
//            
//            remPoint = CGPointMake(_leftCollectionView.frame.origin.x + 4, frame.origin.y + self.contentView.frame.origin.y );
            
            
        }
        
        
        
        
        return;
    }
    
    [UIView animateWithDuration:0.35 animations:^{
        if (self.menuView.frame.origin.y == 64.0) {
            self.menuView.frame = CGRectMake(0, -120.0, self.menuView.frame.size.width, self.menuView.frame.size.height);
        }
        else{
            self.menuView.frame = CGRectMake(0, 64.0, self.menuView.frame.size.width, self.menuView.frame.size.height);
        }
        
    } completion:^(BOOL finished) {
        
    }];
}
//Search bar
-(void)searchBarButtonClicked{
    if (self.menuView.frame.origin.y == 64.0) return;
    
    [self.searchBar resignFirstResponder];
    [self.view findAndResignFirstResponder];
    
    _topBarItem.titleView = nil;
    
    if (self.searchView.frame.origin.x == 320.0) {
        self.topBarItem.leftBarButtonItem = nil;
        self.topBarItem.rightBarButtonItem = nil;
    }
    else{
        if (self.detailView.alpha == 0.0) {
            UIBarButtonItem *itemLeft = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu.png"] style:UIBarButtonItemStylePlain target:self action:@selector(menuBarButtonClicked)];
            [itemLeft setTintColor:[UIColor whiteColor]];
            self.topBarItem.leftBarButtonItem = itemLeft;
            
            
            UIBarButtonItem *itemRight = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search_bar.png"] style:UIBarButtonItemStylePlain target:self action:@selector(searchBarButtonClicked)];
            [itemRight setTintColor:[UIColor whiteColor]];
            self.topBarItem.rightBarButtonItem = itemRight;
            
            if (isIOS7) {
                [itemLeft setTintColor:[UIColor colorWithRed:120.0/255 green:120.0/255 blue:120.0/255 alpha:1.0]];
                [itemRight setTintColor:[UIColor colorWithRed:120.0/255 green:120.0/255 blue:120.0/255 alpha:1.0]];
            }
        }
        else if (self.detailView.alpha == 1.0 && !_flagGotoDetailOnHaveMatch && !_flagGotoDetailOnNotMatch) {
            UIBarButtonItem *itemLeft = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_icon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(menuBarButtonClicked)];
            [itemLeft setTintColor:[UIColor whiteColor]];
            self.topBarItem.leftBarButtonItem = itemLeft;
            
            
            UIBarButtonItem *itemRight = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search_bar.png"] style:UIBarButtonItemStylePlain target:self action:@selector(searchBarButtonClicked)];
            [itemRight setTintColor:[UIColor whiteColor]];
            self.topBarItem.rightBarButtonItem = itemRight;
            
            if (isIOS7) {
                [itemLeft setTintColor:[UIColor colorWithRed:120.0/255 green:120.0/255 blue:120.0/255 alpha:1.0]];
                [itemRight setTintColor:[UIColor colorWithRed:120.0/255 green:120.0/255 blue:120.0/255 alpha:1.0]];
            }
        }
        else{
            UIBarButtonItem *itemLeft = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_icon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(menuBarButtonClicked)];
            [itemLeft setTintColor:[UIColor whiteColor]];
            self.topBarItem.leftBarButtonItem = itemLeft;
            
            if (isIOS7) {
                [itemLeft setTintColor:[UIColor colorWithRed:120.0/255 green:120.0/255 blue:120.0/255 alpha:1.0]];
            }
        }
    }
    
    BOOL flag = NO;
    if (self.searchView.frame.origin.x == 320.0) {
        flag = YES;
    }
    else{
        if (self.detailView.alpha == 0.0) {
        }
        else if (self.detailView.alpha == 1.0 && !_flagGotoDetailOnHaveMatch && !_flagGotoDetailOnNotMatch) {
        }
        else {
            flag = YES;
        }
    }
    
    [UIView animateWithDuration:0.35 animations:^{
        if (self.searchView.frame.origin.x == 320.0) {
            self.contentView.frame = CGRectMake(-320, self.contentView.frame.origin.y, self.contentView.frame.size.width, self.contentView.frame.size.height);
            self.searchView.frame = CGRectMake(0, self.searchView.frame.origin.y, self.searchView.frame.size.width, self.searchView.frame.size.height);
        }
        else{
            
            if (self.detailView.alpha == 0.0) {
                self.contentView.frame = CGRectMake(0, self.contentView.frame.origin.y, self.contentView.frame.size.width, self.contentView.frame.size.height);
                self.searchView.frame = CGRectMake(320, self.searchView.frame.origin.y, self.searchView.frame.size.width, self.searchView.frame.size.height);
                self.cameraButton.alpha = 1.0;
            }
            else if (self.detailView.alpha == 1.0 && !_flagGotoDetailOnHaveMatch && !_flagGotoDetailOnNotMatch) {
                self.searchView.frame = CGRectMake(320, self.searchView.frame.origin.y, self.searchView.frame.size.width, self.searchView.frame.size.height);
            }
            else {
                self.searchView.alpha = 1.0;
                _txtSearchField.text = @"";
                [arrSearch removeAllObjects];
                [_tblSearch reloadData];
                
                [_arrGallerySearch removeAllObjects];
                SAFE_RELEASE_VIEW(_searchGalleryView);
                
                SAFE_RELEASE_VIEW(_galleryView);
                _lblResultSearch.hidden = YES;
                
                self.topBarItem.leftBarButtonItem = nil;
                self.topBarItem.rightBarButtonItem = nil;
                
                self.searchView.frame = CGRectMake(0, self.searchView.frame.origin.y, self.searchView.frame.size.width, self.searchView.frame.size.height);
                self.detailView.alpha = 0.0;
                _resultSearchView.frame = CGRectMake(320, _resultSearchView.frame.origin.y, _resultSearchView.frame.size.width, _resultSearchView.frame.size.height);
            }
            
        }
        
    } completion:^(BOOL finished) {
        if (flag) {
//            [self.searchBar becomeFirstResponder];
        }
    }];
}

-(void)loadDataAgainWhenUploaded:(NSNotification *)not{
    
    _insertSnapData = [[NSMutableDictionary alloc] initWithDictionary:not.object];
    _isInsertNewDish = YES;
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (_isInsertNewDish) {
        _isLoadingMore = YES;
        
        [_arrNews insertObject:_insertSnapData atIndex:0];
        
        if ([[_insertSnapData allKeys] containsObject:@"restaurant"]) {
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/restaurants/%@", urlReal, [_insertSnapData objectForKey:@"restaurant"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            
            __weak typeof(ASIHTTPRequest *) weakSelf = request;
            
            [request setCompletionBlock:^{
                [self requestRestaurantDidFinish:weakSelf];
            }];
            
            [request setFailedBlock:^{
                [self requestRestaurantDidFail:weakSelf];
            }];
            
//            [request setDidFinishSelector:@selector(requestRestaurantDidFinish:)];
//            [request setDidFailSelector:@selector(requestRestaurantDidFail:)];
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
        if ([[_insertSnapData allKeys] containsObject:@"dish"]) {
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/dishes/%@", urlReal, [_insertSnapData objectForKey:@"dish"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            
            __weak typeof(ASIHTTPRequest *) weakSelf = request;
            
            [request setCompletionBlock:^{
                [self requestDishDidFinish:weakSelf];
            }];
            
            [request setFailedBlock:^{
                [self requestDishDidFail:weakSelf];
            }];
            
//            [request setDidFinishSelector:@selector(requestDishDidFinish:)];
//            [request setDidFailSelector:@selector(requestDishDidFail:)];
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
        
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/snaps/%@/likes", urlReal, [_insertSnapData objectForKey:@"_id"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        
        __weak typeof(ASIHTTPRequest *) weakSelf = request;
        
        [request setCompletionBlock:^{
            [self requestLoadLikeDidFinish:weakSelf];
        }];
        
        [request setFailedBlock:^{
            [self requestLoadLikeDidFail:weakSelf];
        }];
        
//        [request setDidFinishSelector:@selector(requestLoadLikeDidFinish:)];
//        [request setDidFailSelector:@selector(requestLoadLikeDidFail:)];
//        request.delegate = self;
        
        
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
        
        [_leftCollectionView reloadData];
        [_leftCollectionView setContentOffset:CGPointMake(0, 0) animated:NO];
        
        _isLoadingMore = NO;
    }
    
    
    [self.view bringSubviewToFront:self.cameraButton];
    [self.view bringSubviewToFront:self.menuView];
    [self.view bringSubviewToFront:self.searchView];
    [self.view bringSubviewToFront:self.statusBarOverlay];
    [self.view bringSubviewToFront:self.topNavBar];
    
    //Configure data source arrays
    NSString* leftPlistPath = [[NSBundle mainBundle] pathForResource:@"LeftCityList"
                                                              ofType:@"plist"];
    self.leftColumnData = [NSArray arrayWithContentsOfFile: leftPlistPath];
    
    
    NSString* rightPlistPath = [[NSBundle mainBundle] pathForResource:@"RightCityList"
                                                               ofType:@"plist"];
    self.rightColumnData = [NSArray arrayWithContentsOfFile: rightPlistPath];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    [UIView animateWithDuration:0.25 delay:0.75 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _vShowTrending.alpha = 0.0;
        _vShowNew.alpha = 0.0;
    } completion:^(BOOL finished) {
    }];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView == _scrollList) {
//        float offset = _scrollList.contentOffset.x;
//        if (offset >= _currentContentOffset) {
//            if (offset == 0 && offset == _currentContentOffset && _currentIndex == 0) return;
//            
//            _currentContentOffset = offset;
//            if (_isOpenRightSide) {
//                if (_currentIndex == _arrTrends.count-2) {
//                    _currentIndex++;
//                    return;
//                }
//            }
//            else {
//                if (_currentIndex == _arrNews.count-2) {
//                    _currentIndex++;
//                    return;
//                }
//            }
//            _currentIndex++;
//            if (_isOpenRightSide) {
//                if (_currentIndex >= _arrTrends.count) {
//                    _currentIndex = _arrTrends.count - 1;
//                    return;
//                }
//            }
//            else{
//                if (_currentIndex >= _arrNews.count) {
//                    _currentIndex = _arrNews.count - 1;
//                    return;
//                }
//            }
//        }
//        else{
//            if (_currentIndex == 0) return;
//            _currentIndex--;
//        }
//        
//        if (_isOpenRightSide) {
//            _currentItemDishData = [_arrTrends objectAtIndex:_currentIndex];
//        }
//        else{
//            _currentItemDishData = [_arrNews objectAtIndex:_currentIndex];
//        }
//        
//        [[_scrollList subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
//        
//        if (_currentIndex == 0) {
//            [self loadItemAtIndex:_currentIndex];
//            [self loadItemAtIndex:_currentIndex+1];
//            [self loadItemAtIndex:_currentIndex+2];
//        }
//        else if (_currentIndex == _arrTrends.count-1) {
//            [self loadItemAtIndex:_currentIndex-2];
//            [self loadItemAtIndex:_currentIndex-1];
//            [self loadItemAtIndex:_currentIndex];
//        }
//        else{
//            [self loadItemAtIndex:_currentIndex-1];
//            [self loadItemAtIndex:_currentIndex];
//            [self loadItemAtIndex:_currentIndex+1];
//        }
    }
    else{
        if (scrollView == _leftCollectionView) {
            NSInteger index = _leftCollectionView.contentOffset.y / 207.0;
            if ((int)_leftCollectionView.contentOffset.y % 207 > 0) {
                [_leftCollectionView setContentOffset:CGPointMake(0, (index+1) * 207.0) animated:YES];
            }
            
        }
        else if (scrollView == _rightCollectionView) {
            NSInteger index = _rightCollectionView.contentOffset.y / 207.0;
            if ((int)_rightCollectionView.contentOffset.y % 207 > 0) {
                [_rightCollectionView setContentOffset:CGPointMake(0, (index+1) * 207.0) animated:YES];
                
            }
        }
        
        [UIView animateWithDuration:0.25 delay:0.75 options:UIViewAnimationOptionCurveEaseOut animations:^{
            _vShowTrending.alpha = 0.0;
            _vShowNew.alpha = 0.0;
        } completion:^(BOOL finished) {
        }];
    }
}

- (void)lazyScrollViewDidEndDecelerating:(DMLazyScrollView *)pagingView atPageIndex:(NSInteger)pageIndex{
    _currentIndex = pageIndex;
    
    [_timerDownloadData invalidate];
    _timerDownloadData = nil;
    
    _timerDownloadData = [NSTimer scheduledTimerWithTimeInterval:0.75 target:self selector:@selector(delayLoadData:) userInfo:[NSNumber numberWithInteger:_currentIndex] repeats:NO];
}

-(void)showHUDOnMainThread{
    if ([[MBProgressHUD allHUDsForView:[kApplicationDelegate window]] count] == 0) {
        [MBProgressHUD showHUDAddedTo:[kApplicationDelegate window] animated:NO];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == _tblSearch) {
        CGFloat scrollPosition = scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y;
        if (scrollPosition < 40.0 && !_isLoadingMore) {
            _isLoadingMore = YES;
            _currentPageIndexAutoComplete++;
            
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/dishes/autocomplete?[{\"$input\":\"%@\"},{\"limit\":500,\"page\":%d}]", urlReal, _txtSearchField.text, (int)_currentPageIndexAutoComplete] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            
            __weak typeof(ASIHTTPRequest *) weakSelf = request;
            
            [request setCompletionBlock:^{
                [self requestAutoCompleteDidFinish:weakSelf];
            }];
            
            [request setFailedBlock:^{
                [self requestAutoCompleteDidFail:weakSelf];
            }];
            
//            [request setDidFinishSelector:@selector(requestAutoCompleteDidFinish:)];
//            [request setDidFailSelector:@selector(requestAutoCompleteDidFail:)];
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
    else if(scrollView == _scrollList){
        _flagWillLoadData = NO;
    }
    else if(scrollView == _leftCollectionView){
        _vShowNew.alpha = 1.0;
        [UIView animateWithDuration:1.0 animations:^{
            _vShowNew.alpha = 0.0;
        }];
        
        _lastScrollPosition = _currentScrollPosition;
        _currentScrollPosition = [scrollView contentOffset];
        
//        NSLog(@"_leftCollectionView.contentOffset.y:%f, %f, %d", _leftCollectionView.contentOffset.y, _leftCollectionView.contentSize.height - 207.0*4, _isLoadingMore);
        
        if (_leftCollectionView.contentOffset.y > 0 && _leftCollectionView.contentOffset.y >= _leftCollectionView.contentSize.height - 207.0*4 - 3 && !_isLoadingMore && _arrNews.count > 0)
        {
            
            //LOAD MORE
            _isLoadingMore = YES;
            [_leftCollectionView setContentOffset:CGPointMake(0, (_arrNews.count-5)*207.0) animated:NO];
//            [_leftCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_arrNews.count-5 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
            _leftCollectionView.scrollEnabled = NO;
            [self performSelectorOnMainThread:@selector(showHUDOnMainThread) withObject:nil waitUntilDone:YES];
            
            
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/snaps/new?[{\"lat\":%f,\"lng\":%f}, {\"page\":%d}]", urlReal, [LocationManager locationManager].currentLocation.coordinate.latitude, [LocationManager locationManager].currentLocation.coordinate.longitude, (int)currentSnapNewsPageIndex+1] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            
            __weak typeof(ASIHTTPRequest *) weakSelf = request;
            
            [request setCompletionBlock:^{
                [self requestNewsDidFinish:weakSelf];
            }];
            
            [request setFailedBlock:^{
                [self requestNewsDidFail:weakSelf];
            }];
            
//            [request setDidFinishSelector:@selector(requestNewsDidFinish:)];
//            [request setDidFailSelector:@selector(requestNewsDidFail:)];
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
    else if(scrollView == _rightCollectionView){
        _vShowTrending.alpha = 1.0;
        [UIView animateWithDuration:1.0 animations:^{
            _vShowTrending.alpha = 0.0;
        }];
        
        _lastScrollPosition = _currentScrollPosition;
        _currentScrollPosition = [scrollView contentOffset];
        
        if (_rightCollectionView.contentOffset.y >= _rightCollectionView.contentSize.height - 207.0*4 - 3 && !_isLoadingMore && _arrTrends.count > 0)
        {
            //LOAD MORE
            
            _isLoadingMore = YES;
            [_rightCollectionView setContentOffset:CGPointMake(0, (_arrTrends.count-5)*207.0) animated:NO];
//            [_rightCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_arrTrends.count-5 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
            _rightCollectionView.scrollEnabled = NO;
            [self performSelectorOnMainThread:@selector(showHUDOnMainThread) withObject:nil waitUntilDone:YES];
            
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/snaps/trending?[{\"lat\":%f,\"lng\":%f}, {\"page\":%d}]", urlReal, [LocationManager locationManager].currentLocation.coordinate.latitude, [LocationManager locationManager].currentLocation.coordinate.longitude, (int)currentSnapTrendingPageIndex+1] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            
            __weak typeof(ASIHTTPRequest *) weakSelf = request;
            
            [request setCompletionBlock:^{
                [self requestTrendingDidFinish:weakSelf];
            }];
            
            [request setFailedBlock:^{
                [self requestTrendingDidFail:weakSelf];
            }];
            
//            [request setDidFinishSelector:@selector(requestTrendingDidFinish:)];
//            [request setDidFailSelector:@selector(requestTrendingDidFail:)];
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

-(void)requestData{
    
    ASIHTTPRequest *requestN = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/snaps/new?[{\"lat\":%f,\"lng\":%f}, {\"page\":%d}]", urlReal, [LocationManager locationManager].currentLocation.coordinate.latitude, [LocationManager locationManager].currentLocation.coordinate.longitude, 1] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];

    __weak typeof(ASIHTTPRequest *) weakSelf1 = requestN;
    
    [requestN setCompletionBlock:^{
        [self requestDataDidFinish:weakSelf1];
    }];
    
    [requestN setFailedBlock:^{
        [self requestDataDidFail:weakSelf1];
    }];
    
//    [requestN setDidFinishSelector:@selector(requestDataDidFinish:)];
//    [requestN setDidFailSelector:@selector(requestDataDidFail:)];
//    requestN.delegate = self;
    
    [requestN setRequestMethod:@"GET"];
    [requestN addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    
    [requestN setUseCookiePersistence:NO];
    [requestN setUseSessionPersistence:NO];
    
    if (cookie) {
        [requestN setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
    }
    
    [requestN addRequestHeader:@"Vary" value:@"Accept-Encoding"];
    [requestN addRequestHeader:@"X-Powered-By" value:@"Express"];
    [requestN startAsynchronous];
}

-(void) viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"path:%@", pathDir);
    
    _isInsertNewDish = NO;
    _isOpenMap = NO;
    _isOpeningDetail = NO;
    
    currentSnapNewsPageIndex = 0;
    currentSnapTrendingPageIndex = 0;
    
    _isLoadingMore = YES;
    
    _timerSchedule = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(requestData) userInfo:nil repeats:YES];
    
    [MBProgressHUD showHUDAddedTo:[kApplicationDelegate window] animated:YES];
    
    [self.topNavBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [self.topNavBar setBackgroundColor:[UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1.0]];
    
    UIBarButtonItem *itemLeft = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu.png"] style:UIBarButtonItemStylePlain target:self action:@selector(menuBarButtonClicked)];
    [itemLeft setTintColor:[UIColor whiteColor]];
    self.topBarItem.leftBarButtonItem = itemLeft;
    
    UIBarButtonItem *itemRight = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search_bar.png"] style:UIBarButtonItemStylePlain target:self action:@selector(searchBarButtonClicked)];
    [itemRight setTintColor:[UIColor whiteColor]];
    self.topBarItem.rightBarButtonItem = itemRight;
    
    if (isIOS7) {
        [itemLeft setTintColor:[UIColor colorWithRed:120.0/255 green:120.0/255 blue:120.0/255 alpha:1.0]];
        [itemRight setTintColor:[UIColor colorWithRed:120.0/255 green:120.0/255 blue:120.0/255 alpha:1.0]];
    }
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                           UITextAttributeTextColor: [UIColor colorWithRed:96.0/255.0 green:99.0/255.0 blue:102.0/255.0 alpha:1.0],
                                                           UITextAttributeFont: [UIFont fontWithName:@"MyriadPro-Regular" size:20.0],
                                                           UITextAttributeTextShadowColor: [UIColor clearColor],
                                                           }];
//    self.topBarItem.title = @"Food Print";
    
    
//    UIPinchGestureRecognizer *pinchOut = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchOutGesture:)];
//    [self.detailView addGestureRecognizer:pinchOut];
    
    self.imvRate1.layer.cornerRadius = self.imvRate1.frame.size.width/2;
    self.imvRate2.layer.cornerRadius = self.imvRate2.frame.size.width/2;
    self.imvRate3.layer.cornerRadius = self.imvRate3.frame.size.width/2;
    
    self.btnMenu1.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.btnMenu1.titleEdgeInsets = UIEdgeInsetsMake(0, 30, 0, 0);
    CALayer *sublayer = [CALayer layer];
    sublayer.backgroundColor = [UIColor colorWithRed:200.0/255 green:200.0/255 blue:200.0/255 alpha:1.0].CGColor;
    sublayer.frame = CGRectMake(0, self.btnMenu1.frame.size.height - 1, self.btnMenu1.frame.size.width, 1);
    [self.btnMenu1.layer addSublayer:sublayer];
    
    self.btnMenu2.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.btnMenu2.titleEdgeInsets = UIEdgeInsetsMake(0, 30, 0, 0);
    sublayer = [CALayer layer];
    sublayer.backgroundColor = [UIColor colorWithRed:200.0/255 green:200.0/255 blue:200.0/255 alpha:1.0].CGColor;
    sublayer.frame = CGRectMake(0, self.btnMenu2.frame.size.height - 1, self.btnMenu2.frame.size.width, 1);
    [self.btnMenu2.layer addSublayer:sublayer];
    
    self.btnMenu3.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.btnMenu3.titleEdgeInsets = UIEdgeInsetsMake(0, 30, 0, 0);
    sublayer = [CALayer layer];
    sublayer.backgroundColor = [UIColor colorWithRed:200.0/255 green:200.0/255 blue:200.0/255 alpha:1.0].CGColor;
    sublayer.frame = CGRectMake(0, self.btnMenu3.frame.size.height - 1, self.btnMenu3.frame.size.width, 1);
    [self.btnMenu3.layer addSublayer:sublayer];
    
    
    
    _lblResultSearch = [[UILabel alloc] initWithFrame:CGRectMake(20, 44.0, 280, 44.0)];
    _lblResultSearch.backgroundColor = [UIColor clearColor];
    _lblResultSearch.textColor = [UIColor colorWithRed:64.0/255 green:64.0/255 blue:64.0/255 alpha:1.0];
    _lblResultSearch.font = [UIFont fontWithName:@"Helvetica-Light" size:14.0];
    _lblResultSearch.textAlignment = NSTextAlignmentCenter;
    _lblResultSearch.text = @"No Matches, Please explore the most recent dish posts";
    _lblResultSearch.lineBreakMode = NSLineBreakByWordWrapping;
    _lblResultSearch.numberOfLines = 2;
    _lblResultSearch.hidden = YES;
    [self.searchView addSubview:_lblResultSearch];
    
    UITapGestureRecognizer *tapOnSearchView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnSearchView)];
    tapOnSearchView.numberOfTapsRequired = 1;
    tapOnSearchView.numberOfTouchesRequired = 1;
    tapOnSearchView.delegate = self;
    [self.searchView addGestureRecognizer:tapOnSearchView];
    
    if (isIOS7) {
        for (UIView *view in [[self.searchBar.subviews objectAtIndex:0] subviews]){
            NSLog(@"view:%@", view);
            if ([view isKindOfClass: [UITextField class]]) {
                UITextField *tf = (UITextField *)view;
                tf.font = [UIFont fontWithName:@"Helvetica-Light" size:14.0];
                tf.returnKeyType = UIReturnKeySearch;
                [tf setClearButtonMode:UITextFieldViewModeNever];
                break;
            }
        }
    }
    else{
        for (UIView *view in self.searchBar.subviews){
            NSLog(@"view:%@", view);
            if ([view isKindOfClass: [UITextField class]]) {
                UITextField *tf = (UITextField *)view;
                tf.font = [UIFont fontWithName:@"Helvetica-Light" size:14.0];
                tf.returnKeyType = UIReturnKeySearch;
                [tf setClearButtonMode:UITextFieldViewModeNever];
                break;
            }
        }
    }
    
    searching = NO;
    arrSearch = [[NSMutableArray alloc] init];
//    _currentSelectedSearchType = 0;
//    [_tblSearch reloadData];
    
    _tblSearch.frame = CGRectMake(_tblSearch.frame.origin.x, _tblSearch.frame.origin.y, _tblSearch.frame.size.width, 0);
    [self.searchView bringSubviewToFront:_tblSearch];
    
    [self.lblDishName setTextColor:[UIColor colorWithRed:96.0/255 green:99.0/255 blue:102.0/255 alpha:1.0]];
    [self.lblDishName setFont:[UIFont fontWithName:@"Roboto-Light" size:20.0]];
    
    self.lblRestaurantName.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.lblRestaurantName.titleLabel setFont:[UIFont fontWithName:@"Roboto-Light" size:24.0]];
    
    [self.lblCountLike setTextColor:[UIColor colorWithRed:96.0/255 green:99.0/255 blue:102.0/255 alpha:1.0]];
    [self.lblCountLike setFont:[UIFont fontWithName:@"Roboto-Light" size:28.0]];
    
    [self.lblLike setFont:[UIFont fontWithName:@"Roboto-Regular" size:9.0]];
    [self.lblUploaded setFont:[UIFont fontWithName:@"Roboto-Regular" size:9.0]];
    [self.lblUploaded setTextColor:[UIColor colorWithRed:202.0/255 green:193.0/255 blue:191.0/255 alpha:1.0]];
    
//    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDetailToLeft)];
//    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
//    [self.detailView addGestureRecognizer:swipeLeft];
//    
//    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDetailToRight)];
//    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
//    [self.detailView addGestureRecognizer:swipeRight];
    
//    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
//    [self.detailView addGestureRecognizer:pan];
//    
//    UISwipeGestureRecognizer *swipeNext = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeNext:)];
//    swipeNext.direction = UISwipeGestureRecognizerDirectionRight;
//    [self.detailView addGestureRecognizer:swipeNext];
//    
//    UISwipeGestureRecognizer *swipePrev = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipePrev:)];
//    swipePrev.direction = UISwipeGestureRecognizerDirectionLeft;
//    [self.detailView addGestureRecognizer:swipePrev];
    
    currentSelectSearch = -1;
    
    if (isIOS7) {
        JCRBlurView *blurView = [JCRBlurView new];
        [blurView setTintColor:[UIColor whiteColor]];
        [blurView setFrame:CGRectMake(0.0f,0.0f, self.menuView.frame.size.width,self.menuView.frame.size.height)];
        blurView.alpha = 0.98;
        [self.menuView addSubview:blurView];
    }
    
    [self.menuView bringSubviewToFront:self.btnMenu1];
    [self.menuView bringSubviewToFront:self.btnMenu2];
    [self.menuView bringSubviewToFront:self.btnMenu3];
    
    [_lblSearchDishName setFont:[UIFont fontWithName:@"Roboto-Light" size:20.0]];
    
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
    
    if (![ASIHTTPRequest isNetworkReachable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Whoops! No Internet connection found. Please check your connection or try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    else{
        
        ASIHTTPRequest *request1 = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/snaps/new?[{\"lat\":%f,\"lng\":%f}, {\"page\":%d}]", urlReal, [LocationManager locationManager].currentLocation.coordinate.latitude, [LocationManager locationManager].currentLocation.coordinate.longitude, (int)currentSnapNewsPageIndex+1] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        
        __weak typeof(ASIHTTPRequest *) weakSelf1 = request1;
        
        [request1 setCompletionBlock:^{
            [self requestNewsDidFinish:weakSelf1];
        }];
        
        [request1 setFailedBlock:^{
            [self requestNewsDidFail:weakSelf1];
        }];
        
//        [requestN setDidFinishSelector:@selector(requestNewsDidFinish:)];
//        [requestN setDidFailSelector:@selector(requestNewsDidFail:)];
//        requestN.delegate = self;
        
        [request1 setRequestMethod:@"GET"];
        [request1 addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
        
        [request1 setUseCookiePersistence:NO];
        [request1 setUseSessionPersistence:NO];
        
        if (cookie) {
            [request1 setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
        }
        
        [request1 addRequestHeader:@"Vary" value:@"Accept-Encoding"];
        [request1 addRequestHeader:@"X-Powered-By" value:@"Express"];
        [request1 startAsynchronous];
        
        ASIHTTPRequest *request2 = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/snaps/trending?[{\"lat\":%f,\"lng\":%f}, {\"page\":%d}]", urlReal, [LocationManager locationManager].currentLocation.coordinate.latitude, [LocationManager locationManager].currentLocation.coordinate.longitude, (int)currentSnapTrendingPageIndex+1] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        
        __weak typeof(ASIHTTPRequest *) weakSelf2 = request2;
        
        [request2 setCompletionBlock:^{
            [self requestTrendingDidFinish:weakSelf2];
        }];
        
        [request2 setFailedBlock:^{
            [self requestTrendingDidFail:weakSelf2];
        }];
        
//        [requestT setDidFinishSelector:@selector(requestTrendingDidFinish:)];
//        [requestT setDidFailSelector:@selector(requestTrendingDidFinish:)];
//        requestT.delegate = self;
        
        [request2 setRequestMethod:@"GET"];
        [request2 addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
        
        [request2 setUseCookiePersistence:NO];
        [request2 setUseSessionPersistence:NO];
        
        if (cookie) {
            [request2 setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
        }
        
        [request2 addRequestHeader:@"Vary" value:@"Accept-Encoding"];
        [request2 addRequestHeader:@"X-Powered-By" value:@"Express"];
        [request2 startAsynchronous];
    }
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadDataAgainWhenUploaded:) name:@"loadDataAgainWhenUploaded" object:nil];
    
    UISwipeGestureRecognizer *swipeLeftGalNoMatch = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeftGalNoMatch)];
    swipeLeftGalNoMatch.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.searchView addGestureRecognizer:swipeLeftGalNoMatch];
    
    UISwipeGestureRecognizer *swipeRightGalNoMatch = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRightGalNoMatch)];
    swipeRightGalNoMatch.direction = UISwipeGestureRecognizerDirectionRight;
    [self.searchView addGestureRecognizer:swipeRightGalNoMatch];
    
    UISwipeGestureRecognizer *swipeLeftGalResult = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeftGalResult)];
    swipeLeftGalResult.direction = UISwipeGestureRecognizerDirectionLeft;
    [_resultSearchView addGestureRecognizer:swipeLeftGalResult];
    
    UISwipeGestureRecognizer *swipeRightGalResult = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRightGalResult)];
    swipeRightGalResult.direction = UISwipeGestureRecognizerDirectionRight;
    [_resultSearchView addGestureRecognizer:swipeRightGalResult];
    
    _flagGotoDetailOnNotMatch = NO;
    
    CGSize stringsize = [@"Cancel" sizeWithFont:[UIFont fontWithName:@"Roboto-Light" size:15.0]];
    
    UIButton *btnCancelSearch = [[UIButton alloc] initWithFrame:CGRectMake(320 - stringsize.width - 15, self.searchBar.frame.origin.y, stringsize.width, 44)];
    [btnCancelSearch setTitle:@"Cancel" forState:UIControlStateNormal];
    [btnCancelSearch setTitleColor:[UIColor colorWithRed:96.0/255 green:99.0/255 blue:102.0/255 alpha:1.0] forState:UIControlStateNormal];
    [btnCancelSearch setTitleColor:[UIColor colorWithRed:200.0/255 green:200.0/255 blue:200.0/255 alpha:1.0] forState:UIControlStateHighlighted];
    [btnCancelSearch addTarget:self action:@selector(cancelSearchClicked) forControlEvents:UIControlEventTouchUpInside];
    btnCancelSearch.titleLabel.font = [UIFont fontWithName:@"Roboto-Light" size:15.0];
    [self.searchView addSubview:btnCancelSearch];
    
    _txtSearchField.font = [UIFont fontWithName:@"Roboto-Light" size:15.0];
    
    _lblShowNew.font = [UIFont fontWithName:@"Roboto-Bold" size:12.0];
    _lblShowTrending.font = [UIFont fontWithName:@"Roboto-Bold" size:12.0];
    
    _isOpenRightSide = NO;
    _isLoadingMore = YES;
    
    _isOpeningDetail = NO;
}

-(void)swipeLeftGalNoMatch{
    if (_galleryView) {
        _currentIndex++;
        
        [_galleryView removeImageAtIndex2:0 animated:YES];
        [_galleryView layoutSubviews];
        
        _lblResultSearch.hidden = YES;
        
        if (_galleryView.imageViews.count == 0) {

            [self performSelector:@selector(removeGal) withObject:nil afterDelay:0.35];
            _lblResultSearch.center = CGPointMake(self.view.center.x, self.view.center.y - 40.0);
            _lblResultSearch.text = @"Oops, you have reached the end. Please try searching for something else!";
            _lblResultSearch.hidden = NO;
        }
    }
}

-(void)swipeRightGalNoMatch{
    if (_txtSearchField.text.length == 0) {
        [self menuBarButtonClicked];
        
        return;
    }
    
    if (_galleryView) {
        _currentIndex++;
        
        [_galleryView removeImageAtIndex:0 animated:YES];
        [_galleryView layoutSubviews];
        
        _lblResultSearch.hidden = YES;
        
        if (_galleryView.imageViews.count == 0) {
            [self performSelector:@selector(removeGal) withObject:nil afterDelay:0.35];
            
           _lblResultSearch.center = CGPointMake(self.view.center.x, self.view.center.y - 40.0);
            _lblResultSearch.text = @"Oops, you have reached the end. Please try searching for something else!";
            _lblResultSearch.hidden = NO;
        }
    }
    
}

-(void)removeGal{
    SAFE_RELEASE_VIEW(_galleryView);
    SAFE_RELEASE_VIEW(_searchGalleryView);
}

-(void)swipeLeftGalResult{
    if (_searchGalleryView && _arrGallerySearch.count > 0) {
        
        [_arrGallerySearch removeObjectAtIndex:0];
        
        [_searchGalleryView removeImageAtIndex2:0 animated:YES];
        [_searchGalleryView layoutSubviews];
        
        if (_searchGalleryView.imageViews.count == 0) {
            [self performSelector:@selector(removeGal) withObject:nil afterDelay:0.35];
        }
        
        if (_arrGallerySearch.count > 0) {
        }
        else{
            _lblSearchDishName.text = @"Oops, you reach the end! Try something else";
            _lblSearchDishName.adjustsFontSizeToFitWidth = YES;
        }
    }
}

-(void)swipeRightGalResult{
    if (!_searchGalleryView ||  _arrGallerySearch.count == 0 || !_arrGallerySearch) {
        [self menuBarButtonClicked];
        
        return;
    }
    
    if (_searchGalleryView) {
        
        [_arrGallerySearch removeObjectAtIndex:0];
        
        [_searchGalleryView removeImageAtIndex:0 animated:YES];
        [_searchGalleryView layoutSubviews];
        
        if (_searchGalleryView.imageViews.count == 0) {
            [self performSelector:@selector(removeGal) withObject:nil afterDelay:0.35];
        }
        
        if (_arrGallerySearch.count > 0) {
        }
        else{
            _lblSearchDishName.text = @"Oops, you reach the end! Try something else";
            _lblSearchDishName.adjustsFontSizeToFitWidth = YES;
        }
    }
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    NSLog(@"touch:%@", touch.view);
    if ([touch.view isKindOfClass:[NSClassFromString(@"UITableViewCellContentView") class]] || [touch.view isKindOfClass:[UIButton class]]) {
        if (![touch.view isKindOfClass:[UIButton class]]) {
            [self.view findAndResignFirstResponder];
        }
        
        return NO;
    }
    else if([touch.view isKindOfClass:[NSClassFromString(@"UISearchBarTextField") class]] || [touch.view isKindOfClass:[UISearchBar class]] ){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_searchBar becomeFirstResponder];
        });
        
//        [self.view findAndResignFirstResponder];
//        [self.searchBar becomeFirstResponder];
//        [self.searchBar performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.35];
        return NO;
    }
    [self.view findAndResignFirstResponder];
    
    return YES;
}

-(void)swipeDetailToLeft{
    
    CATransition *applicationLoadViewIn = [CATransition animation];
    [applicationLoadViewIn setDuration:0.4];
    [applicationLoadViewIn setType:kCATransitionPush];
    applicationLoadViewIn.subtype = kCATransitionFromRight;
    [applicationLoadViewIn setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    [self.detailView.layer addAnimation:applicationLoadViewIn forKey:kCATransitionPush];
    
    NSDictionary *itemData = nil;
    _currentSelectedItem++;
    if (_isLeft) {
        if (_currentSelectedItem == self.leftColumnData.count) {
            _currentSelectedItem = 0;
        }
        itemData = [self.leftColumnData objectAtIndex:_currentSelectedItem];
    }
    else{
        if (_currentSelectedItem == self.rightColumnData.count) {
            _currentSelectedItem = 0;
        }
        itemData = [self.rightColumnData objectAtIndex:_currentSelectedItem];
    }
    
    self.imvFull.image = [UIImage imageNamed:[itemData objectForKey:@"image"]];
    self.lblDishName.text = [itemData objectForKey:@"subtitle"];
    [self.lblRestaurantName setTitle:[itemData objectForKey:@"title"] forState:UIControlStateNormal];
    self.lblCountLike.text = [itemData objectForKey:@"countLike"];
    
    self.lblLike.text = [NSString stringWithFormat:@"Mr. A and 3 other friends like %@.", [itemData objectForKey:@"subtitle"]];
}

-(void)swipeDetailToRight{
    CATransition *applicationLoadViewIn = [CATransition animation];
    [applicationLoadViewIn setDuration:0.4];
    [applicationLoadViewIn setType:kCATransitionPush];
    applicationLoadViewIn.subtype = kCATransitionFromLeft;
    [applicationLoadViewIn setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    [self.detailView.layer addAnimation:applicationLoadViewIn forKey:kCATransitionPush];
    
    NSDictionary *itemData = nil;
    _currentSelectedItem--;
    if (_isLeft) {
        if (_currentSelectedItem < 0) {
            _currentSelectedItem = self.leftColumnData.count-1;
        }
        itemData = [self.leftColumnData objectAtIndex:_currentSelectedItem];
    }
    else{
        if (_currentSelectedItem < 0) {
            _currentSelectedItem = self.rightColumnData.count-1;
        }
        itemData = [self.rightColumnData objectAtIndex:_currentSelectedItem];
    }
    
    self.imvFull.image = [UIImage imageNamed:[itemData objectForKey:@"image"]];
    self.lblDishName.text = [itemData objectForKey:@"subtitle"];
    [self.lblRestaurantName setTitle:[itemData objectForKey:@"title"] forState:UIControlStateNormal];
    self.lblCountLike.text = [itemData objectForKey:@"countLike"];
    
    self.lblLike.text = [NSString stringWithFormat:@"Mr. A and 3 other friends like %@.", [itemData objectForKey:@"subtitle"]];
}

-(void)tapOnSearchView{
    [self.searchBar resignFirstResponder];
}

-(void)handlePinchOutGesture:(UIGestureRecognizer *)recognizer{
    CGFloat factor = [(UIPinchGestureRecognizer *) recognizer scale];
    if (factor < 1.0) {
        UIBarButtonItem *itemLeft = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu.png"] style:UIBarButtonItemStylePlain target:self action:@selector(menuBarButtonClicked)];
        [itemLeft setTintColor:[UIColor whiteColor]];
        self.topBarItem.leftBarButtonItem = itemLeft;
        if (isIOS7) {
            [itemLeft setTintColor:[UIColor colorWithRed:120.0/255 green:120.0/255 blue:120.0/255 alpha:1.0]];
        }
        
        [imvZoom setHidden:NO];
        
        CGAffineTransform t = CGAffineTransformMakeScale(1.0, 1.0);
        
        [UIView animateWithDuration:0.35 animations:^{
            self.contentView.frame = CGRectMake(0, self.contentView.frame.origin.y, self.contentView.frame.size.width, self.contentView.frame.size.height);
            
            imvZoom.transform = t;
            imvZoom.center = remPoint;
            self.detailView.alpha = 0.0;
            
            self.cameraButton.alpha = 1.0;
            
        } completion:^(BOOL finished) {
            
            imvZoom.hidden = YES;
        }];
    }
}

- (CGFloat)scrollRateForColumnAtIndex: (NSInteger) index {
    
    return 15 + index * 15;
}
-(NSInteger) numberOfColumnsInScrollSelect:(KLScrollSelect *)scrollSelect {
    return 2;
}
-(NSInteger) scrollSelect:(KLScrollSelect *)scrollSelect numberOfRowsInColumnAtIndex:(NSInteger)index {
    if (index == 0) {
        //Left column
        return self.leftColumnData.count;
    }
    //Right Column
    else return self.rightColumnData.count;
}
- (UITableViewCell*) scrollSelect:(KLScrollSelect*) scrollSelect cellForRowAtIndexPath:(KLIndexPath *)indexPath {
    KLScrollingColumn* column = [[scrollSelect columns] objectAtIndex: indexPath.column];
    KLImageCell* cell;
    
    //registerClass only works on iOS 6 so if the app runs on iOS 5 we shouldn't use this method.
    //On iOS 5 we only initialize a new KLImageCell if the cell is nil
    if (IOS_VERSION >= 6.0) {
        [column registerClass:[KLImageCell class] forCellReuseIdentifier:@"Cell" ];
        cell = [column dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:[indexPath innerIndexPath]];
    } else {
        cell = [column dequeueReusableCellWithIdentifier:@"Cell"];
        if (cell == nil) {
            cell = [[KLImageCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
        }
    }
    
    [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
    
    NSDictionary* dictForCell = indexPath.column == 0? [self.leftColumnData objectAtIndex:indexPath.row] : [self.rightColumnData objectAtIndex:indexPath.row];
    
    [cell.image setImage:[UIImage imageNamed: [dictForCell objectForKey:@"image"]]];
    [cell.label setText:[dictForCell objectForKey:@"subtitle"]];
    [cell.subLabel setText: [dictForCell objectForKey:@"title"]];
    cell.countLikeLabel.text = [dictForCell objectForKey:@"countLike"];
    
    cell.remColum = [NSNumber numberWithInt:(int)indexPath.column];
    cell.remSection = [NSNumber numberWithInt:(int)indexPath.section];
    cell.remRow = [NSNumber numberWithInt:(int)indexPath.row];
    
    cell.cellDelegate = self;
    
    return cell;
}

-(void)handlePinchInGesture:(UIGestureRecognizer *)recognizer{
    CGFloat factor = [(UIPinchGestureRecognizer *) recognizer scale];
    if (factor > 1.0) {
        
        FACellDish* cell = (FACellDish *)[recognizer view];
        
        self.imvFull.image = [cell.image image];
        
        if (!imvZoom) {
            imvZoom = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.image.frame.size.width, cell.image.frame.size.height)];
            imvZoom.contentMode = UIViewContentModeScaleAspectFit;
            [self.view addSubview:imvZoom];
        }
        imvZoom.image = [cell.image image];
        
        UICollectionViewLayoutAttributes *attributes = [_rightCollectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:[cell.remRow integerValue] inSection:0]];
        CGRect frame = CGRectMake(0.0,
                                  0.0,
                                  cell.frame.size.width,
                                  cell.frame.size.height);
        frame.origin = [cell convertPoint:cell.frame.origin
                                   toView:self.view];
        
        if ([cell.remColum integerValue] == 2) {
            imvZoom.frame = CGRectMake(_rightCollectionView.frame.origin.x + 5, frame.origin.y - attributes.center.y + 80 + addIOS7, imvZoom.frame.size.width, imvZoom.frame.size.height);
        }
        else{
            imvZoom.frame = CGRectMake(_leftCollectionView.frame.origin.x + 10, frame.origin.y - attributes.center.y + 80 + addIOS7, imvZoom.frame.size.width, imvZoom.frame.size.height);
        }
        
        
        CGAffineTransform t = CGAffineTransformMakeScale(2, 2);
        //    t = CGAffineTransformTranslate(t, -20, -64);
        
        [UIView animateWithDuration:0.5 animations:^{
            self.contentView.frame = CGRectMake(-320, self.contentView.frame.origin.y, 320, 504);
            imvZoom.transform = t;
            imvZoom.center = CGPointMake(self.imvFull.center.x + 15, self.imvFull.center.y + (44.0 + addIOS7));
            
        } completion:^(BOOL finished) {
            self.detailView.alpha = 1.0;
            
            [imvZoom setHidden:YES];
        }];
    }
}

- (void)scrollSelect:(KLScrollSelect *)tableView didSelectCellAtIndexPath:(KLIndexPath *)indexPath andRect:(CGRect)rect{
    NSLog(@"Selected cell at index %ld, %ld, %ld", (long)indexPath.column, (long)indexPath.section, (long)indexPath.row);

    NSDictionary *itemData = nil;
    if ((long)indexPath.column == 0) {
        itemData = [self.leftColumnData objectAtIndex:(long)indexPath.row];
        _isLeft = YES;
    }
    else{
        
        itemData = [self.rightColumnData objectAtIndex:(long)indexPath.row];
        _isLeft = NO;
    }
    _currentSelectedItem = indexPath.row;
    
    self.imvFull.image = [UIImage imageNamed:[itemData objectForKey:@"image"]];
    self.lblDishName.text = [itemData objectForKey:@"subtitle"];
    [self.lblRestaurantName setTitle:[itemData objectForKey:@"title"] forState:UIControlStateNormal];
    self.lblCountLike.text = [itemData objectForKey:@"countLike"];
    
    self.lblLike.text = [NSString stringWithFormat:@"Mr. A and 3 other friends like %@.", [itemData objectForKey:@"subtitle"]];
    
    self.scrollSelect.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.35 animations:^{
        self.contentView.frame = CGRectMake(-self.contentView.frame.size.width + 40, self.contentView.frame.origin.y, self.contentView.frame.size.width, self.contentView.frame.size.height);
        self.detailView.frame = CGRectMake(40, self.detailView.frame.origin.y, self.detailView.frame.size.width, self.detailView.frame.size.height);
    } completion:^(BOOL finished) {
        
    }];
}
- (CGFloat) scrollSelect: (KLScrollSelect*) scrollSelect heightForColumnAtIndex: (NSInteger) index {
    if (index == 0) {
        return 200.0;
    }
    return 300.0;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)requestLogoutDidFinish:(ASIHTTPRequest *)request{
    NSLog(@"requestLogoutDidFinish:%@", request.responseString);
    
    [MBProgressHUD hideAllHUDsForView:[kApplicationDelegate window] animated:YES];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"tempLogout"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    FBSession* session = [FBSession activeSession];
    //            [session closeAndClearTokenInformation];
    [session close];
    [FBSession setActiveSession:nil];
    
    NSHTTPCookie *cookieG;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookieG in [storage cookies])
    {
        NSString* domainName = [cookieG domain];
        NSLog(@"domain:%@, value:%@", domainName, cookieG.value);
        NSRange domainRange = [domainName rangeOfString:urlReal];
        if(domainRange.length > 0)
        {
            [storage deleteCookie:cookieG];
        }
    }
    
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"_isLoggedIn"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)requestLogoutDidFail:(ASIHTTPRequest *)request{
    NSLog(@"requestLogoutDidFail:%@", request.responseString);
    
    [MBProgressHUD hideAllHUDsForView:[kApplicationDelegate window] animated:YES];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"tempLogout"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    FBSession* session = [FBSession activeSession];
    //            [session closeAndClearTokenInformation];
    [session close];
    [FBSession setActiveSession:nil];

    
    NSHTTPCookie *cookieG;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookieG in [storage cookies])
    {
        NSString* domainName = [cookieG domain];
        NSLog(@"domain:%@, value:%@", domainName, cookieG.value);
        NSRange domainRange = [domainName rangeOfString:urlReal];
        if(domainRange.length > 0)
        {
            [storage deleteCookie:cookieG];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"_isLoggedIn"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)keyPress:(UIButton *)sender {
    if (sender == self.cameraButton) {
        FACameraViewController *cameraViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Camera"];
        [self presentViewController:cameraViewController animated:YES completion:nil];
    }
    else if (sender == self.btnMenu1) {
        [UIView animateWithDuration:0.35 animations:^{
            self.menuView.frame = CGRectMake(0, -120.0, self.menuView.frame.size.width, self.menuView.frame.size.height);
            
        } completion:^(BOOL finished) {
            FATermViewController *termView = [self.storyboard instantiateViewControllerWithIdentifier:@"Term"];
            [self presentViewController:termView animated:YES completion:^{
                
            }];
        }];
    }
    else if (sender == self.btnMenu2) {
        [UIView animateWithDuration:0.35 animations:^{
            self.menuView.frame = CGRectMake(0, -120.0, self.menuView.frame.size.width, self.menuView.frame.size.height);
            
        } completion:^(BOOL finished) {
            FAAboutViewController *aboutView = [self.storyboard instantiateViewControllerWithIdentifier:@"About"];
            [self presentViewController:aboutView animated:YES completion:^{
                
            }];
        }];
    }
    else if (sender == self.btnMenu3) {
        
        [MBProgressHUD showHUDAddedTo:[kApplicationDelegate window] animated:YES];
        
        ASIHTTPRequest *requestLogout = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/deauth", urlReal] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        
        __weak typeof(ASIHTTPRequest *) weakSelf = requestLogout;
        
        [requestLogout setCompletionBlock:^{
            [self requestLogoutDidFinish:weakSelf];
        }];
        
        [requestLogout setFailedBlock:^{
            [self requestLogoutDidFail:weakSelf];
        }];
        
//        [requestLogout setDidFinishSelector:@selector(requestLogoutDidFinish:)];
//        [requestLogout setDidFailSelector:@selector(requestLogoutDidFail:)];
//        requestLogout.delegate = self;
        
        [requestLogout setRequestMethod:@"GET"];
        [requestLogout addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
        
        [requestLogout setUseCookiePersistence:NO];
        [requestLogout setUseSessionPersistence:NO];
        
        if (cookie) {
            [requestLogout setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
        }
        
        [requestLogout addRequestHeader:@"Vary" value:@"Accept-Encoding"];
        [requestLogout addRequestHeader:@"X-Powered-By" value:@"Express"];
        [requestLogout startAsynchronous];
        
        [UIView animateWithDuration:0.35 animations:^{
            self.menuView.frame = CGRectMake(0, -120.0, self.menuView.frame.size.width, self.menuView.frame.size.height);
            
        } completion:^(BOOL finished) {
            
            
        }];
    }
    else if (sender == self.lblRestaurantName) {
        
    }
}

-(void)cancelSearchClicked{
    _flagGotoDetailOnHaveMatch = NO;
    _flagGotoDetailOnNotMatch = NO;
    
    if (_txtSearchField.text.length == 0) {
        [self.view findAndResignFirstResponder];
        [self searchBarButtonClicked];
//        [self menuBarButtonClicked];
    }
    else{
        _txtSearchField.text = @"";
        currentSelectSearch = -1;
        searching = NO;
        SAFE_RELEASE_ARRAY(arrSearch);
        arrSearch = [[NSMutableArray alloc] init];
        [_tblSearch reloadData];
        
        _lblResultSearch.hidden = YES;
        _galleryView.hidden = YES;
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    return YES;
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    if(searching)
		return;
    
    searching = YES;
//	_tblSearch.scrollEnabled = NO;
}
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    return YES;
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    
}

-(void)_sendRequestGetAuto{
    [timerInput invalidate];
    timerInput = nil;
    
    searching = YES;
    _tblSearch.scrollEnabled = YES;
    
    SAFE_RELEASE_ARRAY(arrSearch);
    
    _currentPageIndexAutoComplete = 1;
    
    if (![ASIHTTPRequest isNetworkReachable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Whoops! No Internet connection found. Please check your connection or try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    else{
        
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/dishes/autocomplete?[{\"$input\":\"%@\"},{\"limit\":500,\"page\":%d}]", urlReal, _txtSearchField.text, (int)_currentPageIndexAutoComplete] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        
        __weak typeof(ASIHTTPRequest *) weakSelf = request;
        
        [request setCompletionBlock:^{
            [self requestAutoCompleteDidFinish:weakSelf];
        }];
        
        [request setFailedBlock:^{
            [self requestAutoCompleteDidFail:weakSelf];
        }];
        
        
//        [request setDidFinishSelector:@selector(requestAutoCompleteDidFinish:)];
//        [request setDidFailSelector:@selector(requestAutoCompleteDidFail:)];
//        request.delegate = self;
        
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
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    SAFE_RELEASE_ARRAY(arrSearch);
    arrSearch = [[NSMutableArray alloc] init];
	if([searchText length] > 0) {
        
        _tblSearch.userInteractionEnabled = NO;
        
        [timerInput invalidate];
        timerInput = nil;
        
        timerInput = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(_sendRequestGetAuto) userInfo:nil repeats:NO];
        
		
	}
	else {
        currentSelectSearch = -1;
        searching = NO;
        SAFE_RELEASE_ARRAY(arrSearch);
        arrSearch = [[NSMutableArray alloc] init];
        [_tblSearch reloadData];
        
        _lblResultSearch.hidden = YES;
        _galleryView.hidden = YES;
	}
}

-(void)searchTableView{
    
    SAFE_RELEASE_ARRAY(arrSearch);
    
    _currentPageIndexAutoComplete = 1;
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/dishes/autocomplete?[{\"$input\":\"%@\"},{\"limit\":500,\"page\":%d}]", urlReal, _txtSearchField.text, (int)_currentPageIndexAutoComplete] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    __weak typeof(ASIHTTPRequest *) weakSelf = request;
    
    [request setCompletionBlock:^{
        [self requestAutoComplete2DidFinish:weakSelf];
    }];
    
    [request setFailedBlock:^{
        [self requestAutoComplete2DidFail:weakSelf];
    }];
    
//    [request setDidFinishSelector:@selector(requestAutoComplete2DidFinish:)];
//    [request setDidFailSelector:@selector(requestAutoComplete2DidFail:)];
//    request.delegate = self;
    
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


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.searchBar resignFirstResponder];
    
    [self searchTableView];
    
}

-(void)requestAutoComplete2DidFinish:(ASIHTTPRequest *)request{
    NSString *theJSON = [request responseString];
    NSLog(@"requestAutoComplete2DidFinish:%@", theJSON);
    _isLoadingMore = NO;
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    
    if (!arrSearch) {
        arrSearch = [[NSMutableArray alloc] initWithArray:[[parser objectWithString:theJSON] objectForKey:@"data"]];
    }
    else{
        NSMutableArray *tmp = [[parser objectWithString:theJSON] objectForKey:@"data"];
        if (tmp.count > 0) {
            [arrSearch addObjectsFromArray:tmp];
        }
    }
    
    
    
    _tblSearch.frame = CGRectMake(_tblSearch.frame.origin.x, _tblSearch.frame.origin.y, _tblSearch.frame.size.width, self.searchView.frame.size.height - _tblSearch.frame.origin.y);
    if (arrSearch.count > 0) {
        currentSelectSearch = 0;
    }
    [_tblSearch reloadData];
    
    if (arrSearch.count == 0) {
        
        [MBProgressHUD showHUDAddedTo:[kApplicationDelegate window] animated:YES];
        
//        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/snaps?[{},{\"page\":1,limit:50}]", urlReal] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
//        [request setDidFinishSelector:@selector(requestListSearchDishDidFinish:)];
//        [request setDidFailSelector:@selector(requestListSearchDishDidFail:)];
//        request.delegate = self;
//        [request setRequestMethod:@"GET"];
//        [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
//        
//        [request setUseCookiePersistence:NO];
//        [request setUseSessionPersistence:NO];
//        
//        if (cookie) {
//            [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
//        }
//        
//        [request addRequestHeader:@"Vary" value:@"Accept-Encoding"];
//        [request addRequestHeader:@"X-Powered-By" value:@"Express"];
//        [request startAsynchronous];
//        
//        return;
        
        _lblResultSearch.frame = CGRectMake(20, 44.0, 280, 44.0);
        _lblResultSearch.text = @"No Matches, Please explore the most recent dish posts";
        _lblResultSearch.lineBreakMode = NSLineBreakByWordWrapping;
        _lblResultSearch.numberOfLines = 2;
        _lblResultSearch.hidden = NO;
        _galleryView.hidden = NO;
        
        _tblSearch.frame = CGRectMake(_tblSearch.frame.origin.x, _tblSearch.frame.origin.y, _tblSearch.frame.size.width, 0);
        
        _currentIndex = 0;
        
        SAFE_RELEASE_VIEW(_galleryView);
        NSMutableArray *listImvs = [[NSMutableArray alloc] init];
        NSInteger count = 50;
        if (_arrNews.count < 50) {
            count = _arrNews.count;
        }
        for (NSInteger i = 0; i < count; i++) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:[pathDir stringByAppendingPathComponent:[[[[_arrNews objectAtIndex:i] objectForKey:@"image"] componentsSeparatedByString:@"/"] lastObject]]]) {
                UIImage *imv = [UIImage imageWithContentsOfFile:[pathDir stringByAppendingPathComponent:[[[[_arrNews objectAtIndex:i] objectForKey:@"image"] componentsSeparatedByString:@"/"] lastObject]]];
                [listImvs addObject:imv];
            }
            else{
                UIImage *imv = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/%@", urlReal, [[_arrNews objectAtIndex:i] objectForKey:@"image"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
                [listImvs addObject:imv];
            }
        }
        
        float posY = self.searchView.frame.size.height/2  - 60;
        if (!IS_IPHONE5) {
            posY = self.searchView.frame.size.height/2  - 35;
        }
        
        _galleryView      = [[WCGalleryView alloc] initWithImages:listImvs frame:CGRectMake(0.0f, 0.0f, 140.0f, 140.0f)];
        _galleryView.backgroundColor     = [UIColor clearColor];
        _galleryView.center = CGPointMake(self.searchView.frame.size.width/2, posY);
        _galleryView.borderColor         = [UIColor whiteColor];
        _galleryView.borderWidth         = 3.0f;
        _galleryView.shadowColor         = [UIColor blackColor];
        _galleryView.shadowOffset        = CGSizeMake(1.0f, 2.0f);
        _galleryView.shadowOpacity       = 0.5f;
        _galleryView.shadowRadius        = 2.0f;
        _galleryView.stackRadiusOffset   = 9.0f;
        _galleryView.animationDuration   = 0.3f;
        _galleryView.stackRadiusDirection = WCGalleryStackRadiusRandom;
        _galleryView.animationType        = WCGalleryAnimationFade;
        _galleryView.delegate = self;
        [self.searchView addSubview:_galleryView];
        
        [MBProgressHUD hideAllHUDsForView:[kApplicationDelegate window] animated:YES];
    }
}

-(void)requestAutoComplete2DidFail:(ASIHTTPRequest *)request{
    NSString *theJSON = [request responseString];
    NSLog(@"requestAutoComplete2DidFail:%@", theJSON);
    
    [self checkAndLogout401:request.responseStatusCode];
}

-(void)requestAutoCompleteDidFinish:(ASIHTTPRequest *)request{
    NSString *theJSON = [request responseString];
    NSLog(@"requestAutoCompleteDidFinish:%@", theJSON);
    _isLoadingMore = NO;
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    
    _tblSearch.userInteractionEnabled = YES;
    
    if (_currentPageIndexAutoComplete == 1) {
        SAFE_RELEASE_ARRAY(arrSearch);
    }
    if (!arrSearch) {
        arrSearch = [[NSMutableArray alloc] initWithArray:[[parser objectWithString:theJSON] objectForKey:@"data"]];
    }
    else{
        NSMutableArray *tmp = [[parser objectWithString:theJSON] objectForKey:@"data"];
        if (tmp.count > 0) {
            [arrSearch addObjectsFromArray:tmp];
        }
    }
    
    
    
    _tblSearch.frame = CGRectMake(_tblSearch.frame.origin.x, _tblSearch.frame.origin.y, _tblSearch.frame.size.width, self.searchView.frame.size.height - _tblSearch.frame.origin.y);
    if (arrSearch.count > 0) {
        currentSelectSearch = 0;
    }
    [_tblSearch reloadData];
    
    if (arrSearch.count == 0) {
//        _lblResultSearch.frame = CGRectMake(0, 44.0, 320, 44.0);
//        _lblResultSearch.text = @"No Matches, Please explore the most recent dish posts";
//        
//        _lblResultSearch.hidden = NO;
//        _galleryView.hidden = NO;
//        
//        _tblSearch.frame = CGRectMake(_tblSearch.frame.origin.x, _tblSearch.frame.origin.y, _tblSearch.frame.size.width, 0);
//        
//        _currentIndex = 0;
//        
//        SAFE_RELEASE_VIEW(_galleryView);
//        NSMutableArray *listImvs = [[NSMutableArray alloc] init];
//        NSInteger count = 50;
//        if (_arrNews.count < 50) {
//            count = _arrNews.count;
//        }
//        for (int i = 0; i < count; i++) {
//            UIImage *imv = [UIImage imageWithContentsOfFile:[pathDir stringByAppendingPathComponent:[[[[_arrNews objectAtIndex:i] objectForKey:@"image"] componentsSeparatedByString:@"/"] lastObject]]];
//            [listImvs addObject:imv];
//        }
//        
//        float posY = self.searchView.frame.size.height/2  - 60;
//        if (!IS_IPHONE5) {
//            posY = self.searchView.frame.size.height/2  - 35;
//        }
//        
//        _galleryView      = [[WCGalleryView alloc] initWithImages:listImvs frame:CGRectMake(0.0f, 0.0f, 140.0f, 140.0f)];
//        _galleryView.backgroundColor     = [UIColor clearColor];
//        _galleryView.center = CGPointMake(self.searchView.frame.size.width/2, posY);
//        _galleryView.borderColor         = [UIColor whiteColor];
//        _galleryView.borderWidth         = 3.0f;
//        _galleryView.shadowColor         = [UIColor blackColor];
//        _galleryView.shadowOffset        = CGSizeMake(1.0f, 2.0f);
//        _galleryView.shadowOpacity       = 0.5f;
//        _galleryView.shadowRadius        = 2.0f;
//        _galleryView.stackRadiusOffset   = 9.0f;
//        _galleryView.animationDuration   = 0.3f;
//        _galleryView.stackRadiusDirection = WCGalleryStackRadiusRandom;
//        _galleryView.animationType        = WCGalleryAnimationFade;
//        _galleryView.delegate = self;
//        [self.searchView addSubview:_galleryView];
    }
    else{
        _lblResultSearch.hidden = YES;
        _galleryView.hidden = YES;
        
        
        
        _tblSearch.frame = CGRectMake(_tblSearch.frame.origin.x, _tblSearch.frame.origin.y, _tblSearch.frame.size.width, self.searchView.frame.size.height - _tblSearch.frame.origin.y);
    }
    
}

-(void)requestAutoCompleteDidFail:(ASIHTTPRequest *)request{
    NSString *theJSON = [request responseString];
    NSLog(@"requestAutoCompleteDidFail:%@", theJSON);
    
    [self checkAndLogout401:request.responseStatusCode];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
	_txtSearchField.text = @"";
    searching = NO;
    currentSelectSearch = -1;
    SAFE_RELEASE_ARRAY(arrSearch);
    arrSearch = [[NSMutableArray alloc] init];
    
    _lblResultSearch.hidden = YES;
    _galleryView.hidden = YES;
    
    _tblSearch.frame = CGRectMake(_tblSearch.frame.origin.x, _tblSearch.frame.origin.y, _tblSearch.frame.size.width, 0);
    [_tblSearch reloadData];
    
    return NO;
}

//-(void)searchTableView{
//    searching = YES;
//    
//    _tblSearch.frame = CGRectMake(_tblSearch.frame.origin.x, _tblSearch.frame.origin.y, _tblSearch.frame.size.width, self.searchView.frame.size.height - _tblSearch.frame.origin.y);
//    [_tblSearch reloadData];
//}

#pragma  UITableViewDataSource implementation
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (searching) {
        return arrSearch.count;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (searching) {
        return 1;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    UIView *vCell = nil;
    UILabel *lblTitle;
    UILabel *lblDistance;
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        
        vCell = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tblSearch.frame.size.width, 40)];
        vCell.backgroundColor = [UIColor clearColor];
        vCell.tag = 1;
        vCell.userInteractionEnabled = NO;
        [cell.contentView addSubview:vCell];
        
        lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, _tblSearch.frame.size.width - 60, 40)];
        lblTitle.backgroundColor = [UIColor clearColor];
        lblTitle.textColor = [UIColor colorWithRed:100.0/255 green:100.0/255 blue:100.0/255 alpha:1.0];
        lblTitle.font = [UIFont systemFontOfSize:13.0];
        lblTitle.tag = 2;
        lblTitle.userInteractionEnabled = NO;
        [vCell addSubview:lblTitle];
        
        lblDistance = [[UILabel alloc] initWithFrame:CGRectMake(_tblSearch.frame.size.width - 60, 0, 50, 30)];
        lblDistance.backgroundColor = [UIColor clearColor];
        lblDistance.textColor = [UIColor colorWithRed:100.0/255 green:100.0/255 blue:100.0/255 alpha:1.0];
        lblDistance.font = [UIFont systemFontOfSize:10.0];
        lblDistance.textAlignment = NSTextAlignmentRight;
        lblDistance.tag = 3;
        [vCell addSubview:lblDistance];
    }
    
    if (!vCell) {
        vCell = [cell.contentView viewWithTag:1];
        lblTitle = (UILabel *)[vCell viewWithTag:2];
        lblDistance = (UILabel *)[vCell viewWithTag:3];
    }
    
    lblTitle.text = [[arrSearch objectAtIndex:indexPath.row] objectForKey:@"name"];
//    lblDistance.text = @"0.7m";
//    lblDistance.hidden = NO;
    
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    
    if (indexPath.row == currentSelectSearch) {
        vCell.backgroundColor = [UIColor colorWithRed:69.0/255 green:185.0/255 blue:207.0/255 alpha:1.0];
        lblTitle.textColor = [UIColor whiteColor];
    }
    else{
        vCell.backgroundColor = [UIColor clearColor];
        lblTitle.textColor = [UIColor colorWithRed:100.0/255 green:100.0/255 blue:100.0/255 alpha:1.0];
    }
    
    return cell;
}

-(void)didSelectedOnGalleryView:(UIImage *)imv{
    SAFE_RELEASE_ARRAY(tmpArrData);
    
    if (_arrGallerySearch.count == 0) {
        
        _flagGotoDetailOnNotMatch = YES;
//        _lblResultSearch.hidden = YES;
        
        for (int i=4-1; i>=0; i--) {
            MxoDoubleSidedView *vGr = (MxoDoubleSidedView *)[_scrollList viewWithTag:i+1111];
            SAFE_RELEASE_VIEW(vGr);
        }
        SAFE_RELEASE_VIEW(_scrollList);
        SAFE_RELEASE_VIEW(doubleSide);
        
        UIImage *__imv = [UIImage imageWithContentsOfFile:[pathDir stringByAppendingPathComponent:[[[[_arrNews objectAtIndex:_currentIndex] objectForKey:@"image"] componentsSeparatedByString:@"/"] lastObject]]];
        
        self.imvFull.image = __imv;
        
        UIBarButtonItem *itemLeft = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_icon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(menuBarButtonClicked)];
        [itemLeft setTintColor:[UIColor whiteColor]];
        self.topBarItem.leftBarButtonItem = itemLeft;
        
        
        UIBarButtonItem *itemRight = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search_bar.png"] style:UIBarButtonItemStylePlain target:self action:@selector(searchBarButtonClicked)];
        [itemRight setTintColor:[UIColor whiteColor]];
        self.topBarItem.rightBarButtonItem = itemRight;
        
        if (isIOS7) {
            [itemLeft setTintColor:[UIColor colorWithRed:120.0/255 green:120.0/255 blue:120.0/255 alpha:1.0]];
            [itemRight setTintColor:[UIColor colorWithRed:120.0/255 green:120.0/255 blue:120.0/255 alpha:1.0]];
        }
        
        
        NSMutableDictionary *itemData = [_arrNews objectAtIndex:_currentIndex];
        
        _currentItemDishData = itemData;
        
        NSInteger countTotalLike = 0;
        
        if ([[_currentItemDishData allKeys] containsObject:@"likeData"]) {
            countTotalLike = [[_currentItemDishData objectForKey:@"likeData"] count];
            if ([[_currentItemDishData objectForKey:@"likeData"] count] == 0) {
                countTotalLike = 0;
            }
        }
        else{
            countTotalLike = 0;
        }
        
        SAFE_RELEASE_VIEW(doubleSide);
        doubleSide = [[MxoDoubleSidedView alloc] initWithFrame:CGRectMake(22, 0, (320.0 - 44.0), self.detailView.frame.size.height)];
        doubleSide.tag = 1111;
        
        UIView *vFront = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (320.0 - 44.0), self.detailView.frame.size.height)];
        vFront.backgroundColor = [UIColor whiteColor];
        [doubleSide addFrontSubview:vFront];
        
        UIImageView *imvDetail = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 276, 245)];
        imvDetail.contentMode = UIViewContentModeScaleAspectFit;
        imvDetail.image = __imv;
        [vFront addSubview:imvDetail];
        
        float posY = 265;
        if (!IS_IPHONE5) {
            posY = 245;
        }
        
        UILabel *lblDish = [[UILabel alloc] initWithFrame:CGRectMake(20, posY, 237, 30)];
        lblDish.backgroundColor = [UIColor clearColor];
        [lblDish setTextColor:[UIColor colorWithRed:96.0/255 green:99.0/255 blue:102.0/255 alpha:1.0]];
        [lblDish setFont:[UIFont fontWithName:@"Roboto-Light" size:20.0]];
        lblDish.text = @"Dish Name";
        if ([[itemData allKeys] containsObject:@"dishData"]) {
            lblDish.text = [[itemData objectForKey:@"dishData"] objectForKey:@"name"];
        }
        lblDish.lineBreakMode = NSLineBreakByTruncatingTail;
        [vFront addSubview:lblDish];
        
        UIButton *btnRestaurantName = [[UIButton alloc] initWithFrame:CGRectMake(20, posY + 25, 249, 30)];
        btnRestaurantName.backgroundColor = [UIColor clearColor];
        [btnRestaurantName setTitleColor:[UIColor colorWithRed:202.0/255 green:193.0/255 blue:191.0/255 alpha:1.0] forState:UIControlStateNormal];
        [btnRestaurantName.titleLabel setFont:[UIFont fontWithName:@"Roboto-Light" size:24.0]];
        [btnRestaurantName setTitle:@"Restaurant" forState:UIControlStateNormal];
        if ([[itemData allKeys] containsObject:@"restData"]) {
            [btnRestaurantName setTitle:[[itemData objectForKey:@"restData"] objectForKey:@"name"] forState:UIControlStateNormal];
        }
        btnRestaurantName.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [btnRestaurantName addTarget:self action:@selector(flipCardToBack:) forControlEvents:UIControlEventTouchUpInside];
        btnRestaurantName.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [vFront addSubview:btnRestaurantName];
        
        
        UILabel *uploadedBy = [[UILabel alloc] initWithFrame:CGRectMake(20, vFront.frame.size.height - 20, 249, 20)];
        uploadedBy.backgroundColor = [UIColor clearColor];
        [uploadedBy setTextColor:[UIColor colorWithRed:202.0/255 green:193.0/255 blue:191.0/255 alpha:1.0]];
        [uploadedBy setFont:[UIFont fontWithName:@"Roboto-Regular" size:9.0]];
        uploadedBy.text = @"Uploaded on July 13th, 2014";
        uploadedBy.text = [NSString stringWithFormat:@"Uploaded on %@", [itemData objectForKey:@"createdAt"]];
        uploadedBy.textAlignment = NSTextAlignmentRight;
        [vFront addSubview:uploadedBy];
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd"];
        [df setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[itemData objectForKey:@"createdAt"] longLongValue]/1000];
        
        [df setDateFormat:@"MMMM dd ### yyyy"];
        uploadedBy.text = [[df stringFromDate:date] stringByReplacingOccurrencesOfString:@"###" withString:@","];
        
        NSCalendar *calender = [NSCalendar currentCalendar];
        [calender setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
        NSDateComponents *dateComponent = [calender components:(NSWeekOfYearCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
        
        if (dateComponent.day == 1 || dateComponent.day == 21 || dateComponent.day == 31 || dateComponent.day == 2 || dateComponent.day == 22 || dateComponent.day == 3 || dateComponent.day == 23) {
            uploadedBy.text = [uploadedBy.text stringByReplacingOccurrencesOfString:@" 1 " withString:@" 1st "];
            uploadedBy.text = [uploadedBy.text stringByReplacingOccurrencesOfString:@" 21 " withString:@" 21st "];
            uploadedBy.text = [uploadedBy.text stringByReplacingOccurrencesOfString:@" 31 " withString:@" 31st "];
            
            uploadedBy.text = [uploadedBy.text stringByReplacingOccurrencesOfString:@" 2 " withString:@" 2nd "];
            uploadedBy.text = [uploadedBy.text stringByReplacingOccurrencesOfString:@" 22 " withString:@" 22nd "];
            
            uploadedBy.text = [uploadedBy.text stringByReplacingOccurrencesOfString:@" 3 " withString:@" 3rd "];
            uploadedBy.text = [uploadedBy.text stringByReplacingOccurrencesOfString:@" 23 " withString:@" 23rd "];
        }
        else{
            uploadedBy.text = [uploadedBy.text stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@" %02d ", (int)dateComponent.day] withString:[NSString stringWithFormat:@" %02dth ", (int)dateComponent.day]];
        }
        
        uploadedBy.text = [NSString stringWithFormat:@"Uploaded on %@", uploadedBy.text];
        
        if (countTotalLike > 0) {
            
            posY = 265 + 73;
            if (!IS_IPHONE5) {
                posY = 245 + 60;
            }
            
            [[vFront viewWithTag:9] removeFromSuperview];
            [[vFront viewWithTag:10] removeFromSuperview];
            [[vFront viewWithTag:11] removeFromSuperview];
            [[vFront viewWithTag:12] removeFromSuperview];
            [[vFront viewWithTag:13] removeFromSuperview];
            [[vFront viewWithTag:14] removeFromSuperview];
            [[vFront viewWithTag:15] removeFromSuperview];
            [[vFront viewWithTag:16] removeFromSuperview];
            
            UIButton *imvHeart = [[UIButton alloc] initWithFrame:CGRectMake(35, posY, 23, 22)];
            [imvHeart setImage:[UIImage imageNamed:@"big_heart.png"] forState:UIControlStateNormal];
            imvHeart.tag = 9;
            [vFront addSubview:imvHeart];
            
            UILabel *countLike = [[UILabel alloc] initWithFrame:CGRectMake(66, posY, 51, 22)];
            countLike.backgroundColor = [UIColor clearColor];
            [countLike setTextColor:[UIColor colorWithRed:96.0/255 green:99.0/255 blue:102.0/255 alpha:1.0]];
            [countLike setFont:[UIFont fontWithName:@"Roboto-Light" size:24.0]];
            countLike.text = [NSString stringWithFormat:@"%d", (int)countTotalLike];
            countLike.tag = 10;
            [vFront addSubview:countLike];
            
            UILabel *namesLike = [[UILabel alloc] initWithFrame:CGRectMake(20, posY + 57, 249, 20)];
            namesLike.backgroundColor = [UIColor clearColor];
            [namesLike setTextColor:[UIColor colorWithRed:96.0/255 green:99.0/255 blue:102.0/255 alpha:1.0]];
            [namesLike setFont:[UIFont fontWithName:@"Roboto-Regular" size:9.0]];
            namesLike.text = @"";
            namesLike.tag = 11;
            [vFront addSubview:namesLike];
            
            UIImageView *imvLikePerson1 = [[UIImageView alloc] initWithFrame:CGRectMake(20, posY + 35, 20, 20)];
            imvLikePerson1.backgroundColor = [UIColor clearColor];
            imvLikePerson1.layer.cornerRadius = 10.0;
            imvLikePerson1.tag = 12;
            [vFront addSubview:imvLikePerson1];
            
            UIImageView *imvLikePerson2 = [[UIImageView alloc] initWithFrame:CGRectMake(45, posY + 35, 20, 20)];
            imvLikePerson2.backgroundColor = [UIColor clearColor];
            imvLikePerson2.layer.cornerRadius= 10.0;
            imvLikePerson2.tag = 13;
            [vFront addSubview:imvLikePerson2];
            
            UIImageView *imvLikePerson3 = [[UIImageView alloc] initWithFrame:CGRectMake(70, posY + 35, 20, 20)];
            imvLikePerson3.backgroundColor = [UIColor clearColor];
            imvLikePerson3.layer.cornerRadius= 10.0;
            imvLikePerson3.tag = 14;
            [vFront addSubview:imvLikePerson3];
            
            UIImageView *imvLikePersonMore = [[UIImageView alloc] initWithFrame:CGRectMake(97, posY + 35 + 8, 15, 4)];
            imvLikePersonMore.image = [UIImage imageNamed:@"3dot.png"];
            imvLikePersonMore.tag = 15;
            [vFront addSubview:imvLikePersonMore];
            
            SAFE_RELEASE_ARRAY(_arrLikes);
            _arrLikes = [[NSMutableArray alloc] initWithArray:[itemData objectForKey:@"likeData"]];
            
            BOOL flagMyHadLiked = NO;
            for (int j=0; j<_arrLikes.count; j++) {
                if ([[[_arrLikes objectAtIndex:j] objectForKey:@"createdBy"] isEqualToString:[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] objectForKey:@"_id"]]) {
                    flagMyHadLiked = YES;
                    break;
                }
            }
            
            if (!flagMyHadLiked) {
//                UIButton *btnLike = [[UIButton alloc] initWithFrame:CGRectMake(270 - 40, 338, 40, 40)];
//                [btnLike setImage:[UIImage imageNamed:@"icon_like.png"] forState:UIControlStateNormal];
//                [btnLike setImage:[UIImage imageNamed:@"icon_like_selected.png"] forState:UIControlStateHighlighted];
//                [btnLike addTarget:self action:@selector(likeDish:) forControlEvents:UIControlEventTouchUpInside];
//                btnLike.tag = 16;
//                [vFront addSubview:btnLike];
                
                [imvHeart setImage:[UIImage imageNamed:@"heart.png"] forState:UIControlStateNormal];
                [imvHeart addTarget:self action:@selector(likeDish:) forControlEvents:UIControlEventTouchUpInside];
            }
            else{
//                UIButton *btnLike = [[UIButton alloc] initWithFrame:CGRectMake(270 - 40, 338, 40, 40)];
//                [btnLike setImage:[UIImage imageNamed:@"icon_unlike.png"] forState:UIControlStateNormal];
//                [btnLike setImage:[UIImage imageNamed:@"icon_unlike_selected.png"] forState:UIControlStateHighlighted];
//                [btnLike addTarget:self action:@selector(unlikeDish:) forControlEvents:UIControlEventTouchUpInside];
//                btnLike.tag = 16;
//                [vFront addSubview:btnLike];
                
                [imvHeart setImage:[UIImage imageNamed:@"big_heart.png"] forState:UIControlStateNormal];
                [imvHeart addTarget:self action:@selector(unlikeDish:) forControlEvents:UIControlEventTouchUpInside];
            }
            
            if (_arrLikes.count == 1) {
                ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/users/%@", urlReal, [[_arrLikes objectAtIndex:0] objectForKey:@"createdBy"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                
                __weak typeof(ASIHTTPRequest *) weakSelf = request;
                
                [request setCompletionBlock:^{
                    [self request1UserLikeDidFinish:weakSelf];
                }];
                
                [request setFailedBlock:^{
                    [self request1UserLikeDidFail:weakSelf];
                }];
                
//                [request setDidFinishSelector:@selector(request1UserLikeDidFinish:)];
//                [request setDidFailSelector:@selector(request1UserLikeDidFail:)];
//                request.delegate = self;
                
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
            else if (_arrLikes.count > 1) {
                [_arrLikes sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:NO]]];
                
                ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/users/%@", urlReal, [[_arrLikes objectAtIndex:0] objectForKey:@"createdBy"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                
                __weak typeof(ASIHTTPRequest *) weakSelf = request;
                
                [request setCompletionBlock:^{
                    [self request1UserLikeDidFinish:weakSelf];
                }];
                
                [request setFailedBlock:^{
                    [self request1UserLikeDidFail:weakSelf];
                }];
                
//                [request setDidFinishSelector:@selector(request1UserLikeDidFinish:)];
//                [request setDidFailSelector:@selector(request1UserLikeDidFail:)];
//                request.delegate = self;
                
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
                
                ASINetworkQueue *queueUserLike = [[ASINetworkQueue alloc] init];
                queueUserLike.delegate = self;
                [queueUserLike setQueueDidFinishSelector:@selector(queueUserLikeDidFinished:)];
                for (int j=1; j<_arrLikes.count; j++) {
                    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/users/%@", urlReal, [[_arrLikes objectAtIndex:j] objectForKey:@"createdBy"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                    
                    __weak typeof(ASIHTTPRequest *) weakSelf = request;
                    
                    [request setCompletionBlock:^{
                        [self requestUserLikeDidFinish:weakSelf];
                    }];
                    
                    [request setFailedBlock:^{
                        [self requestUserLikeDidFail:weakSelf];
                    }];
                    
//                    [request setDidFinishSelector:@selector(requestUserLikeDidFinish:)];
//                    [request setDidFailSelector:@selector(requestUserLikeDidFail:)];
//                    request.delegate = self;
                    
                    [request setRequestMethod:@"GET"];
                    [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
                    
                    [request setUseCookiePersistence:NO];
                    [request setUseSessionPersistence:NO];
                    
                    if (cookie) {
                        [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
                    }
                    
                    [request addRequestHeader:@"Vary" value:@"Accept-Encoding"];
                    [request addRequestHeader:@"X-Powered-By" value:@"Express"];
                    [queueUserLike addOperation:request];
                }
                
                if (queueUserLike.operationCount > 0) {
                    [queueUserLike go];
                }
            }
            
            if (_arrLikes.count == 1) {
                imvLikePerson2.hidden = YES;
                imvLikePerson3.hidden = YES;
                imvLikePersonMore.hidden = YES;
            }
            else if (_arrLikes.count == 2) {
                imvLikePerson2.hidden = NO;
                imvLikePerson3.hidden = YES;
                imvLikePersonMore.hidden = YES;
            }
            else if (_arrLikes.count == 3) {
                imvLikePerson2.hidden = NO;
                imvLikePerson3.hidden = NO;
                imvLikePersonMore.hidden = YES;
            }
            else if (_arrLikes.count > 3) {
                imvLikePerson2.hidden = NO;
                imvLikePerson3.hidden = NO;
                imvLikePersonMore.hidden = NO;
            }
        }
        else {
            posY = 265 + 73;
            if (!IS_IPHONE5) {
                posY = 245 + 60;
            }
            UIButton *imvHeart = [[UIButton alloc] initWithFrame:CGRectMake(35, posY, 23, 22)];
            [imvHeart setImage:[UIImage imageNamed:@"heart.png"] forState:UIControlStateNormal];
            imvHeart.tag = 9;
            [imvHeart addTarget:self action:@selector(likeDish:) forControlEvents:UIControlEventTouchUpInside];
            [vFront addSubview:imvHeart];
        }
        
        UIView *vBack = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, (320.0 - 44.0), self.detailView.frame.size.height)];
        vBack.backgroundColor = [UIColor whiteColor];
        [doubleSide addBackSubview:vBack];
        
        UIImageView *imvMapImv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 276, 215)];
        if ([[itemData allKeys] containsObject:@"restData"]) {
            [imvMapImv setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://gobbl.snapplab.com/api/0/restaurants/%@/photo", [[itemData objectForKey:@"restData"] objectForKey:@"_id"]]] placeholderImage:[UIImage imageNamed:@"exMapImv.png"]];
        }
        [vBack addSubview:imvMapImv];
        
        UIImageView *imvMapImvMask = [[UIImageView alloc] initWithFrame:CGRectMake(0, 215-110, 276, 110)];
        imvMapImvMask.image = [UIImage imageNamed:@"gradient_fill.png"];
        [vBack addSubview:imvMapImvMask];
        
        UILabel *map_restName = [[UILabel alloc] initWithFrame:CGRectMake(10, 215-60, 257, 20)];
        map_restName.backgroundColor = [UIColor clearColor];
        [map_restName setTextColor:[UIColor whiteColor]];
        [map_restName setFont:[UIFont fontWithName:@"Roboto-Light" size:22.0]];
        map_restName.text = @"Restaurant Name";
        if ([[itemData allKeys] containsObject:@"restData"]) {
            [map_restName setText:[[itemData objectForKey:@"restData"] objectForKey:@"name"]];
        }
        [vBack addSubview:map_restName];
        
        UILabel *map_restAddress = [[UILabel alloc] initWithFrame:CGRectMake(10, 215-40, 257, 20)];
        map_restAddress.backgroundColor = [UIColor clearColor];
        [map_restAddress setTextColor:[UIColor whiteColor]];
        [map_restAddress setFont:[UIFont fontWithName:@"Roboto-Condensed" size:13.0]];
        map_restAddress.text = @"510 Main street, New York, NY 10044";
        if ([[itemData allKeys] containsObject:@"restData"]) {
            [map_restAddress setText:[[itemData objectForKey:@"restData"] objectForKey:@"vicinity"]];
        }
        map_restAddress.lineBreakMode = NSLineBreakByTruncatingTail;
        [vBack addSubview:map_restAddress];
        
        UILabel *map_restPhone = [[UILabel alloc] initWithFrame:CGRectMake(10, 215-20, 257, 20)];
        map_restPhone.backgroundColor = [UIColor clearColor];
        [map_restPhone setTextColor:[UIColor whiteColor]];
        [map_restPhone setFont:[UIFont fontWithName:@"Roboto-Condensed" size:13.0]];
        map_restPhone.text = @"646 206 4887";
        map_restPhone.lineBreakMode = NSLineBreakByTruncatingTail;
        if ([[itemData allKeys] containsObject:@"restData"]) {
            NSString *sType = @"";
            for (int i=0; i<[[[[itemData objectForKey:@"restData"] objectForKey:@"google"] objectForKey:@"types"] count]; i++) {
                sType = [sType stringByAppendingFormat:@"%@, ", [[[[itemData objectForKey:@"restData"] objectForKey:@"google"] objectForKey:@"types"] objectAtIndex:i]];
            }
            if (sType.length > 0) {
                sType = [sType substringToIndex:sType.length-2];
            }
            [map_restPhone setText:sType];
        }
        map_restPhone.lineBreakMode = NSLineBreakByTruncatingTail;
        [vBack addSubview:map_restPhone];
        
        UIButton *btnMapBack = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 276, 215)];
        [btnMapBack addTarget:self action:@selector(flipCardToFront:) forControlEvents:UIControlEventTouchUpInside];
        [vBack addSubview:btnMapBack];
        
        UIButton *btnCloseMap = [[UIButton alloc] initWithFrame:CGRectMake(276 - 40, 0, 40, 40)];
        [btnCloseMap setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
        [btnCloseMap addTarget:self action:@selector(flipCardToFront:) forControlEvents:UIControlEventTouchUpInside];
        [vBack addSubview:btnCloseMap];
        
        MKMapView *myMap = [[MKMapView alloc] initWithFrame:CGRectMake(0, 215, 276, self.detailView.frame.size.height - 215)];
        myMap.delegate = self;
        [vBack addSubview:myMap];
        
        if ([[itemData allKeys] containsObject:@"restData"]) {
            CLLocationCoordinate2D zoomLocation;
            
            float longValue = [[[[[itemData objectForKey:@"restData"] objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"] floatValue];
            float latValue = [[[[[itemData objectForKey:@"restData"] objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"] floatValue];
            
            zoomLocation.latitude = latValue;
            zoomLocation.longitude = longValue;
            
            MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
            [myMap setRegion:viewRegion animated:YES];
            
            
            MyLocation *annotation = [[MyLocation alloc] initWithName:[[itemData objectForKey:@"restData"] objectForKey:@"name"] address:[[itemData objectForKey:@"restData"] objectForKey:@"vicinity"] coordinate:zoomLocation] ;
            [myMap addAnnotation:annotation];
            
            
            MyLocation *myAnnotation = [[MyLocation alloc] initWithName:@"My Location" address:@"" coordinate:[LocationManager locationManager].currentLocation.coordinate];
            [myMap addAnnotation:myAnnotation];
            
//            UIButton *mapCurrentLocation = [[UIButton alloc] initWithFrame:CGRectMake(276-40, 215, 40, 40)];
//            [mapCurrentLocation setImage:[UIImage imageNamed:@"location_icon.png"] forState:UIControlStateNormal];
//            [vBack addSubview:mapCurrentLocation];
            
//            float max_long = longValue;
//            float min_long = [LocationManager locationManager].currentLocation.coordinate.longitude;
//            float max_lat = latValue;
//            float min_lat = [LocationManager locationManager].currentLocation.coordinate.latitude;
//            
//            //find min and max values
//            if (latValue > max_lat) {max_lat = latValue;}
//            if (latValue < min_lat) {min_lat = latValue;}
//            if (longValue > max_long) {max_long = longValue;}
//            if (longValue < min_long) {min_long = longValue;}
//            
//            //calculate center of map
//            double center_long = (max_long + min_long) / 2;
//            double center_lat = (max_lat + min_lat) / 2;
//            
//            //calculate deltas
//            double deltaLat = abs(max_lat - min_lat);
//            double deltaLong = abs(max_long - min_long);
//            
//            //set minimal delta
//            if (deltaLat < 0.1) {deltaLat = 0.1;}
//            if (deltaLong < 0.1) {deltaLong = 0.1;}
//            
//            //debug
//            //NSLog(@"center long: %f, center lat: %f", center_long, center_lat);
//            //NSLog(@"max_long: %f, min_long: %f, max_lat: %f, min_lat: %f", max_long, min_long, max_lat, min_lat);
//            
//            //create new region and set map
//            CLLocationCoordinate2D coord = {.latitude =  center_lat, .longitude =  center_long};
//            MKCoordinateSpan span = MKCoordinateSpanMake(deltaLat, deltaLong);
//            MKCoordinateRegion region = {coord, span};
//            [myMap setRegion:region animated:YES];
        }
        
        
        doubleSide.tag = 9999;
        [self.detailView addSubview:doubleSide];
        
        [UIView animateWithDuration:0.5 animations:^{
            self.searchView.frame = CGRectMake(-320, self.searchView.frame.origin.y, 320, self.searchView.frame.size.height);
            self.cameraButton.alpha = 0.0;
            self.detailView.alpha = 1.0;
            
        } completion:^(BOOL finished) {
            
            
            [imvZoom setHidden:YES];
        }];
        
        return;
    }
    
    _flagGotoDetailOnHaveMatch = YES;
    
    for (int i=4-1; i>=0; i--) {
        MxoDoubleSidedView *vGr = (MxoDoubleSidedView *)[_scrollList viewWithTag:i+1111];
        SAFE_RELEASE_VIEW(vGr);
    }
    SAFE_RELEASE_VIEW(_scrollList);
    SAFE_RELEASE_VIEW(doubleSide);
    
    UIImage *__imv = [UIImage imageWithContentsOfFile:[pathDir stringByAppendingPathComponent:[[[[_arrGallerySearch objectAtIndex:0] objectForKey:@"image"] componentsSeparatedByString:@"/"] lastObject]]];
    
    self.imvFull.image = __imv;
    
    UIBarButtonItem *itemLeft = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_icon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(menuBarButtonClicked)];
    [itemLeft setTintColor:[UIColor whiteColor]];
    self.topBarItem.leftBarButtonItem = itemLeft;
    
    
    UIBarButtonItem *itemRight = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search_bar.png"] style:UIBarButtonItemStylePlain target:self action:@selector(searchBarButtonClicked)];
    [itemRight setTintColor:[UIColor whiteColor]];
    self.topBarItem.rightBarButtonItem = itemRight;
    
    if (isIOS7) {
        [itemLeft setTintColor:[UIColor colorWithRed:120.0/255 green:120.0/255 blue:120.0/255 alpha:1.0]];
        [itemRight setTintColor:[UIColor colorWithRed:120.0/255 green:120.0/255 blue:120.0/255 alpha:1.0]];
    }
    
    
    NSMutableDictionary *itemData = [_arrGallerySearch objectAtIndex:0];
    
    _currentItemDishData = itemData;
    
    NSInteger countTotalLike = 0;
    
    if ([[_currentItemDishData allKeys] containsObject:@"likeData"]) {
        countTotalLike = [[_currentItemDishData objectForKey:@"likeData"] count];
        if ([[_currentItemDishData objectForKey:@"likeData"] count] == 0) {
            countTotalLike = 0;
        }
    }
    else{
        countTotalLike = 0;
    }
    
    SAFE_RELEASE_VIEW(doubleSide);
    doubleSide = [[MxoDoubleSidedView alloc] initWithFrame:CGRectMake(22, 0, (320.0 - 44.0), self.detailView.frame.size.height)];
    doubleSide.tag = 1111;
    
    UIView *vFront = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (320.0 - 44.0), self.detailView.frame.size.height)];
    vFront.backgroundColor = [UIColor whiteColor];
    [doubleSide addFrontSubview:vFront];
    
    UIImageView *imvDetail = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 276, 245)];
    imvDetail.contentMode = UIViewContentModeScaleAspectFit;
    imvDetail.image = __imv;
    [vFront addSubview:imvDetail];
    
    float posY = 265;
    if (!IS_IPHONE5) {
        posY = 245;
    }
    
    UILabel *lblDish = [[UILabel alloc] initWithFrame:CGRectMake(20, posY, 237, 30)];
    lblDish.backgroundColor = [UIColor clearColor];
    [lblDish setTextColor:[UIColor colorWithRed:96.0/255 green:99.0/255 blue:102.0/255 alpha:1.0]];
    [lblDish setFont:[UIFont fontWithName:@"Roboto-Light" size:20.0]];
    lblDish.text = @"Dish Name";
    if ([[itemData allKeys] containsObject:@"dishData"]) {
        lblDish.text = [[itemData objectForKey:@"dishData"] objectForKey:@"name"];
    }
    lblDish.lineBreakMode = NSLineBreakByTruncatingTail;
    [vFront addSubview:lblDish];
    
    UIButton *btnRestaurantName = [[UIButton alloc] initWithFrame:CGRectMake(20, posY + 25, 249, 30)];
    btnRestaurantName.backgroundColor = [UIColor clearColor];
    [btnRestaurantName setTitleColor:[UIColor colorWithRed:202.0/255 green:193.0/255 blue:191.0/255 alpha:1.0] forState:UIControlStateNormal];
    [btnRestaurantName.titleLabel setFont:[UIFont fontWithName:@"Roboto-Light" size:24.0]];
    [btnRestaurantName setTitle:@"Restaurant" forState:UIControlStateNormal];
    if ([[itemData allKeys] containsObject:@"restData"]) {
        [btnRestaurantName setTitle:[[itemData objectForKey:@"restData"] objectForKey:@"name"] forState:UIControlStateNormal];
    }
    btnRestaurantName.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [btnRestaurantName addTarget:self action:@selector(flipCardToBack:) forControlEvents:UIControlEventTouchUpInside];
    btnRestaurantName.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [vFront addSubview:btnRestaurantName];
    
    
    UILabel *uploadedBy = [[UILabel alloc] initWithFrame:CGRectMake(20, vFront.frame.size.height - 20, 249, 20)];
    uploadedBy.backgroundColor = [UIColor clearColor];
    [uploadedBy setTextColor:[UIColor colorWithRed:202.0/255 green:193.0/255 blue:191.0/255 alpha:1.0]];
    [uploadedBy setFont:[UIFont fontWithName:@"Roboto-Regular" size:9.0]];
    uploadedBy.text = @"Uploaded on July 13th, 2014";
    uploadedBy.text = [NSString stringWithFormat:@"Uploaded on %@", [itemData objectForKey:@"createdAt"]];
    uploadedBy.textAlignment = NSTextAlignmentRight;
    [vFront addSubview:uploadedBy];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    [df setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[itemData objectForKey:@"createdAt"] longLongValue]/1000];
    
    [df setDateFormat:@"MMMM dd ### yyyy"];
    uploadedBy.text = [[df stringFromDate:date] stringByReplacingOccurrencesOfString:@"###" withString:@","];
    
    NSCalendar *calender = [NSCalendar currentCalendar];
    [calender setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
    NSDateComponents *dateComponent = [calender components:(NSWeekOfYearCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
    
    if (dateComponent.day == 1 || dateComponent.day == 21 || dateComponent.day == 31 || dateComponent.day == 2 || dateComponent.day == 22 || dateComponent.day == 3 || dateComponent.day == 23) {
        uploadedBy.text = [uploadedBy.text stringByReplacingOccurrencesOfString:@" 1 " withString:@" 1st "];
        uploadedBy.text = [uploadedBy.text stringByReplacingOccurrencesOfString:@" 21 " withString:@" 21st "];
        uploadedBy.text = [uploadedBy.text stringByReplacingOccurrencesOfString:@" 31 " withString:@" 31st "];
        
        uploadedBy.text = [uploadedBy.text stringByReplacingOccurrencesOfString:@" 2 " withString:@" 2nd "];
        uploadedBy.text = [uploadedBy.text stringByReplacingOccurrencesOfString:@" 22 " withString:@" 22nd "];
        
        uploadedBy.text = [uploadedBy.text stringByReplacingOccurrencesOfString:@" 3 " withString:@" 3rd "];
        uploadedBy.text = [uploadedBy.text stringByReplacingOccurrencesOfString:@" 23 " withString:@" 23rd "];
    }
    else{
        uploadedBy.text = [uploadedBy.text stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@" %02d ", (int)dateComponent.day] withString:[NSString stringWithFormat:@" %02dth ", (int)dateComponent.day]];
    }
    
    uploadedBy.text = [NSString stringWithFormat:@"Uploaded on %@", uploadedBy.text];
    
    if (countTotalLike > 0) {
        
        posY = 265 + 73;
        if (!IS_IPHONE5) {
            posY = 245 + 60;
        }
        
        [[vFront viewWithTag:9] removeFromSuperview];
        [[vFront viewWithTag:10] removeFromSuperview];
        [[vFront viewWithTag:11] removeFromSuperview];
        [[vFront viewWithTag:12] removeFromSuperview];
        [[vFront viewWithTag:13] removeFromSuperview];
        [[vFront viewWithTag:14] removeFromSuperview];
        [[vFront viewWithTag:15] removeFromSuperview];
        [[vFront viewWithTag:16] removeFromSuperview];
        
        UIButton *imvHeart = [[UIButton alloc] initWithFrame:CGRectMake(35, posY, 23, 22)];
        [imvHeart setImage:[UIImage imageNamed:@"big_heart.png"] forState:UIControlStateNormal];
        imvHeart.tag = 9;
        [vFront addSubview:imvHeart];
        
        UILabel *countLike = [[UILabel alloc] initWithFrame:CGRectMake(66, posY, 51, 22)];
        countLike.backgroundColor = [UIColor clearColor];
        [countLike setTextColor:[UIColor colorWithRed:96.0/255 green:99.0/255 blue:102.0/255 alpha:1.0]];
        [countLike setFont:[UIFont fontWithName:@"Roboto-Light" size:24.0]];
        countLike.text = [NSString stringWithFormat:@"%d", (int)countTotalLike];
        countLike.tag = 10;
        [vFront addSubview:countLike];
        
        UILabel *namesLike = [[UILabel alloc] initWithFrame:CGRectMake(20, posY + 57, 249, 20)];
        namesLike.backgroundColor = [UIColor clearColor];
        [namesLike setTextColor:[UIColor colorWithRed:96.0/255 green:99.0/255 blue:102.0/255 alpha:1.0]];
        [namesLike setFont:[UIFont fontWithName:@"Roboto-Regular" size:9.0]];
        namesLike.text = @"";
        namesLike.tag = 11;
        [vFront addSubview:namesLike];
        
        UIImageView *imvLikePerson1 = [[UIImageView alloc] initWithFrame:CGRectMake(20, posY + 35, 20, 20)];
        imvLikePerson1.backgroundColor = [UIColor clearColor];
        imvLikePerson1.layer.cornerRadius = 10.0;
        imvLikePerson1.tag = 12;
        [vFront addSubview:imvLikePerson1];
        
        UIImageView *imvLikePerson2 = [[UIImageView alloc] initWithFrame:CGRectMake(45, posY + 35, 20, 20)];
        imvLikePerson2.backgroundColor = [UIColor clearColor];
        imvLikePerson2.layer.cornerRadius= 10.0;
        imvLikePerson2.tag = 13;
        [vFront addSubview:imvLikePerson2];
        
        UIImageView *imvLikePerson3 = [[UIImageView alloc] initWithFrame:CGRectMake(70, posY + 35, 20, 20)];
        imvLikePerson3.backgroundColor = [UIColor clearColor];
        imvLikePerson3.layer.cornerRadius= 10.0;
        imvLikePerson3.tag = 14;
        [vFront addSubview:imvLikePerson3];
        
        UIImageView *imvLikePersonMore = [[UIImageView alloc] initWithFrame:CGRectMake(97, posY + 35 + 8, 15, 4)];
        imvLikePersonMore.image = [UIImage imageNamed:@"3dot.png"];
        imvLikePersonMore.tag = 15;
        [vFront addSubview:imvLikePersonMore];
        
        SAFE_RELEASE_ARRAY(_arrLikes);
        _arrLikes = [[NSMutableArray alloc] initWithArray:[itemData objectForKey:@"likeData"]];
        
        BOOL flagMyHadLiked = NO;
        for (int j=0; j<_arrLikes.count; j++) {
            if ([[[_arrLikes objectAtIndex:j] objectForKey:@"createdBy"] isEqualToString:[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] objectForKey:@"_id"]]) {
                flagMyHadLiked = YES;
                break;
            }
        }
        
        if (!flagMyHadLiked) {
//            UIButton *btnLike = [[UIButton alloc] initWithFrame:CGRectMake(270 - 40, 338, 40, 40)];
//            [btnLike setImage:[UIImage imageNamed:@"icon_like.png"] forState:UIControlStateNormal];
//            [btnLike setImage:[UIImage imageNamed:@"icon_like_selected.png"] forState:UIControlStateHighlighted];
//            [btnLike addTarget:self action:@selector(likeDish:) forControlEvents:UIControlEventTouchUpInside];
//            btnLike.tag = 16;
//            [vFront addSubview:btnLike];
            
            [imvHeart setImage:[UIImage imageNamed:@"heart.png"] forState:UIControlStateNormal];
            [imvHeart addTarget:self action:@selector(likeDish:) forControlEvents:UIControlEventTouchUpInside];
        }
        else{
//            UIButton *btnLike = [[UIButton alloc] initWithFrame:CGRectMake(270 - 40, 338, 40, 40)];
//            [btnLike setImage:[UIImage imageNamed:@"icon_unlike.png"] forState:UIControlStateNormal];
//            [btnLike setImage:[UIImage imageNamed:@"icon_unlike_selected.png"] forState:UIControlStateHighlighted];
//            [btnLike addTarget:self action:@selector(unlikeDish:) forControlEvents:UIControlEventTouchUpInside];
//            btnLike.tag = 16;
//            [vFront addSubview:btnLike];
            
            [imvHeart setImage:[UIImage imageNamed:@"big_heart.png"] forState:UIControlStateNormal];
            [imvHeart addTarget:self action:@selector(unlikeDish:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        if (_arrLikes.count == 1) {
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/users/%@", urlReal, [[_arrLikes objectAtIndex:0] objectForKey:@"createdBy"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            
            __weak typeof(ASIHTTPRequest *) weakSelf = request;
            
            [request setCompletionBlock:^{
                [self request1UserLikeDidFinish:weakSelf];
            }];
            
            [request setFailedBlock:^{
                [self request1UserLikeDidFail:weakSelf];
            }];
            
//            [request setDidFinishSelector:@selector(request1UserLikeDidFinish:)];
//            [request setDidFailSelector:@selector(request1UserLikeDidFail:)];
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
        else if (_arrLikes.count > 1) {
            [_arrLikes sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:NO]]];
            
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/users/%@", urlReal, [[_arrLikes objectAtIndex:0] objectForKey:@"createdBy"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            
            __weak typeof(ASIHTTPRequest *) weakSelf = request;
            
            [request setCompletionBlock:^{
                [self request1UserLikeDidFinish:weakSelf];
            }];
            
            [request setFailedBlock:^{
                [self request1UserLikeDidFail:weakSelf];
            }];
            
//            [request setDidFinishSelector:@selector(request1UserLikeDidFinish:)];
//            [request setDidFailSelector:@selector(request1UserLikeDidFail:)];
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
            
            ASINetworkQueue *queueUserLike = [[ASINetworkQueue alloc] init];
            queueUserLike.delegate = self;
            [queueUserLike setQueueDidFinishSelector:@selector(queueUserLikeDidFinished:)];
            for (int j=1; j<_arrLikes.count; j++) {
                ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/users/%@", urlReal, [[_arrLikes objectAtIndex:j] objectForKey:@"createdBy"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                
                __weak typeof(ASIHTTPRequest *) weakSelf = request;
                
                [request setCompletionBlock:^{
                    [self requestUserLikeDidFinish:weakSelf];
                }];
                
                [request setFailedBlock:^{
                    [self requestUserLikeDidFail:weakSelf];
                }];
                
//                [request setDidFinishSelector:@selector(requestUserLikeDidFinish:)];
//                [request setDidFailSelector:@selector(requestUserLikeDidFail:)];
//                request.delegate = self;
                
                [request setRequestMethod:@"GET"];
                [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
                
                [request setUseCookiePersistence:NO];
                [request setUseSessionPersistence:NO];
                
                if (cookie) {
                    [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
                }
                
                [request addRequestHeader:@"Vary" value:@"Accept-Encoding"];
                [request addRequestHeader:@"X-Powered-By" value:@"Express"];
                [queueUserLike addOperation:request];
            }
            
            if (queueUserLike.operationCount > 0) {
                [queueUserLike go];
            }
        }
        
        if (_arrLikes.count == 1) {
            imvLikePerson2.hidden = YES;
            imvLikePerson3.hidden = YES;
            imvLikePersonMore.hidden = YES;
        }
        else if (_arrLikes.count == 2) {
            imvLikePerson2.hidden = NO;
            imvLikePerson3.hidden = YES;
            imvLikePersonMore.hidden = YES;
        }
        else if (_arrLikes.count == 3) {
            imvLikePerson2.hidden = NO;
            imvLikePerson3.hidden = NO;
            imvLikePersonMore.hidden = YES;
        }
        else if (_arrLikes.count > 3) {
            imvLikePerson2.hidden = NO;
            imvLikePerson3.hidden = NO;
            imvLikePersonMore.hidden = NO;
        }
    }
    else{
        posY = 265 + 73;
        if (!IS_IPHONE5) {
            posY = 245 + 60;
        }
        
        UIButton *imvHeart = [[UIButton alloc] initWithFrame:CGRectMake(35, posY, 23, 22)];
        [imvHeart setImage:[UIImage imageNamed:@"heart.png"] forState:UIControlStateNormal];
        imvHeart.tag = 9;
        [imvHeart addTarget:self action:@selector(likeDish:) forControlEvents:UIControlEventTouchUpInside];
        [vFront addSubview:imvHeart];
    }
    
    UIView *vBack = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (320.0 - 44.0), self.detailView.frame.size.height)];
    vBack.backgroundColor = [UIColor whiteColor];
    [doubleSide addBackSubview:vBack];
    
    UIImageView *imvMapImv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 276, 215)];
    if ([[itemData allKeys] containsObject:@"restData"]) {
        [imvMapImv setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://gobbl.snapplab.com/api/0/restaurants/%@/photo", [[itemData objectForKey:@"restData"] objectForKey:@"_id"]]] placeholderImage:[UIImage imageNamed:@"exMapImv.png"]];
    }
    [vBack addSubview:imvMapImv];
    
    UIImageView *imvMapImvMask = [[UIImageView alloc] initWithFrame:CGRectMake(0, 215-110, 276, 110)];
    imvMapImvMask.image = [UIImage imageNamed:@"gradient_fill.png"];
    [vBack addSubview:imvMapImvMask];
    
    UILabel *map_restName = [[UILabel alloc] initWithFrame:CGRectMake(10, 215-60, 257, 20)];
    map_restName.backgroundColor = [UIColor clearColor];
    [map_restName setTextColor:[UIColor whiteColor]];
    [map_restName setFont:[UIFont fontWithName:@"Roboto-Light" size:22.0]];
    map_restName.text = @"Restaurant Name";
    if ([[itemData allKeys] containsObject:@"restData"]) {
        [map_restName setText:[[itemData objectForKey:@"restData"] objectForKey:@"name"]];
    }
    [vBack addSubview:map_restName];
    
    UILabel *map_restAddress = [[UILabel alloc] initWithFrame:CGRectMake(10, 215-40, 257, 20)];
    map_restAddress.backgroundColor = [UIColor clearColor];
    [map_restAddress setTextColor:[UIColor whiteColor]];
    [map_restAddress setFont:[UIFont fontWithName:@"Roboto-Condensed" size:13.0]];
    map_restAddress.text = @"510 Main street, New York, NY 10044";
    if ([[itemData allKeys] containsObject:@"restData"]) {
        [map_restAddress setText:[[itemData objectForKey:@"restData"] objectForKey:@"vicinity"]];
    }
    map_restAddress.lineBreakMode = NSLineBreakByTruncatingTail;
    [vBack addSubview:map_restAddress];
    
    UILabel *map_restPhone = [[UILabel alloc] initWithFrame:CGRectMake(10, 215-20, 257, 20)];
    map_restPhone.backgroundColor = [UIColor clearColor];
    [map_restPhone setTextColor:[UIColor whiteColor]];
    [map_restPhone setFont:[UIFont fontWithName:@"Roboto-Condensed" size:13.0]];
    map_restPhone.text = @"646 206 4887";
    map_restPhone.lineBreakMode = NSLineBreakByTruncatingTail;
    if ([[itemData allKeys] containsObject:@"restData"]) {
        NSString *sType = @"";
        for (int i=0; i<[[[[itemData objectForKey:@"restData"] objectForKey:@"google"] objectForKey:@"types"] count]; i++) {
            sType = [sType stringByAppendingFormat:@"%@, ", [[[[itemData objectForKey:@"restData"] objectForKey:@"google"] objectForKey:@"types"] objectAtIndex:i]];
        }
        if (sType.length > 0) {
            sType = [sType substringToIndex:sType.length-2];
        }
        [map_restPhone setText:sType];
    }
    map_restPhone.lineBreakMode = NSLineBreakByTruncatingTail;
    [vBack addSubview:map_restPhone];
    
    UIButton *btnMapBack = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 276, 215)];
    [btnMapBack addTarget:self action:@selector(flipCardToFront:) forControlEvents:UIControlEventTouchUpInside];
    [vBack addSubview:btnMapBack];
    
    UIButton *btnCloseMap = [[UIButton alloc] initWithFrame:CGRectMake(276 - 40, 0, 40, 40)];
    [btnCloseMap setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
    [btnCloseMap addTarget:self action:@selector(flipCardToFront:) forControlEvents:UIControlEventTouchUpInside];
    [vBack addSubview:btnCloseMap];
    
    MKMapView *myMap = [[MKMapView alloc] initWithFrame:CGRectMake(0, 215, 276, self.detailView.frame.size.height - 215)];
    myMap.delegate = self;
    [vBack addSubview:myMap];
    
    if ([[itemData allKeys] containsObject:@"restData"]) {
        CLLocationCoordinate2D zoomLocation;
        
        float longValue = [[[[[itemData objectForKey:@"restData"] objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"] floatValue];
        float latValue = [[[[[itemData objectForKey:@"restData"] objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"] floatValue];
        
        zoomLocation.latitude = latValue;
        zoomLocation.longitude = longValue;
        
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
        [myMap setRegion:viewRegion animated:YES];
        
        
        MyLocation *annotation = [[MyLocation alloc] initWithName:[[itemData objectForKey:@"restData"] objectForKey:@"name"] address:[[itemData objectForKey:@"restData"] objectForKey:@"vicinity"] coordinate:zoomLocation] ;
        [myMap addAnnotation:annotation];
        
        
        MyLocation *myAnnotation = [[MyLocation alloc] initWithName:@"My Location" address:@"" coordinate:[LocationManager locationManager].currentLocation.coordinate];
        [myMap addAnnotation:myAnnotation];
        
//        UIButton *mapCurrentLocation = [[UIButton alloc] initWithFrame:CGRectMake(276-40, 215, 40, 40)];
//        [mapCurrentLocation setImage:[UIImage imageNamed:@"location_icon.png"] forState:UIControlStateNormal];
//        [vBack addSubview:mapCurrentLocation];
        
//        float max_long = longValue;
//        float min_long = [LocationManager locationManager].currentLocation.coordinate.longitude;
//        float max_lat = latValue;
//        float min_lat = [LocationManager locationManager].currentLocation.coordinate.latitude;
//        
//        //find min and max values
//        if (latValue > max_lat) {max_lat = latValue;}
//        if (latValue < min_lat) {min_lat = latValue;}
//        if (longValue > max_long) {max_long = longValue;}
//        if (longValue < min_long) {min_long = longValue;}
//        
//        //calculate center of map
//        double center_long = (max_long + min_long) / 2;
//        double center_lat = (max_lat + min_lat) / 2;
//        
//        //calculate deltas
//        double deltaLat = abs(max_lat - min_lat);
//        double deltaLong = abs(max_long - min_long);
//        
//        //set minimal delta
//        if (deltaLat < 0.1) {deltaLat = 0.1;}
//        if (deltaLong < 0.1) {deltaLong = 0.1;}
//        
//        //debug
//        //NSLog(@"center long: %f, center lat: %f", center_long, center_lat);
//        //NSLog(@"max_long: %f, min_long: %f, max_lat: %f, min_lat: %f", max_long, min_long, max_lat, min_lat);
//        
//        //create new region and set map
//        CLLocationCoordinate2D coord = {.latitude =  center_lat, .longitude =  center_long};
//        MKCoordinateSpan span = MKCoordinateSpanMake(deltaLat, deltaLong);
//        MKCoordinateRegion region = {coord, span};
//        [myMap setRegion:region animated:YES];
    }
    
    
    doubleSide.tag = 9999;
    [self.detailView addSubview:doubleSide];
    self.searchView.alpha = 0.0;
    
    [UIView animateWithDuration:0.5 animations:^{
        _resultSearchView.frame = CGRectMake(-320, _resultSearchView.frame.origin.y, 320, _resultSearchView.frame.size.height);
        self.cameraButton.alpha = 0.0;
        self.detailView.alpha = 1.0;
        
    } completion:^(BOOL finished) {
        
        
        [imvZoom setHidden:YES];
    }];
}

-(void)requestListSearchDishDidFinish:(ASIHTTPRequest *)request{
    NSString *theJSON = [request responseString];
    NSLog(@"requestListSearchDishDidFinish:%@", theJSON);
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    
    NSMutableArray *arrImv = [[NSMutableArray alloc] init];
    
    SAFE_RELEASE_ARRAY(_arrGallerySearch);
    _arrGallerySearch = [[NSMutableArray alloc] initWithArray:[[parser objectWithString:theJSON] objectForKey:@"data"]];
    for (int i=0; i<_arrGallerySearch.count; i++) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[pathDir stringByAppendingPathComponent:[[[[_arrGallerySearch objectAtIndex:i] objectForKey:@"image"] componentsSeparatedByString:@"/"] lastObject]]]) {
            [arrImv addObject:[UIImage imageWithContentsOfFile:[pathDir stringByAppendingPathComponent:[[[[_arrGallerySearch objectAtIndex:i] objectForKey:@"image"] componentsSeparatedByString:@"/"] lastObject]]]];
        }
        else{
            NSData *binaryImageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@", urlReal, [[_arrGallerySearch objectAtIndex:i] objectForKey:@"image"]]]];
            [binaryImageData writeToFile:[pathDir stringByAppendingPathComponent:[[[[_arrGallerySearch objectAtIndex:i] objectForKey:@"image"] componentsSeparatedByString:@"/"] lastObject]] atomically:YES];
            
            [arrImv addObject:[UIImage imageWithData:binaryImageData]];
        }
    }
    
    ASINetworkQueue *queue = [[ASINetworkQueue alloc] init];
    queue.delegate = self;
    
    ASINetworkQueue *queueDish = [[ASINetworkQueue alloc] init];
    queueDish.delegate = self;
    
    ASINetworkQueue *queueLikes = [[ASINetworkQueue alloc] init];
    queueLikes.delegate = self;
    
    for (NSInteger i=0; i<_arrGallerySearch.count; i++) {
        if ([[[_arrGallerySearch objectAtIndex:i] allKeys] containsObject:@"restaurant"]) {
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/restaurants/%@", urlReal, [[_arrGallerySearch objectAtIndex:i] objectForKey:@"restaurant"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            
            __weak typeof(ASIHTTPRequest *) weakSelf = request;
            
            [request setCompletionBlock:^{
                [self requestRestaurantDidFinish:weakSelf];
            }];
            
            [request setFailedBlock:^{
                [self requestRestaurantDidFail:weakSelf];
            }];
            
//            [request setDidFinishSelector:@selector(requestRestaurantDidFinish:)];
//            [request setDidFailSelector:@selector(requestRestaurantDidFail:)];
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
            [queue addOperation:request];
        }
        if ([[[_arrGallerySearch objectAtIndex:i] allKeys] containsObject:@"dish"]) {
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/dishes/%@", urlReal, [[_arrGallerySearch objectAtIndex:i] objectForKey:@"dish"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            
            __weak typeof(ASIHTTPRequest *) weakSelf = request;
            
            [request setCompletionBlock:^{
                [self requestDishDidFinish:weakSelf];
            }];
            
            [request setFailedBlock:^{
                [self requestDishDidFail:weakSelf];
            }];
            
//            [request setDidFinishSelector:@selector(requestDishDidFinish:)];
//            [request setDidFailSelector:@selector(requestDishDidFail:)];
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
            [queueDish addOperation:request];
        }
        
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/snaps/%@/likes", urlReal, [[_arrGallerySearch objectAtIndex:i] objectForKey:@"_id"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        
        __weak typeof(ASIHTTPRequest *) weakSelf = request;
        
        [request setCompletionBlock:^{
            [self requestLoadLikeDidFinish:weakSelf];
        }];
        
        [request setFailedBlock:^{
            [self requestLoadLikeDidFail:weakSelf];
        }];
        
//        [request setDidFinishSelector:@selector(requestLoadLikeDidFinish:)];
//        [request setDidFailSelector:@selector(requestLoadLikeDidFail:)];
//        request.delegate = self;
        
        [request setRequestMethod:@"GET"];
        [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
        
        [request setUseCookiePersistence:NO];
        [request setUseSessionPersistence:NO];
        
        if (cookie) {
            [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
        }
        
        [request addRequestHeader:@"Vary" value:@"Accept-Encoding"];
        [request addRequestHeader:@"X-Powered-By" value:@"Express"];
        [queueLikes addOperation:request];
    }
    
    [queue setQueueDidFinishSelector:@selector(queueDidFinish:)];
    
    if (queue.operations.count > 0) {
        [queue go];
    }
    
    [queueDish setQueueDidFinishSelector:@selector(queueDishDidFinish:)];
    
    if (queueDish.operations.count > 0) {
        [queueDish go];
    }
    
    [queueLikes setQueueDidFinishSelector:@selector(queueLikesDidFinish:)];
    
    if (queueLikes.operations.count > 0) {
        [queueLikes go];
    }
    
    SAFE_RELEASE_VIEW(_searchGalleryView);
    
    if (_arrGallerySearch.count > 0) {
        _searchGalleryView      = [[WCGalleryView alloc] initWithImages:arrImv frame:CGRectMake(0.0f, 0.0f, 140.0f, 140.0f)];
        _searchGalleryView.backgroundColor     = [UIColor clearColor];
        _searchGalleryView.center = CGPointMake(_resultSearchView.frame.size.width/2, _resultSearchView.frame.size.height/2 - 60);
        _searchGalleryView.borderColor         = [UIColor whiteColor];
        _searchGalleryView.borderWidth         = 3.0f;
        _searchGalleryView.shadowColor         = [UIColor blackColor];
        _searchGalleryView.shadowOffset        = CGSizeMake(1.0f, 2.0f);
        _searchGalleryView.shadowOpacity       = 0.5f;
        _searchGalleryView.shadowRadius        = 2.0f;
        _searchGalleryView.stackRadiusOffset   = 9.0f;
        _searchGalleryView.animationDuration   = 0.3f;
        _searchGalleryView.stackRadiusDirection = WCGalleryStackRadiusRandom;
        _searchGalleryView.animationType        = WCGalleryAnimationFade;
        _searchGalleryView.delegate = self;
        
        [_resultSearchView addSubview:_searchGalleryView];
    }
    
    [self.view bringSubviewToFront:_resultSearchView];
    
    [UIView animateWithDuration:0.35 animations:^{
        _resultSearchView.frame = CGRectMake(0, _resultSearchView.frame.origin.y, _resultSearchView.frame.size.width, _resultSearchView.frame.size.height);
    } completion:^(BOOL finished) {
        currentSelectSearch = -1;
        [_tblSearch reloadData];
        
        [MBProgressHUD hideAllHUDsForView:[kApplicationDelegate window] animated:YES];
    }];
    
}

-(void)requestListSearchDishDidFail:(ASIHTTPRequest *)request{
    NSString *theJSON = [request responseString];
    NSLog(@"requestListSearchDishDidFail:%@", theJSON);
    
    if (![ASIHTTPRequest isNetworkReachable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Whoops! No Internet connection found. Please check your connection or try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    currentSelectSearch = indexPath.row;
    [_tblSearch reloadData];
    
    UIBarButtonItem *itemLeft = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_icon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(menuBarButtonClicked)];
    [itemLeft setTintColor:[UIColor whiteColor]];
    self.topBarItem.leftBarButtonItem = itemLeft;
    self.topBarItem.rightBarButtonItem = nil;
    
    if (isIOS7) {
        [itemLeft setTintColor:[UIColor colorWithRed:120.0/255 green:120.0/255 blue:120.0/255 alpha:1.0]];
    }
    
    [MBProgressHUD showHUDAddedTo:[kApplicationDelegate window] animated:YES];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/snaps?[{\"dish\":\"%@\"},{}]", urlReal, [[arrSearch objectAtIndex:indexPath.row] objectForKey:@"_id"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    __weak typeof(ASIHTTPRequest *) weakSelf = request;
    
    [request setCompletionBlock:^{
        [self requestListSearchDishDidFinish:weakSelf];
    }];
    
    [request setFailedBlock:^{
        [self requestListSearchDishDidFail:weakSelf];
    }];
    
//    [request setDidFinishSelector:@selector(requestListSearchDishDidFinish:)];
//    [request setDidFailSelector:@selector(requestListSearchDishDidFail:)];
//    request.delegate = self;
    
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
    
    _lblSearchDishName.text = [[arrSearch objectAtIndex:indexPath.row] objectForKey:@"name"];
    
    return;
    
    NSMutableArray *arrImv = [[NSMutableArray alloc] init];
    
    SAFE_RELEASE_ARRAY(_arrGallerySearch);
    _arrGallerySearch = [[NSMutableArray alloc] init];
    for (int i=0; i<_arrNews.count; i++) {
        if ([[[_arrNews objectAtIndex:i] allKeys] containsObject:@"dishData"]) {
            if ([[[[_arrNews objectAtIndex:i] objectForKey:@"dishData"] objectForKey:@"_id"] isEqualToString:[[arrSearch objectAtIndex:indexPath.row] objectForKey:@"_id"]]) {
                [arrImv addObject:[UIImage imageWithContentsOfFile:[pathDir stringByAppendingPathComponent:[[[[_arrNews objectAtIndex:i] objectForKey:@"image"] componentsSeparatedByString:@"/"] lastObject]]]];
                
                [_arrGallerySearch addObject:[_arrNews objectAtIndex:i]];
            }
        }
    }
    
    _lblSearchDishName.text = [[arrSearch objectAtIndex:indexPath.row] objectForKey:@"name"];
    
    SAFE_RELEASE_VIEW(_searchGalleryView);
    
    if (_arrGallerySearch.count > 0) {
        _searchGalleryView      = [[WCGalleryView alloc] initWithImages:arrImv frame:CGRectMake(0.0f, 0.0f, 140.0f, 140.0f)];
        _searchGalleryView.backgroundColor     = [UIColor clearColor];
        _searchGalleryView.center = CGPointMake(_resultSearchView.frame.size.width/2, _resultSearchView.frame.size.height/2 - 60);
        _searchGalleryView.borderColor         = [UIColor whiteColor];
        _searchGalleryView.borderWidth         = 3.0f;
        _searchGalleryView.shadowColor         = [UIColor blackColor];
        _searchGalleryView.shadowOffset        = CGSizeMake(1.0f, 2.0f);
        _searchGalleryView.shadowOpacity       = 0.5f;
        _searchGalleryView.shadowRadius        = 2.0f;
        _searchGalleryView.stackRadiusOffset   = 9.0f;
        _searchGalleryView.animationDuration   = 0.3f;
        _searchGalleryView.stackRadiusDirection = WCGalleryStackRadiusRandom;
        _searchGalleryView.animationType        = WCGalleryAnimationFade;
        _searchGalleryView.delegate = self;
        
        [_resultSearchView addSubview:_searchGalleryView];
    }
    
    [self.view bringSubviewToFront:_resultSearchView];
    
    [UIView animateWithDuration:0.35 animations:^{
        _resultSearchView.frame = CGRectMake(0, _resultSearchView.frame.origin.y, _resultSearchView.frame.size.width, _resultSearchView.frame.size.height);
    } completion:^(BOOL finished) {
        currentSelectSearch = -1;
        [_tblSearch reloadData];
        
        [MBProgressHUD hideAllHUDsForView:[kApplicationDelegate window] animated:YES];
    }];
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5.0, 4.0, 5.0, 4.0);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == _leftCollectionView) {
        return _arrNews.count;
    }
    
    return _arrTrends.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	return CGSizeMake(153.0, 197.0);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FACellDish *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FACellDish" forIndexPath:indexPath];
    cell.cellDelegate = self;
    cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    
    if (collectionView == _leftCollectionView) {
        cell.remColum = [NSNumber numberWithInt:1];
        cell.remRow = [NSNumber numberWithInt:(int)indexPath.row];
        
        
        if (![cell viewWithTag:999]) {
            UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            indicator.center = cell.image.center;
            indicator.tag = 999;
            [cell addSubview:indicator];
        }
        
        [(UIActivityIndicatorView *)[cell viewWithTag:999] startAnimating];
        
        
        
        __weak typeof(FACellDish *) weakSelf = cell;
        if ([[NSFileManager defaultManager] fileExistsAtPath:[pathDir stringByAppendingPathComponent:[[[[_arrNews objectAtIndex:indexPath.row] objectForKey:@"image"] componentsSeparatedByString:@"/"] lastObject]]]) {
            [(UIActivityIndicatorView *)[weakSelf viewWithTag:999] stopAnimating];
            [(UIActivityIndicatorView *)[weakSelf viewWithTag:999] removeFromSuperview];
            
            cell.image.image = [UIImage imageWithContentsOfFile:[pathDir stringByAppendingPathComponent:[[[[_arrNews objectAtIndex:indexPath.row] objectForKey:@"image"] componentsSeparatedByString:@"/"] lastObject]]];
        }
        else{
            [cell.image setImageWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/%@", urlReal, [[_arrNews objectAtIndex:indexPath.row] objectForKey:@"image"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                [(UIActivityIndicatorView *)[weakSelf viewWithTag:999] stopAnimating];
                [(UIActivityIndicatorView *)[weakSelf viewWithTag:999] removeFromSuperview];
            }];
        }
        
        
        if ([[[_arrNews objectAtIndex:indexPath.row] allKeys] containsObject:@"restData"]) {
            cell.subLabel.text = [[[_arrNews objectAtIndex:indexPath.row] objectForKey:@"restData"] objectForKey:@"name"];
        }
        
        if ([[[_arrNews objectAtIndex:indexPath.row] allKeys] containsObject:@"dishData"]) {
            cell.label.text = [[[_arrNews objectAtIndex:indexPath.row] objectForKey:@"dishData"] objectForKey:@"name"];
        }
        
        if ([[[_arrNews objectAtIndex:indexPath.row] allKeys] containsObject:@"rating"]) {
            cell.averRatingStar.hidden = NO;
            cell.averRatingStar.rating = [[[_arrNews objectAtIndex:indexPath.row] objectForKey:@"rating"] intValue];
        }
        else{
            cell.averRatingStar.hidden = YES;
        }
        
        if ([[[_arrNews objectAtIndex:indexPath.row] allKeys] containsObject:@"likeData"]) {
            cell.heartImage.hidden = NO;
            cell.countLikeLabel.hidden = NO;
            cell.countLikeLabel.text = [NSString stringWithFormat:@"%d", (int)[[[_arrNews objectAtIndex:indexPath.row] objectForKey:@"likeData"] count]];
            
            if ([[[_arrNews objectAtIndex:indexPath.row] objectForKey:@"likeData"] count] == 0) {
                cell.countLikeLabel.hidden = YES;
                cell.heartImage.hidden = YES;
            }
            
            BOOL _flagHaveMyLike = NO;
            NSMutableArray *tmp = [[_arrNews objectAtIndex:indexPath.row] objectForKey:@"likeData"];
            for (int i=0; i < tmp.count; i++) {
                if ([[[tmp objectAtIndex:i] objectForKey:@"createdBy"] isEqualToString:[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] objectForKey:@"_id"]]) {
                    _flagHaveMyLike = YES;
                    break;
                }
            }
            
            if (_flagHaveMyLike) {
                cell.heartImage.image = [UIImage imageNamed:@"big_heart.png"];
            }
            else{
                cell.heartImage.image = [UIImage imageNamed:@"heart.png"];
            }
        }
        else{
            cell.heartImage.hidden = YES;
            cell.countLikeLabel.hidden = YES;
        }
        
    }
    else{
        cell.remColum = [NSNumber numberWithInt:2];
        cell.remRow = [NSNumber numberWithInt:(int)indexPath.row];
        
        if (![cell viewWithTag:999]) {
            UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            indicator.center = cell.image.center;
            indicator.tag = 999;
            [cell addSubview:indicator];
        }
        
        [(UIActivityIndicatorView *)[cell viewWithTag:999] startAnimating];
        
        __weak typeof(FACellDish *) weakSelf = cell;
        [cell.image setImageWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/%@", urlReal, [[_arrTrends objectAtIndex:indexPath.row] objectForKey:@"image"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            [(UIActivityIndicatorView *)[weakSelf viewWithTag:999] stopAnimating];
            [(UIActivityIndicatorView *)[weakSelf viewWithTag:999] removeFromSuperview];
        }];
        
        if ([[[_arrTrends objectAtIndex:indexPath.row] allKeys] containsObject:@"restData"]) {
            cell.subLabel.text = [[[_arrTrends objectAtIndex:indexPath.row] objectForKey:@"restData"] objectForKey:@"name"];
        }
        
        if ([[[_arrTrends objectAtIndex:indexPath.row] allKeys] containsObject:@"dishData"]) {
            cell.label.text = [[[_arrTrends objectAtIndex:indexPath.row] objectForKey:@"dishData"] objectForKey:@"name"];
        }
        
        if ([[[_arrTrends objectAtIndex:indexPath.row] allKeys] containsObject:@"rating"]) {
            cell.averRatingStar.hidden = NO;
            cell.averRatingStar.rating = [[[_arrTrends objectAtIndex:indexPath.row] objectForKey:@"rating"] intValue];
        }
        else{
            cell.averRatingStar.hidden = YES;
        }
        
        if ([[[_arrTrends objectAtIndex:indexPath.row] allKeys] containsObject:@"likeData"]) {
            cell.heartImage.hidden = NO;
            cell.countLikeLabel.hidden = NO;
            cell.countLikeLabel.text = [NSString stringWithFormat:@"%d", (int)[[[_arrTrends objectAtIndex:indexPath.row] objectForKey:@"likeData"] count]];
            
            if ([[[_arrTrends objectAtIndex:indexPath.row] objectForKey:@"likeData"] count] == 0) {
                cell.countLikeLabel.hidden = YES;
                cell.heartImage.hidden = YES;
            }
            
            BOOL _flagHaveMyLike = NO;
            NSMutableArray *tmp = [[_arrTrends objectAtIndex:indexPath.row] objectForKey:@"likeData"];
            for (int i=0; i < tmp.count; i++) {
                if ([[[tmp objectAtIndex:i] objectForKey:@"createdBy"] isEqualToString:[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] objectForKey:@"_id"]]) {
                    _flagHaveMyLike = YES;
                    break;
                }
            }
            
            if (_flagHaveMyLike) {
                cell.heartImage.image = [UIImage imageNamed:@"big_heart.png"];
            }
            else{
                cell.heartImage.image = [UIImage imageNamed:@"heart.png"];
            }
        }
        else{
            cell.heartImage.hidden = YES;
            cell.countLikeLabel.hidden = YES;
        }
    }
    
    if (!_isLoadingMore) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.75];
        
        if (_lastScrollPosition.y > _currentScrollPosition.y) {
            cell.layer.transform = CATransform3DMakeTranslation(0.0, -15.0, 0.0);
        }
        else{
            cell.layer.transform = CATransform3DMakeTranslation(0.0, 15.0, 0.0);
        }
        
        cell.layer.transform = CATransform3DIdentity;
        cell.layer.opacity = 1.0f;
        
        [UIView commitAnimations];
    }
    
    
	return cell;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    static NSString *identifier = @"MyLocation";
    if ([annotation isKindOfClass:[MyLocation class]]) {
        MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if(annotationView){
            if ([[annotation title] isEqualToString:@"My Location"]) {
                annotationView.image = [UIImage imageNamed:@"currentpin.png"];
            }
            else{
                annotationView.image = [UIImage imageNamed:@"btnMap.png"];
            }
            return annotationView;
        }
        else
        {
            MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.canShowCallout = YES;
            if ([[annotation title] isEqualToString:@"My Location"]) {
                annotationView.image = [UIImage imageNamed:@"currentpin.png"];
            }
            else{
                annotationView.image = [UIImage imageNamed:@"btnMap.png"];
            }
            
            return annotationView;
        }
        return annotationView;
    }
    
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.menuView.frame.origin.y > 0) {
        [UIView animateWithDuration:0.35 animations:^{
            self.menuView.frame = CGRectMake(0, -120.0, self.menuView.frame.size.width, self.menuView.frame.size.height);
        }];
        
        return;
    }
    
    _topBarItem.titleView = nil;
    _isOpeningDetail = YES;
    
    if (collectionView == _leftCollectionView) {
        
        _isOpenRightSide = NO;
        
        FACellDish *cell = (FACellDish *)[_leftCollectionView cellForItemAtIndexPath:indexPath];
        NSLog(@"co:%f", _leftCollectionView.contentOffset.y);
        
        
        UIImageView *imvView = [cell image];
    
        UIImage *imv = imvView.image;
        
        self.imvFull.image = imv;
        
        UIBarButtonItem *itemLeft = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_icon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(menuBarButtonClicked)];
        [itemLeft setTintColor:[UIColor whiteColor]];
        self.topBarItem.leftBarButtonItem = itemLeft;
        
        if (isIOS7) {
            [itemLeft setTintColor:[UIColor colorWithRed:120.0/255 green:120.0/255 blue:120.0/255 alpha:1.0]];
        }
        
        SAFE_RELEASE_VIEW(imvZoom)
        imvZoom = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imvView.frame.size.width, imvView.frame.size.height)];
        imvZoom.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:imvZoom];
        imvZoom.image = imv;
        
        CGRect frame = CGRectMake(imvView.frame.origin.x,
                                  cell.frame.origin.y - _leftCollectionView.contentOffset.y,
                                  imvView.frame.size.width,
                                  imvView.frame.size.height);
        
        SAFE_RELEASE_ARRAY(tmpArrData);
        tmpArrData = [[NSMutableArray alloc] init];
        
        imvZoom.frame = CGRectMake(_leftCollectionView.frame.origin.x + 4, frame.origin.y + self.contentView.frame.origin.y , imvZoom.frame.size.width, imvZoom.frame.size.height);
        
        _currentIndex = indexPath.row;
        
        for (NSInteger i = _currentIndex; i < _arrNews.count; i++) {
            [tmpArrData addObject:[_arrNews objectAtIndex:i]];
        }
        for (int i = 0; i < _currentIndex; i++) {
            [tmpArrData addObject:[_arrNews objectAtIndex:i]];
        }
        imvZoom.hidden = NO;
        
        CGAffineTransform t = CGAffineTransformMakeScale(1.8, 1.8);
        remPoint = CGPointMake(imvZoom.center.x, imvZoom.center.y);
        
        for (int i=4-1; i>=0; i--) {
            MxoDoubleSidedView *vGr = (MxoDoubleSidedView *)[_scrollList viewWithTag:i+1111];
            SAFE_RELEASE_VIEW(vGr);
        }
        
        SAFE_RELEASE_VIEW(doubleSide);
        
        _currentItemDishData = [tmpArrData objectAtIndex:0];
        NSInteger countTotalLike = 0;
        
        if ([[_currentItemDishData allKeys] containsObject:@"likeData"]) {
            countTotalLike = [[_currentItemDishData objectForKey:@"likeData"] count];
            if ([[_currentItemDishData objectForKey:@"likeData"] count] == 0) {
                countTotalLike = 0;
            }
        }
        else{
            countTotalLike = 0;
        }
        
        NSInteger indexCount = 4;
        if (tmpArrData.count < indexCount) {
            indexCount = tmpArrData.count;
        }
        
        viewControllerArray = [[NSMutableArray alloc] initWithCapacity:_arrNews.count];
        for (NSUInteger k = 0; k < _arrNews.count; ++k) {
            [viewControllerArray addObject:[NSNull null]];
        }
        
        SAFE_RELEASE_VIEW(_scrollList);
        // PREPARE LAZY VIEW
        CGRect rect = CGRectMake(0, 0, 320.0, self.detailView.frame.size.height);
        _scrollList = [[DMLazyScrollView alloc] initWithFrame:rect];
        [_scrollList setEnableCircularScroll:NO];
        [_scrollList setAutoPlay:NO];
        _scrollList.controlDelegate = self;
        
        __weak __typeof(&*self)weakSelf = self;
        _scrollList.dataSource = ^(NSUInteger index) {
            return [weakSelf controllerAtIndex:index];
        };
        _scrollList.numberOfPages = _arrNews.count;
        // lazyScrollView.controlDelegate = self;
        [self.detailView addSubview:_scrollList];
        
        [_scrollList setPage:_currentIndex animated:NO];
        
        float posY = self.imvFull.center.y + (44.0 + addIOS7);
        if (!IS_IPHONE5) {
            posY = self.imvFull.center.y + (44.0 + addIOS7) + 44.0;
        }
        
        [UIView animateWithDuration:0.5 animations:^{
            self.contentView.frame = CGRectMake(-320, self.contentView.frame.origin.y, 320, self.contentView.frame.size.height);
            imvZoom.transform = t;
            imvZoom.center = CGPointMake(self.imvFull.center.x, posY);
            self.cameraButton.alpha = 0.0;
            
        } completion:^(BOOL finished) {
            self.detailView.alpha = 1.0;
            
            [imvZoom setHidden:YES];
        }];
    }
    else if (collectionView == _rightCollectionView) {
        
        _isOpenRightSide = YES;
        
        FACellDish *cell = (FACellDish *)[_rightCollectionView cellForItemAtIndexPath:indexPath];
        NSLog(@"co:%f", _rightCollectionView.contentOffset.y);
        
        
        UIImageView *imvView = [cell image];
        
        UIImage *imv = imvView.image;
        
        self.imvFull.image = imv;
        
        UIBarButtonItem *itemLeft = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_icon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(menuBarButtonClicked)];
        [itemLeft setTintColor:[UIColor whiteColor]];
        self.topBarItem.leftBarButtonItem = itemLeft;
        
        if (isIOS7) {
            [itemLeft setTintColor:[UIColor colorWithRed:120.0/255 green:120.0/255 blue:120.0/255 alpha:1.0]];
        }
        
        SAFE_RELEASE_VIEW(imvZoom)
        imvZoom = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imvView.frame.size.width, imvView.frame.size.height)];
        imvZoom.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:imvZoom];
        imvZoom.image = imv;
        
        CGRect frame = CGRectMake(imvView.frame.origin.x,
                                  cell.frame.origin.y - _rightCollectionView.contentOffset.y,
                                  imvView.frame.size.width,
                                  imvView.frame.size.height);
        
        SAFE_RELEASE_ARRAY(tmpArrData);
        tmpArrData = [[NSMutableArray alloc] init];
        
        imvZoom.frame = CGRectMake(_rightCollectionView.frame.origin.x + 4, frame.origin.y + self.contentView.frame.origin.y , imvZoom.frame.size.width, imvZoom.frame.size.height);
        
        _currentIndex = indexPath.row;
        
        for (NSInteger i = _currentIndex; i < _arrTrends.count; i++) {
            [tmpArrData addObject:[_arrTrends objectAtIndex:i]];
        }
        for (int i = 0; i < _currentIndex; i++) {
            [tmpArrData addObject:[_arrTrends objectAtIndex:i]];
        }
        imvZoom.hidden = NO;
        
        CGAffineTransform t = CGAffineTransformMakeScale(1.8, 1.8);
        remPoint = CGPointMake(imvZoom.center.x, imvZoom.center.y);
        
        for (int i=4-1; i>=0; i--) {
            MxoDoubleSidedView *vGr = (MxoDoubleSidedView *)[_scrollList viewWithTag:i+1111];
            SAFE_RELEASE_VIEW(vGr);
        }
        
        SAFE_RELEASE_VIEW(doubleSide);
        
        _currentItemDishData = [tmpArrData objectAtIndex:0];
        NSInteger countTotalLike = 0;
        
        if ([[_currentItemDishData allKeys] containsObject:@"likeData"]) {
            countTotalLike = [[_currentItemDishData objectForKey:@"likeData"] count];
            if ([[_currentItemDishData objectForKey:@"likeData"] count] == 0) {
                countTotalLike = 0;
            }
        }
        else{
            countTotalLike = 0;
        }
        
        NSInteger indexCount = 4;
        if (tmpArrData.count < indexCount) {
            indexCount = tmpArrData.count;
        }
        
        viewControllerArray = [[NSMutableArray alloc] initWithCapacity:_arrTrends.count];
        for (NSUInteger k = 0; k < _arrTrends.count; ++k) {
            [viewControllerArray addObject:[NSNull null]];
        }
        
        SAFE_RELEASE_VIEW(_scrollList);
        // PREPARE LAZY VIEW
        CGRect rect = CGRectMake(0, 0, 320.0, self.detailView.frame.size.height);
        _scrollList = [[DMLazyScrollView alloc] initWithFrame:rect];
        [_scrollList setEnableCircularScroll:NO];
        [_scrollList setAutoPlay:NO];
        _scrollList.controlDelegate = self;
        
        __weak __typeof(&*self)weakSelf = self;
        _scrollList.dataSource = ^(NSUInteger index) {
            return [weakSelf controllerAtIndex:index];
        };
        _scrollList.numberOfPages = _arrTrends.count;
        // lazyScrollView.controlDelegate = self;
        [self.detailView addSubview:_scrollList];
        
        [_scrollList setPage:_currentIndex animated:NO];
        
        float posY = self.imvFull.center.y + (44.0 + addIOS7);
        if (!IS_IPHONE5) {
            posY = self.imvFull.center.y + (44.0 + addIOS7) + 44.0;
        }
        
        [UIView animateWithDuration:0.5 animations:^{
            self.contentView.frame = CGRectMake(-320, self.contentView.frame.origin.y, 320, self.contentView.frame.size.height);
            imvZoom.transform = t;
            imvZoom.center = CGPointMake(self.imvFull.center.x, posY);
            self.cameraButton.alpha = 0.0;
            
        } completion:^(BOOL finished) {
            self.detailView.alpha = 1.0;
            
            [imvZoom setHidden:YES];
        }];
    }
}

-(void)postToWallFinish:(ASIHTTPRequest *)request{
    NSString *theJSON = [request responseString];
    NSLog(@"postToWallFinish:%@", theJSON);
    
    
}

-(void)postToWallFail:(ASIHTTPRequest *)request{
    NSString *theJSON = [request responseString];
    NSLog(@"postToWallFail:%@", theJSON);
    
    
}

-(void)requestMyLikeDishDidFinish:(ASIHTTPRequest *)request{
    NSString *theJSON = [request responseString];
    NSLog(@"requestMyLikeDishDidFinish:%@", theJSON);
    
//    FBRequestConnection *newConnection = [[FBRequestConnection alloc] init];
//    
//    FBRequestHandler handler =
//    ^(FBRequestConnection *connection, id result, NSError *error) {
//        
//    };
//    
//    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
//                                   @"pippo", @"message",
//                                   nil];
//    
//    FBRequest *requestFB = [[FBRequest alloc] initWithSession:FBSession.activeSession graphPath:@"me/feed" parameters:params HTTPMethod:@"POST"];
//    [newConnection addRequest:requestFB completionHandler:handler];
//    [newConnection start];
    
    NSInteger index = [[[request requestHeaders] objectForKey:@"snapIndex"] intValue];
    
//    NSString *accessToken = [FBSession activeSession].accessToken;
//    accessToken = [accessToken stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSDictionary *imageShare;
//    
//    NSDictionary* attachment;
//    
//    if (_isOpenRightSide) {
//        imageShare = [NSDictionary dictionaryWithObjectsAndKeys:
//                      @"image", @"type",
//                      [NSString stringWithFormat:@"http://%@/%@", urlReal, [[_arrTrends objectAtIndex:index] objectForKey:@"image"]], @"src",
//                      [NSString stringWithFormat:@"http://%@/%@", urlReal, [[_arrTrends objectAtIndex:index] objectForKey:@"image"]], @"href",
//                      nil];
//        
//        attachment = [NSDictionary dictionaryWithObjectsAndKeys:
//                      [[[_arrTrends objectAtIndex:index] objectForKey:@"dishData"] objectForKey:@"name"], @"name",
//                      @"", @"caption",
//                      [[[_arrTrends objectAtIndex:index] objectForKey:@"restData"] objectForKey:@"name"], @"description",
//                      [NSString stringWithFormat:@"http://%@/%@", urlReal, [[_arrTrends objectAtIndex:index] objectForKey:@"image"]], @"href",
//                      [NSArray arrayWithObjects:imageShare, nil ], @"media",
//                      nil];
//    }
//    else{
//        imageShare = [NSDictionary dictionaryWithObjectsAndKeys:
//                      @"image", @"type",
//                      [NSString stringWithFormat:@"http://%@/%@", urlReal, [[_arrNews objectAtIndex:index] objectForKey:@"image"]], @"src",
//                      [NSString stringWithFormat:@"http://%@/%@", urlReal, [[_arrNews objectAtIndex:index] objectForKey:@"image"]], @"href",
//                      nil];
//        
//        attachment = [NSDictionary dictionaryWithObjectsAndKeys:
//                      [[[_arrNews objectAtIndex:index] objectForKey:@"dishData"] objectForKey:@"name"], @"name",
//                      @"", @"caption",
//                      [[[_arrNews objectAtIndex:index] objectForKey:@"restData"] objectForKey:@"name"], @"description",
//                      [NSString stringWithFormat:@"http://%@/%@", urlReal, [[_arrNews objectAtIndex:index] objectForKey:@"image"]], @"href",
//                      [NSArray arrayWithObjects:imageShare, nil ], @"media",
//                      nil];
//    }
//    NSString *attachmentStr = [attachment JSONRepresentation];
//    
//    NSString *myid = [kApplicationDelegate userFBId];
//    
//    ASIHTTPRequest *postWall = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.facebook.com/method/stream.publish?message=%@&target_id=%@&uid=%@&attachment=%@&access_token=%@", @"", myid, myid,[attachmentStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], accessToken]]];
//    [postWall setDelegate:self];
//    [postWall setDidFinishSelector:@selector(postToWallFinish:)];
//    [postWall setDidFailSelector:@selector(postToWallFail:)];
//    [postWall startAsynchronous];
    
    
    
    UIViewController *controller = [viewControllerArray objectAtIndex:index];
    if ([controller isKindOfClass:[NSNull class]]) return;
    MxoDoubleSidedView *vGr = (MxoDoubleSidedView *)[controller.view viewWithTag:1111 + index];
    if (doubleSide) {
        vGr = doubleSide;
    }
    UIView *vFront = [[vGr frontSubviews] objectAtIndex:0];
    [[vFront viewWithTag:9] removeFromSuperview];
    [[vFront viewWithTag:10] removeFromSuperview];
    [[vFront viewWithTag:11] removeFromSuperview];
    [[vFront viewWithTag:12] removeFromSuperview];
    [[vFront viewWithTag:13] removeFromSuperview];
    [[vFront viewWithTag:14] removeFromSuperview];
    [[vFront viewWithTag:15] removeFromSuperview];
    [[vFront viewWithTag:16] removeFromSuperview];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *userData = [[NSDictionary alloc] initWithDictionary:[[parser objectWithString:theJSON] objectForKey:@"data"]];
    
    if (!_arrLikes) {
        _arrLikes = [[NSMutableArray alloc] init];
    }
    [_arrLikes addObject:userData];
    
    ASIHTTPRequest *requestL = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/snaps/%@/likes", urlReal, [userData objectForKey:@"snap"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    __weak typeof(ASIHTTPRequest *) weakSelf = requestL;
    
    [requestL setCompletionBlock:^{
        [self requestLoadLikeDidFinish:weakSelf];
    }];
    
    [requestL setFailedBlock:^{
        [self requestLoadLikeDidFail:weakSelf];
    }];
    
//    [requestL setDidFinishSelector:@selector(requestLoadLikeDidFinish:)];
//    [requestL setDidFailSelector:@selector(requestLoadLikeDidFail:)];
//    requestL.delegate = self;
    [requestL setRequestMethod:@"GET"];
    [requestL addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    
    [requestL setUseCookiePersistence:NO];
    [requestL setUseSessionPersistence:NO];
    
    if (cookie) {
        [requestL setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
    }
    
    [requestL addRequestHeader:@"Vary" value:@"Accept-Encoding"];
    [requestL addRequestHeader:@"X-Powered-By" value:@"Express"];
    [requestL startAsynchronous];
    
    if (_arrLikes.count > 0) {
        float posY = 265 + 73;
        if (!IS_IPHONE5) {
            posY = 245 + 60;
        }
        
        [[vFront viewWithTag:9] removeFromSuperview];
        [[vFront viewWithTag:10] removeFromSuperview];
        [[vFront viewWithTag:11] removeFromSuperview];
        [[vFront viewWithTag:12] removeFromSuperview];
        [[vFront viewWithTag:13] removeFromSuperview];
        [[vFront viewWithTag:14] removeFromSuperview];
        [[vFront viewWithTag:15] removeFromSuperview];
        [[vFront viewWithTag:16] removeFromSuperview];
        
        UIButton *imvHeart = [[UIButton alloc] initWithFrame:CGRectMake(35, posY, 23, 22)];
        [imvHeart setImage:[UIImage imageNamed:@"big_heart.png"] forState:UIControlStateNormal];
        imvHeart.tag = 9;
        [vFront addSubview:imvHeart];
        
        UILabel *countLike = [[UILabel alloc] initWithFrame:CGRectMake(66, posY, 51, 22)];
        countLike.backgroundColor = [UIColor clearColor];
        [countLike setTextColor:[UIColor colorWithRed:96.0/255 green:99.0/255 blue:102.0/255 alpha:1.0]];
        [countLike setFont:[UIFont fontWithName:@"Roboto-Light" size:24.0]];
        countLike.text = @"";
        countLike.tag = 10;
        [vFront addSubview:countLike];
        
        UILabel *namesLike = [[UILabel alloc] initWithFrame:CGRectMake(20, posY + 57, 249, 20)];
        namesLike.backgroundColor = [UIColor clearColor];
        [namesLike setTextColor:[UIColor colorWithRed:96.0/255 green:99.0/255 blue:102.0/255 alpha:1.0]];
        [namesLike setFont:[UIFont fontWithName:@"Roboto-Regular" size:9.0]];
        namesLike.text = @"";
        namesLike.tag = 11;
        [vFront addSubview:namesLike];
        
        UIImageView *imvLikePerson1 = [[UIImageView alloc] initWithFrame:CGRectMake(20, posY + 35, 20, 20)];
        imvLikePerson1.backgroundColor = [UIColor clearColor];
        imvLikePerson1.layer.cornerRadius = 10.0;
        imvLikePerson1.tag = 12;
        [vFront addSubview:imvLikePerson1];
        
        UIImageView *imvLikePerson2 = [[UIImageView alloc] initWithFrame:CGRectMake(45, posY + 35, 20, 20)];
        imvLikePerson2.backgroundColor = [UIColor clearColor];
        imvLikePerson2.layer.cornerRadius= 10.0;
        imvLikePerson2.tag = 13;
        [vFront addSubview:imvLikePerson2];
        
        UIImageView *imvLikePerson3 = [[UIImageView alloc] initWithFrame:CGRectMake(70, posY + 35, 20, 20)];
        imvLikePerson3.backgroundColor = [UIColor clearColor];
        imvLikePerson3.layer.cornerRadius= 10.0;
        imvLikePerson3.tag = 14;
        [vFront addSubview:imvLikePerson3];
        
        UIImageView *imvLikePersonMore = [[UIImageView alloc] initWithFrame:CGRectMake(97, posY + 35 + 8, 15, 4)];
        imvLikePersonMore.image = [UIImage imageNamed:@"3dot.png"];
        imvLikePersonMore.tag = 15;
        [vFront addSubview:imvLikePersonMore];
        
        BOOL flagMyHadLiked = NO;
        for (int j=0; j<_arrLikes.count; j++) {
            if ([[[_arrLikes objectAtIndex:j] objectForKey:@"createdBy"] isEqualToString:[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] objectForKey:@"_id"]]) {
                flagMyHadLiked = YES;
                break;
            }
        }
        
        if (!flagMyHadLiked) {
            
            [imvHeart setImage:[UIImage imageNamed:@"heart.png"] forState:UIControlStateNormal];
            [imvHeart addTarget:self action:@selector(likeDish:) forControlEvents:UIControlEventTouchUpInside];
        }
        else{
            
            [imvHeart setImage:[UIImage imageNamed:@"big_heart.png"] forState:UIControlStateNormal];
            [imvHeart addTarget:self action:@selector(unlikeDish:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        if (_arrLikes.count == 1) {
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/users/%@", urlReal, [[_arrLikes objectAtIndex:0] objectForKey:@"createdBy"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            
            __weak typeof(ASIHTTPRequest *) weakSelf = request;
            
            [request setCompletionBlock:^{
                [self request1UserLikeDidFinish:weakSelf];
            }];
            
            [request setFailedBlock:^{
                [self request1UserLikeDidFail:weakSelf];
            }];
            
//            [request setDidFinishSelector:@selector(request1UserLikeDidFinish:)];
//            [request setDidFailSelector:@selector(request1UserLikeDidFail:)];
//            request.delegate = self;
            [request setRequestMethod:@"GET"];
            [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
            
            [request setUseCookiePersistence:NO];
            [request setUseSessionPersistence:NO];
            
            if (cookie) {
                [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
            }
            
            [request addRequestHeader:@"snapIndex" value:[NSString stringWithFormat:@"%d", (int)_currentIndex]];
            
            [request addRequestHeader:@"Vary" value:@"Accept-Encoding"];
            [request addRequestHeader:@"X-Powered-By" value:@"Express"];
            [request startAsynchronous];
        }
        else if (_arrLikes.count > 1) {
            [_arrLikes sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:NO]]];
            
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/users/%@", urlReal, [[_arrLikes objectAtIndex:0] objectForKey:@"createdBy"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            
            __weak typeof(ASIHTTPRequest *) weakSelf = request;
            
            [request setCompletionBlock:^{
                [self request1UserLikeDidFinish:weakSelf];
            }];
            
            [request setFailedBlock:^{
                [self request1UserLikeDidFail:weakSelf];
            }];
            
//            [request setDidFinishSelector:@selector(request1UserLikeDidFinish:)];
//            [request setDidFailSelector:@selector(request1UserLikeDidFail:)];
//            request.delegate = self;
            [request setRequestMethod:@"GET"];
            [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
            
            [request setUseCookiePersistence:NO];
            [request setUseSessionPersistence:NO];
            
            if (cookie) {
                [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
            }
            
            [request addRequestHeader:@"snapIndex" value:[NSString stringWithFormat:@"%d", (int)_currentIndex]];
            
            [request addRequestHeader:@"Vary" value:@"Accept-Encoding"];
            [request addRequestHeader:@"X-Powered-By" value:@"Express"];
            [request startAsynchronous];
            
            ASINetworkQueue *queueUserLike = [[ASINetworkQueue alloc] init];
            queueUserLike.delegate = self;
            [queueUserLike setQueueDidFinishSelector:@selector(queueUserLikeDidFinished:)];
            for (int j=1; j<_arrLikes.count; j++) {
                ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/users/%@", urlReal, [[_arrLikes objectAtIndex:j] objectForKey:@"createdBy"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                
                __weak typeof(ASIHTTPRequest *) weakSelf = request;
                
                [request setCompletionBlock:^{
                    [self requestUserLikeDidFinish:weakSelf];
                }];
                
                [request setFailedBlock:^{
                    [self requestUserLikeDidFail:weakSelf];
                }];
                
//                [request setDidFinishSelector:@selector(requestUserLikeDidFinish:)];
//                [request setDidFailSelector:@selector(requestUserLikeDidFail:)];
//                request.delegate = self;
                
                [request setRequestMethod:@"GET"];
                [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
                
                [request setUseCookiePersistence:NO];
                [request setUseSessionPersistence:NO];
                
                if (cookie) {
                    [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
                }
                
                [request addRequestHeader:@"snapIndex" value:[NSString stringWithFormat:@"%d", (int)_currentIndex]];
                
                [request addRequestHeader:@"Vary" value:@"Accept-Encoding"];
                [request addRequestHeader:@"X-Powered-By" value:@"Express"];
                [queueUserLike addOperation:request];
            }
            
            if (queueUserLike.operationCount > 0) {
                [queueUserLike go];
            }
        }
        
        if (_arrLikes.count == 1) {
            imvLikePerson2.hidden = YES;
            imvLikePerson3.hidden = YES;
            imvLikePersonMore.hidden = YES;
        }
        else if (_arrLikes.count == 2) {
            imvLikePerson2.hidden = NO;
            imvLikePerson3.hidden = YES;
            imvLikePersonMore.hidden = YES;
        }
        else if (_arrLikes.count == 3) {
            imvLikePerson2.hidden = NO;
            imvLikePerson3.hidden = NO;
            imvLikePersonMore.hidden = YES;
        }
        else if (_arrLikes.count > 3) {
            imvLikePerson2.hidden = NO;
            imvLikePerson3.hidden = NO;
            imvLikePersonMore.hidden = NO;
        }
    }
    else{
        float posY = 265 + 73;
        if (!IS_IPHONE5) {
            posY = 245 + 60;
        }
        
        UIButton *imvHeart = [[UIButton alloc] initWithFrame:CGRectMake(35, posY, 23, 22)];
        [imvHeart setImage:[UIImage imageNamed:@"heart.png"] forState:UIControlStateNormal];
        imvHeart.tag = 9;
        [imvHeart addTarget:self action:@selector(likeDish:) forControlEvents:UIControlEventTouchUpInside];
        [vFront addSubview:imvHeart];
    }
    
    [MBProgressHUD hideAllHUDsForView:[kApplicationDelegate window] animated:YES];
}

-(void)requestMyLikeDishDidFail:(ASIHTTPRequest *)request{
    NSString *theJSON = [request responseString];
    NSLog(@"requestMyLikeDishDidFail:%@", theJSON);
    
    [MBProgressHUD hideAllHUDsForView:[kApplicationDelegate window] animated:YES];
    
    [self checkAndLogout401:request.responseStatusCode];
}

-(void)requestMyUnLikeDishDidFinish:(ASIHTTPRequest *)request{
    NSString *theJSON = [request responseString];
    NSLog(@"requestMyUnLikeDishDidFinish:%@", theJSON);
    
    NSInteger index = [[[request requestHeaders] objectForKey:@"snapIndex"] intValue];
    
    if (index > viewControllerArray.count-1) return;
    UIViewController *controller = [viewControllerArray objectAtIndex:index];
    if ([controller isKindOfClass:[NSNull class]]) return;
    MxoDoubleSidedView *vGr = (MxoDoubleSidedView *)[controller.view viewWithTag:1111 + index];
    if (doubleSide) {
        vGr = doubleSide;
    }
    
    if (!vGr) return;
    
    UIView *vFront = [[vGr frontSubviews] objectAtIndex:0];
    [[vFront viewWithTag:9] removeFromSuperview];
    [[vFront viewWithTag:10] removeFromSuperview];
    [[vFront viewWithTag:11] removeFromSuperview];
    [[vFront viewWithTag:12] removeFromSuperview];
    [[vFront viewWithTag:13] removeFromSuperview];
    [[vFront viewWithTag:14] removeFromSuperview];
    [[vFront viewWithTag:15] removeFromSuperview];
    [[vFront viewWithTag:16] removeFromSuperview];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *userData = [[NSDictionary alloc] initWithDictionary:[[parser objectWithString:theJSON] objectForKey:@"data"]];
    
    ASIHTTPRequest *requestL = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/snaps/%@/likes", urlReal, [userData objectForKey:@"snap"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    __weak typeof(ASIHTTPRequest *) weakSelf = requestL;
    
    [requestL setCompletionBlock:^{
        [self requestLoadLikeDidFinish:weakSelf];
    }];
    
    [requestL setFailedBlock:^{
        [self requestLoadLikeDidFail:weakSelf];
    }];
    
//    [requestL setDidFinishSelector:@selector(requestLoadLikeDidFinish:)];
//    [requestL setDidFailSelector:@selector(requestLoadLikeDidFail:)];
//    requestL.delegate = self;
    [requestL setRequestMethod:@"GET"];
    [requestL addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    
    [requestL setUseCookiePersistence:NO];
    [requestL setUseSessionPersistence:NO];
    
    if (cookie) {
        [requestL setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
    }
    
    [requestL addRequestHeader:@"Vary" value:@"Accept-Encoding"];
    [requestL addRequestHeader:@"X-Powered-By" value:@"Express"];
    [requestL startAsynchronous];
    
    if (_flagGotoDetailOnHaveMatch) {
        _currentItemDishData = [_arrGallerySearch objectAtIndex:0];
    }
    else{
        if (_isOpenRightSide) {
            _currentItemDishData = [_arrTrends objectAtIndex:_currentIndex];
        }
        else{
            _currentItemDishData = [_arrNews objectAtIndex:_currentIndex];
        }
    }
    
    NSMutableArray *tmp = [_currentItemDishData objectForKey:@"likeData"];
    for (int i=0; i < tmp.count; i++) {
        if ([[[tmp objectAtIndex:i] objectForKey:@"createdBy"] isEqualToString:[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] objectForKey:@"_id"]]) {
            [tmp removeObjectAtIndex:i];
            break;
        }
    }
    [_currentItemDishData setObject:tmp forKey:@"likeData"];
    
    SAFE_RELEASE_ARRAY(_arrLikes);
    _arrLikes = [[NSMutableArray alloc] initWithArray:tmp];
    
    if (_arrLikes.count > 0) {
        float posY = 265 + 73;
        if (!IS_IPHONE5) {
            posY = 245 + 60;
        }
        
        [[vFront viewWithTag:9] removeFromSuperview];
        [[vFront viewWithTag:10] removeFromSuperview];
        [[vFront viewWithTag:11] removeFromSuperview];
        [[vFront viewWithTag:12] removeFromSuperview];
        [[vFront viewWithTag:13] removeFromSuperview];
        [[vFront viewWithTag:14] removeFromSuperview];
        [[vFront viewWithTag:15] removeFromSuperview];
        [[vFront viewWithTag:16] removeFromSuperview];
        
        UIButton *imvHeart = [[UIButton alloc] initWithFrame:CGRectMake(35, posY, 23, 22)];
        [imvHeart setImage:[UIImage imageNamed:@"big_heart.png"] forState:UIControlStateNormal];
        imvHeart.tag = 9;
        [vFront addSubview:imvHeart];
        
        UILabel *countLike = [[UILabel alloc] initWithFrame:CGRectMake(66, posY, 51, 22)];
        countLike.backgroundColor = [UIColor clearColor];
        [countLike setTextColor:[UIColor colorWithRed:96.0/255 green:99.0/255 blue:102.0/255 alpha:1.0]];
        [countLike setFont:[UIFont fontWithName:@"Roboto-Light" size:24.0]];
        countLike.text = [NSString stringWithFormat:@"%d", (int)_arrLikes.count];
        countLike.tag = 10;
        [vFront addSubview:countLike];
        
        UILabel *namesLike = [[UILabel alloc] initWithFrame:CGRectMake(20, posY + 57, 249, 20)];
        namesLike.backgroundColor = [UIColor clearColor];
        [namesLike setTextColor:[UIColor colorWithRed:96.0/255 green:99.0/255 blue:102.0/255 alpha:1.0]];
        [namesLike setFont:[UIFont fontWithName:@"Roboto-Regular" size:9.0]];
        namesLike.text = @"";
        namesLike.tag = 11;
        [vFront addSubview:namesLike];
        
        UIImageView *imvLikePerson1 = [[UIImageView alloc] initWithFrame:CGRectMake(20, posY + 35, 20, 20)];
        imvLikePerson1.backgroundColor = [UIColor clearColor];
        imvLikePerson1.layer.cornerRadius = 10.0;
        imvLikePerson1.tag = 12;
        [vFront addSubview:imvLikePerson1];
        
        UIImageView *imvLikePerson2 = [[UIImageView alloc] initWithFrame:CGRectMake(45, posY + 35, 20, 20)];
        imvLikePerson2.backgroundColor = [UIColor clearColor];
        imvLikePerson2.layer.cornerRadius= 10.0;
        imvLikePerson2.tag = 13;
        [vFront addSubview:imvLikePerson2];
        
        UIImageView *imvLikePerson3 = [[UIImageView alloc] initWithFrame:CGRectMake(70, posY + 35, 20, 20)];
        imvLikePerson3.backgroundColor = [UIColor clearColor];
        imvLikePerson3.layer.cornerRadius= 10.0;
        imvLikePerson3.tag = 14;
        [vFront addSubview:imvLikePerson3];
        
        UIImageView *imvLikePersonMore = [[UIImageView alloc] initWithFrame:CGRectMake(97, posY + 35 + 8, 15, 4)];
        imvLikePersonMore.image = [UIImage imageNamed:@"3dot.png"];
        imvLikePersonMore.tag = 15;
        [vFront addSubview:imvLikePersonMore];
        
        BOOL flagMyHadLiked = NO;
        for (NSInteger j=0; j<_arrLikes.count; j++) {
            if ([[[_arrLikes objectAtIndex:j] objectForKey:@"createdBy"] isEqualToString:[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] objectForKey:@"_id"]]) {
                flagMyHadLiked = YES;
                break;
            }
        }
        
        if (!flagMyHadLiked) {
//            UIButton *btnLike = [[UIButton alloc] initWithFrame:CGRectMake(270 - 40, 338, 40, 40)];
//            [btnLike setImage:[UIImage imageNamed:@"icon_like.png"] forState:UIControlStateNormal];
//            [btnLike setImage:[UIImage imageNamed:@"icon_like_selected.png"] forState:UIControlStateHighlighted];
//            [btnLike addTarget:self action:@selector(likeDish:) forControlEvents:UIControlEventTouchUpInside];
//            btnLike.tag = 16;
//            [vFront addSubview:btnLike];
            
            [imvHeart setImage:[UIImage imageNamed:@"heart.png"] forState:UIControlStateNormal];
            [imvHeart addTarget:self action:@selector(likeDish:) forControlEvents:UIControlEventTouchUpInside];
        }
        else{
//            UIButton *btnLike = [[UIButton alloc] initWithFrame:CGRectMake(270 - 40, 338, 40, 40)];
//            [btnLike setImage:[UIImage imageNamed:@"icon_unlike.png"] forState:UIControlStateNormal];
//            [btnLike setImage:[UIImage imageNamed:@"icon_unlike_selected.png"] forState:UIControlStateHighlighted];
//            [btnLike addTarget:self action:@selector(unlikeDish:) forControlEvents:UIControlEventTouchUpInside];
//            btnLike.tag = 16;
//            [vFront addSubview:btnLike];
            
            [imvHeart setImage:[UIImage imageNamed:@"big_heart.png"] forState:UIControlStateNormal];
            [imvHeart addTarget:self action:@selector(unlikeDish:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        if (_arrLikes.count == 1) {
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/users/%@", urlReal, [[_arrLikes objectAtIndex:0] objectForKey:@"createdBy"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            
            __weak typeof(ASIHTTPRequest *) weakSelf = request;
            
            [request setCompletionBlock:^{
                [self request1UserLikeDidFinish:weakSelf];
            }];
            
            [request setFailedBlock:^{
                [self request1UserLikeDidFail:weakSelf];
            }];
            
//            [request setDidFinishSelector:@selector(request1UserLikeDidFinish:)];
//            [request setDidFailSelector:@selector(request1UserLikeDidFail:)];
//            request.delegate = self;
            [request setRequestMethod:@"GET"];
            [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
            
            [request setUseCookiePersistence:NO];
            [request setUseSessionPersistence:NO];
            
            if (cookie) {
                [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
            }
            
            [request addRequestHeader:@"snapIndex" value:[NSString stringWithFormat:@"%d", (int)_currentIndex]];
            
            [request addRequestHeader:@"Vary" value:@"Accept-Encoding"];
            [request addRequestHeader:@"X-Powered-By" value:@"Express"];
            [request startAsynchronous];
        }
        else if (_arrLikes.count > 1) {
            [_arrLikes sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:NO]]];
            
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/users/%@", urlReal, [[_arrLikes objectAtIndex:0] objectForKey:@"createdBy"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            
            
            __weak typeof(ASIHTTPRequest *) weakSelf = request;
            
            [request setCompletionBlock:^{
                [self request1UserLikeDidFinish:weakSelf];
            }];
            
            [request setFailedBlock:^{
                [self request1UserLikeDidFail:weakSelf];
            }];
            
//            [request setDidFinishSelector:@selector(request1UserLikeDidFinish:)];
//            [request setDidFailSelector:@selector(request1UserLikeDidFail:)];
//            request.delegate = self;
            [request setRequestMethod:@"GET"];
            [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
            
            [request setUseCookiePersistence:NO];
            [request setUseSessionPersistence:NO];
            
            if (cookie) {
                [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
            }
            
            [request addRequestHeader:@"snapIndex" value:[NSString stringWithFormat:@"%d", (int)_currentIndex]];
            
            [request addRequestHeader:@"Vary" value:@"Accept-Encoding"];
            [request addRequestHeader:@"X-Powered-By" value:@"Express"];
            [request startAsynchronous];
            
            ASINetworkQueue *queueUserLike = [[ASINetworkQueue alloc] init];
            queueUserLike.delegate = self;
            [queueUserLike setQueueDidFinishSelector:@selector(queueUserLikeDidFinished:)];
            for (int j=1; j<_arrLikes.count; j++) {
                ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://%@/api/0/users/%@", urlReal, [[_arrLikes objectAtIndex:j] objectForKey:@"createdBy"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                
                
                __weak typeof(ASIHTTPRequest *) weakSelf = request;
                
                [request setCompletionBlock:^{
                    [self requestUserLikeDidFinish:weakSelf];
                }];
                
                [request setFailedBlock:^{
                    [self requestUserLikeDidFail:weakSelf];
                }];
                
//                [request setDidFinishSelector:@selector(requestUserLikeDidFinish:)];
//                [request setDidFailSelector:@selector(requestUserLikeDidFail:)];
//                request.delegate = self;
                [request setRequestMethod:@"GET"];
                [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
                
                [request setUseCookiePersistence:NO];
                [request setUseSessionPersistence:NO];
                
                if (cookie) {
                    [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
                }
                
                [request addRequestHeader:@"snapIndex" value:[NSString stringWithFormat:@"%d", (int)_currentIndex]];
                
                [request addRequestHeader:@"Vary" value:@"Accept-Encoding"];
                [request addRequestHeader:@"X-Powered-By" value:@"Express"];
                [queueUserLike addOperation:request];
            }
            
            if (queueUserLike.operationCount > 0) {
                [queueUserLike go];
            }
        }
        
        if (_arrLikes.count == 1) {
            imvLikePerson2.hidden = YES;
            imvLikePerson3.hidden = YES;
            imvLikePersonMore.hidden = YES;
        }
        else if (_arrLikes.count == 2) {
            imvLikePerson2.hidden = NO;
            imvLikePerson3.hidden = YES;
            imvLikePersonMore.hidden = YES;
        }
        else if (_arrLikes.count == 3) {
            imvLikePerson2.hidden = NO;
            imvLikePerson3.hidden = NO;
            imvLikePersonMore.hidden = YES;
        }
        else if (_arrLikes.count > 3) {
            imvLikePerson2.hidden = NO;
            imvLikePerson3.hidden = NO;
            imvLikePersonMore.hidden = NO;
        }
    }
    else{
        
        float posY = 265 + 73;
        if (!IS_IPHONE5) {
            posY = 245 + 60;
        }
        
        UIButton *imvHeart = [[UIButton alloc] initWithFrame:CGRectMake(35, posY, 23, 22)];
        [imvHeart setImage:[UIImage imageNamed:@"heart.png"] forState:UIControlStateNormal];
        imvHeart.tag = 9;
        [imvHeart addTarget:self action:@selector(likeDish:) forControlEvents:UIControlEventTouchUpInside];
        [vFront addSubview:imvHeart];
    }
    
    [MBProgressHUD hideAllHUDsForView:[kApplicationDelegate window] animated:YES];
}

-(void)requestMyUnLikeDishDidFail:(ASIHTTPRequest *)request{
    NSString *theJSON = [request responseString];
    NSLog(@"requestMyUnLikeDishDidFail:%@", theJSON);
    
    [MBProgressHUD hideAllHUDsForView:[kApplicationDelegate window] animated:YES];
    
    [self checkAndLogout401:request.responseStatusCode];
}

-(void)likeDish:(UIButton *)sender{
    
    [MBProgressHUD showHUDAddedTo:[kApplicationDelegate window] animated:YES];
    
    NSDictionary *dicData;
    if (_flagGotoDetailOnHaveMatch) {
        dicData = [_arrGallerySearch objectAtIndex:0];
        _currentIndex = 0;
    }
    else{
        if (_isOpenRightSide) {
            dicData = [_arrTrends objectAtIndex:_currentIndex];
        }
        else{
            dicData = [_arrNews objectAtIndex:_currentIndex];
        }
    }
    
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/api/0/snaps/%@/likes", urlReal, [dicData objectForKey:@"_id"]]]];
    
    __weak typeof(ASIHTTPRequest *) weakSelf = request;
    
    [request setCompletionBlock:^{
        [self requestMyLikeDishDidFinish:weakSelf];
    }];
    
    [request setFailedBlock:^{
        [self requestMyLikeDishDidFail:weakSelf];
    }];
    
//    [request setDidFinishSelector:@selector(requestMyLikeDishDidFinish:)];
//    [request setDidFailSelector:@selector(requestMyLikeDishDidFail:)];
//    request.delegate = self;
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    
    if (cookie) {
        [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
    }
    
    [request addRequestHeader:@"snapIndex" value:[NSString stringWithFormat:@"%d", (int)_currentIndex]];
    
    [request startAsynchronous];
}

-(void)unlikeDish:(UIButton *)sender{
    
    [MBProgressHUD showHUDAddedTo:[kApplicationDelegate window] animated:YES];
    
    NSDictionary *dicData;
    if (_flagGotoDetailOnHaveMatch) {
        dicData = [_arrGallerySearch objectAtIndex:0];
        _currentIndex = 0;
    }
    else{
        if (_isOpenRightSide) {
            dicData = [_arrTrends objectAtIndex:_currentIndex];
        }
        else{
            dicData = [_arrNews objectAtIndex:_currentIndex];
        }
    }
    
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/api/0/snaps/%@/likes", urlReal, [dicData objectForKey:@"_id"]]]];
    
    __weak typeof(ASIHTTPRequest *) weakSelf = request;
    
    [request setCompletionBlock:^{
        [self requestMyUnLikeDishDidFinish:weakSelf];
    }];
    
    [request setFailedBlock:^{
        [self requestMyUnLikeDishDidFail:weakSelf];
    }];
    
//    [request setDidFinishSelector:@selector(requestMyUnLikeDishDidFinish:)];
//    [request setDidFailSelector:@selector(requestMyUnLikeDishDidFail:)];
//    request.delegate = self;
    
    [request setRequestMethod:@"DELETE"];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    
    if (cookie) {
        [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
    }
    
    [request addRequestHeader:@"snapIndex" value:[NSString stringWithFormat:@"%d", (int)_currentIndex]];
    
    [request startAsynchronous];
}

-(void)queueUserLikeDidFinished:(ASINetworkQueue *)queue{
    if (queue.operationCount > 0) {
        [queue go];
    }
}

-(void)requestUserLikeDidFinish:(ASIHTTPRequest *)request{
    NSString *theJSON = [request responseString];
    NSLog(@"requestUserLikeDidFinish:%@", theJSON);
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    
    NSDictionary *userData = [[NSDictionary alloc] initWithDictionary:[[parser objectWithString:theJSON] objectForKey:@"data"]];
    
    NSInteger index = [[[request requestHeaders] objectForKey:@"snapIndex"] intValue];
    
    UIViewController *controller = [viewControllerArray objectAtIndex:_currentIndex];
    if ([controller isKindOfClass:[NSNull class]]) return;
    MxoDoubleSidedView *vGr = (MxoDoubleSidedView *)[controller.view viewWithTag:1111 + _currentIndex];
    if (doubleSide) {
        vGr = doubleSide;
    }
    UIView *vFront = [[vGr frontSubviews] objectAtIndex:0];
    
    NSMutableDictionary *itemData = nil;
    if (_flagGotoDetailOnHaveMatch) {
        itemData = [_arrGallerySearch objectAtIndex:0];
        _currentIndex = 0;
    }
    else{
        if (_isOpenRightSide) {
            itemData = [_arrTrends objectAtIndex:index];
        }
        else{
            itemData = [_arrNews objectAtIndex:index];
        }
    }
    NSMutableArray *arrLikes = [[NSMutableArray alloc] initWithArray:[itemData objectForKey:@"likeData"]];
    [arrLikes sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:NO]]];
    
    NSInteger indexI = 12;
    for (int j=0; j<arrLikes.count; j++) {
        if ([[[arrLikes objectAtIndex:j] objectForKey:@"createdBy"] isEqualToString:[userData objectForKey:@"_id"]]) {
            indexI = 12 + j;
            break;
        }
    }
    
    UIImageView *imvLikePerson = (UIImageView *)[vFront viewWithTag:indexI];
    __weak typeof(UIImageView *) weakSelf = imvLikePerson;
    
    if (indexI != 15 && imvLikePerson) {
        [imvLikePerson setImageWithURL:[NSURL URLWithString:[[[[userData objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            weakSelf.layer.masksToBounds = YES;
            weakSelf.layer.cornerRadius = 10.0;
        }];
    }
    
    
}

-(void)requestUserLikeDidFail:(ASIHTTPRequest *)request{
    NSString *theJSON = [request responseString];
    NSLog(@"requestUserLikeDidFail:%@", theJSON);
    
    [self checkAndLogout401:request.responseStatusCode];
}

-(void)request1UserLikeDidFinish:(ASIHTTPRequest *)request{
    NSString *theJSON = [request responseString];
    NSLog(@"request1UserLikeDidFinish:%@", theJSON);
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    
    NSDictionary *userData = [[NSDictionary alloc] initWithDictionary:[[parser objectWithString:theJSON] objectForKey:@"data"]];
    
    NSInteger index = [[[request requestHeaders] objectForKey:@"snapIndex"] intValue];
    if (index > viewControllerArray.count-1) return;
    
    UIViewController *controller = [viewControllerArray objectAtIndex:index];
    if ([controller isKindOfClass:[NSNull class]]) return;
    MxoDoubleSidedView *vGr = (MxoDoubleSidedView *)[controller.view viewWithTag:1111 + index];
    if (doubleSide) {
        vGr = doubleSide;
    }
    
    if (!vGr) return;
    
    UIView *vFront = [[vGr frontSubviews] objectAtIndex:0];
    UILabel *namesLike = (UILabel *)[vFront viewWithTag:11];
    
    NSInteger countTotalLike = 0;
    
    NSMutableDictionary *itemData = nil;
    if (_flagGotoDetailOnHaveMatch) {
        itemData = [_arrGallerySearch objectAtIndex:0];
        _currentIndex = 0;
    }
    else{
        if (_isOpenRightSide) {
            itemData = [_arrTrends objectAtIndex:index];
        }
        else{
            itemData = [_arrNews objectAtIndex:index];
        }
    }
    
    if ([[itemData allKeys] containsObject:@"likeData"]) {
        countTotalLike = [[itemData objectForKey:@"likeData"] count];
        if ([[itemData objectForKey:@"likeData"] count] == 0) {
            countTotalLike = 0;
        }
    }
    else{
        countTotalLike = 0;
    }
    
    NSMutableArray *tmp = [itemData objectForKey:@"likeData"];
    if (tmp.count == 0) {
        countTotalLike = 1;
    }
    else{
        BOOL _flag = NO;
        for (int i=0; i < tmp.count; i++) {
            if ([[[tmp objectAtIndex:i] objectForKey:@"createdBy"] isEqualToString:[userData objectForKey:@"_id"]]) {
                _flag = YES;
                break;
            }
        }
        if (!_flag) {
            countTotalLike++;
        }
    }
    
    if (namesLike) {
        if (countTotalLike == 1) {
            if ([[userData objectForKey:@"_id"] isEqualToString:[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] objectForKey:@"_id"]]) {
                namesLike.text = @"You like it";
            }
            else{
                namesLike.text = [NSString stringWithFormat:@"%@ like it", [userData objectForKey:@"name"]];
            }
        }
        else{
            if ([[userData objectForKey:@"_id"] isEqualToString:[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] objectForKey:@"_id"]]) {
                namesLike.text = [NSString stringWithFormat:@"You and %d other friends like it", (int)countTotalLike - 1];
            }
            else{
                namesLike.text = [NSString stringWithFormat:@"%@ and %d other friends like it", [userData objectForKey:@"name"], (int)countTotalLike - 1];
            }
        }
    }
    
    BOOL _flag = NO;
    for (int i=0; i < tmp.count; i++) {
        if ([[[tmp objectAtIndex:i] objectForKey:@"createdBy"] isEqualToString:[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] objectForKey:@"_id"]]) {
            _flag = YES;
            break;
        }
    }
    
    if ([[userData objectForKey:@"_id"] isEqualToString:[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] objectForKey:@"_id"]] || _flag) {
        UIButton *imvHeart = (UIButton *)[vFront viewWithTag:9];
        if (imvHeart) {
            [imvHeart setImage:[UIImage imageNamed:@"big_heart.png"] forState:UIControlStateNormal];
            [imvHeart removeTarget:self action:@selector(likeDish:) forControlEvents:UIControlEventTouchUpInside];
            [imvHeart addTarget:self action:@selector(unlikeDish:) forControlEvents:UIControlEventTouchUpInside];
        }
        
    }
    else{
        UIButton *imvHeart = (UIButton *)[vFront viewWithTag:9];
        if (imvHeart) {
            [imvHeart setImage:[UIImage imageNamed:@"heart.png"] forState:UIControlStateNormal];
            [imvHeart removeTarget:self action:@selector(unlikeDish:) forControlEvents:UIControlEventTouchUpInside];
            [imvHeart addTarget:self action:@selector(likeDish:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    UILabel *countLike = (UILabel *)[vFront viewWithTag:10];
    int count = 0;
    for (UILabel *lb in vFront.subviews) {
        if (lb.tag == 10) {
            count++;
        }
    }
    
    if (count == 2) {
        [[vFront viewWithTag:10] removeFromSuperview];
    }
    countLike = (UILabel *)[vFront viewWithTag:10];
    
    if (countLike) {
        countLike.text = [NSString stringWithFormat:@"%d", (int)countTotalLike];
    }
    
    
    UIImageView *imvLikePerson1 = (UIImageView *)[vFront viewWithTag:12];
    UIImageView *imvLikePerson2 = (UIImageView *)[vFront viewWithTag:13];
    UIImageView *imvLikePerson3 = (UIImageView *)[vFront viewWithTag:14];
    UIImageView *imvLikePersonMore = (UIImageView *)[vFront viewWithTag:15];

    __weak typeof(UIImageView *) weakSelf = imvLikePerson1;
    
    if (imvLikePerson1 && imvLikePerson2 && imvLikePerson3 && imvLikePersonMore) {
        if (countTotalLike == 1) {
            imvLikePerson2.hidden = YES;
            imvLikePerson3.hidden = YES;
            imvLikePersonMore.hidden = YES;
        }
        else if (countTotalLike == 2) {
            imvLikePerson2.hidden = NO;
            imvLikePerson3.hidden = YES;
            imvLikePersonMore.hidden = YES;
        }
        else if (countTotalLike == 3) {
            imvLikePerson2.hidden = NO;
            imvLikePerson3.hidden = NO;
            imvLikePersonMore.hidden = YES;
        }
        else if (countTotalLike > 3) {
            imvLikePerson2.hidden = NO;
            imvLikePerson3.hidden = NO;
            imvLikePersonMore.hidden = NO;
        }
        
        if (imvLikePerson1) {
            imvLikePerson1.hidden = NO;
            [imvLikePerson1 setImageWithURL:[NSURL URLWithString:[[[[userData objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                weakSelf.layer.masksToBounds = YES;
                weakSelf.layer.cornerRadius = 10.0;
            }];
        }
    }
    
}

-(void)request1UserLikeDidFail:(ASIHTTPRequest *)request{
    NSString *theJSON = [request responseString];
    NSLog(@"request1UserLikeDidFail:%@", theJSON);
    
    [self checkAndLogout401:request.responseStatusCode];
}

-(void)finishGetRestaurantImage:(ASIHTTPRequest *)request andImage:(UIImageView *)imv{
    NSString *theJSON = [request responseString];
    NSLog(@"finishGetRestaurantImage:%@", theJSON);
    
    [imv setImageWithURL:request.url placeholderImage:[UIImage imageNamed:@"exMapImv.png"]];
}


-(void)flipCardToBack:(UIButton *)sender{
    _isOpenMap = YES;
    if (doubleSide) {
        [doubleSide flipView];
        return;
    }
    
    UIViewController *controller = [viewControllerArray objectAtIndex:_currentIndex];
    if ([controller isKindOfClass:[NSNull class]]) return;
    MxoDoubleSidedView *vGr = (MxoDoubleSidedView *)[controller.view viewWithTag:1111 + _currentIndex];
    
    if (!vGr) return;
    
    _scrollList.scrollEnabled = NO;
    
    NSDictionary *itemData;
    if (_isOpenRightSide) {
        itemData = [_arrTrends objectAtIndex:_currentIndex];
    }
    else{
        itemData = [_arrNews objectAtIndex:_currentIndex];
    }
    
    UIView *vBack = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.0 - 44.0, self.detailView.frame.size.height)];
    vBack.backgroundColor = [UIColor whiteColor];
    if ([vGr backSubviews].count > 0) {
        [vGr removeBackViews];
    }
    [vGr addBackSubview:vBack];
    
    UIImageView *imvMapImv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 276, 215)];
    if ([[itemData allKeys] containsObject:@"restData"]) {
        NSString *strURL = [[NSString stringWithFormat:@"http://gobbl.snapplab.com/api/0/restaurants/%@/photo", [[itemData objectForKey:@"restData"] objectForKey:@"_id"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        
        __weak typeof(ASIHTTPRequest *) weakSelf = request;
        
        [request setCompletionBlock:^{
            
            [self finishGetRestaurantImage:weakSelf andImage:imvMapImv];
            
            
        }];
        
        [request setFailedBlock:^{
            [self finishGetRestaurantImage:weakSelf andImage:imvMapImv];
        }];
        
        [request setRequestMethod:@"GET"];
        [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
        
//        [requestT setUseCookiePersistence:NO];
//        [requestT setUseSessionPersistence:NO];
        
        if (cookie) {
            [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
        }
        
//        [requestT addRequestHeader:@"Vary" value:@"Accept-Encoding"];
//        [requestT addRequestHeader:@"X-Powered-By" value:@"Express"];
        
        [request startAsynchronous];
        
        [imvMapImv setImageWithURL:[NSURL URLWithString:strURL] placeholderImage:[UIImage imageNamed:@"exMapImv.png"]];
    }
    [vBack addSubview:imvMapImv];
    
    UIImageView *imvMapImvMask = [[UIImageView alloc] initWithFrame:CGRectMake(0, 215-110, 276, 110)];
    imvMapImvMask.image = [UIImage imageNamed:@"gradient_fill.png"];
    [vBack addSubview:imvMapImvMask];
    
    UILabel *map_restName = [[UILabel alloc] initWithFrame:CGRectMake(10, 215-60, 256, 20)];
    map_restName.backgroundColor = [UIColor clearColor];
    [map_restName setTextColor:[UIColor whiteColor]];
    [map_restName setFont:[UIFont fontWithName:@"Roboto-Light" size:22.0]];
    map_restName.text = @"Restaurant Name";
    if ([[itemData allKeys] containsObject:@"restData"]) {
        [map_restName setText:[[itemData objectForKey:@"restData"] objectForKey:@"name"]];
    }
    [vBack addSubview:map_restName];
    
    UILabel *map_restAddress = [[UILabel alloc] initWithFrame:CGRectMake(10, 215-40, 256, 20)];
    map_restAddress.backgroundColor = [UIColor clearColor];
    [map_restAddress setTextColor:[UIColor whiteColor]];
    [map_restAddress setFont:[UIFont fontWithName:@"Roboto-Condensed" size:13.0]];
    map_restAddress.text = @"510 Main street, New York, NY 10044";
    if ([[itemData allKeys] containsObject:@"restData"]) {
        [map_restAddress setText:[[itemData objectForKey:@"restData"] objectForKey:@"vicinity"]];
    }
    map_restAddress.lineBreakMode = NSLineBreakByTruncatingTail;
    [vBack addSubview:map_restAddress];
    
    UILabel *map_restPhone = [[UILabel alloc] initWithFrame:CGRectMake(10, 215-20, 256, 20)];
    map_restPhone.backgroundColor = [UIColor clearColor];
    [map_restPhone setTextColor:[UIColor whiteColor]];
    [map_restPhone setFont:[UIFont fontWithName:@"Roboto-Condensed" size:13.0]];
    map_restPhone.text = @"646 206 4887";
    map_restPhone.lineBreakMode = NSLineBreakByTruncatingTail;
    if ([[itemData allKeys] containsObject:@"restData"]) {
        NSString *sType = @"";
        for (int i=0; i<[[[[itemData objectForKey:@"restData"] objectForKey:@"google"] objectForKey:@"types"] count]; i++) {
            sType = [sType stringByAppendingFormat:@"%@, ", [[[[itemData objectForKey:@"restData"] objectForKey:@"google"] objectForKey:@"types"] objectAtIndex:i]];
        }
        if (sType.length > 0) {
            sType = [sType substringToIndex:sType.length-2];
        }
        [map_restPhone setText:sType];
    }
    map_restPhone.lineBreakMode = NSLineBreakByTruncatingTail;
    [vBack addSubview:map_restPhone];
    
    UIButton *btnMapBack = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 276, 215)];
    [btnMapBack addTarget:self action:@selector(flipCardToFront:) forControlEvents:UIControlEventTouchUpInside];
    [vBack addSubview:btnMapBack];
    
    UIButton *btnCloseMap = [[UIButton alloc] initWithFrame:CGRectMake(276 - 40, 0, 40, 40)];
    [btnCloseMap setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
    [btnCloseMap addTarget:self action:@selector(flipCardToFront:) forControlEvents:UIControlEventTouchUpInside];
    [vBack addSubview:btnCloseMap];
    
    MKMapView *myMap = [[MKMapView alloc] initWithFrame:CGRectMake(0, 215, 276, self.detailView.frame.size.height - 215)];
    myMap.delegate = self;
    [vBack addSubview:myMap];
    
    if ([[itemData allKeys] containsObject:@"restData"]) {
        CLLocationCoordinate2D zoomLocation;
        
        float longValue = [[[[[itemData objectForKey:@"restData"] objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"] floatValue];
        float latValue = [[[[[itemData objectForKey:@"restData"] objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"] floatValue];
        
        zoomLocation.latitude = latValue;
        zoomLocation.longitude = longValue;
        
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
        [myMap setRegion:viewRegion animated:YES];
        
        
        MyLocation *annotation = [[MyLocation alloc] initWithName:[[itemData objectForKey:@"restData"] objectForKey:@"name"] address:[[itemData objectForKey:@"restData"] objectForKey:@"vicinity"] coordinate:zoomLocation] ;
        [myMap addAnnotation:annotation];
        
        
        MyLocation *myAnnotation = [[MyLocation alloc] initWithName:@"My Location" address:@"" coordinate:[LocationManager locationManager].currentLocation.coordinate];
        [myMap addAnnotation:myAnnotation];
    }
    
    [vGr flipView];
    
}


-(void)flipCardToFront:(UIButton *)sender{
    _isOpenMap = NO;
    if (doubleSide) {
        [doubleSide flipView];
        return;
    }
    
    
    UIViewController *controller = [viewControllerArray objectAtIndex:_currentIndex];
    if ([controller isKindOfClass:[NSNull class]]) return;
    MxoDoubleSidedView *vGr = (MxoDoubleSidedView *)[controller.view viewWithTag:1111 + _currentIndex];
    
    if (!vGr) return;
    
    _scrollList.scrollEnabled = YES;
    [vGr flipView];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    SAFE_RELEASE_ARRAY(arrSearch);
    arrSearch = [[NSMutableArray alloc] init];
    
    if (string.length > 0) {
        if([_txtSearchField.text length] + string.length > 0) {
            
            _tblSearch.userInteractionEnabled = NO;
            
            [timerInput invalidate];
            timerInput = nil;
            
            timerInput = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(_sendRequestGetAuto) userInfo:nil repeats:NO];
            
            
        }
        else {
            currentSelectSearch = -1;
            searching = NO;
            SAFE_RELEASE_ARRAY(arrSearch);
            arrSearch = [[NSMutableArray alloc] init];
            [_tblSearch reloadData];
            
            _lblResultSearch.hidden = YES;
            _galleryView.hidden = YES;
        }
    }
    else{
        if([_txtSearchField.text length] -1 > 0) {
            
            _tblSearch.userInteractionEnabled = NO;
            
            [timerInput invalidate];
            timerInput = nil;
            
            timerInput = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(_sendRequestGetAuto) userInfo:nil repeats:NO];
            
            
        }
        else {
            currentSelectSearch = -1;
            searching = NO;
            SAFE_RELEASE_ARRAY(arrSearch);
            arrSearch = [[NSMutableArray alloc] init];
            [_tblSearch reloadData];
            
            _lblResultSearch.hidden = YES;
            _galleryView.hidden = YES;
        }
    }
    
	
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    
    [self searchTableView];
    
    return YES;
}
@end
