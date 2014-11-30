//
//  FACameraViewController.m
//  FoodApp
//
//  Created by CHINH LE on 6/25/14.
//  Copyright (c) 2014 chinhlt. All rights reserved.
//

#import "FACameraViewController.h"
#import "FAEntryViewController.h"

#import "SDImageCache.h"
#import "MWCommon.h"
#import "JCRBlurView.h"

#import "FXBlurView.h"

@interface FACameraViewController ()

@end

@implementation FACameraViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"expda-launch-linen.png"]]];
    
    _isTorch = NO;
    _isFront = NO;
    
    UITapGestureRecognizer *singleTapOnView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapOnView)];
    singleTapOnView.numberOfTapsRequired = 1;
    singleTapOnView.numberOfTouchesRequired = 1;
    [_overlayView addGestureRecognizer:singleTapOnView];
    
    _imvPreview.layer.borderWidth = 1;
    _imvPreview.layer.borderColor = [UIColor colorWithRed:81.0/255 green:196.0/255 blue:212.0/255 alpha:1.0].CGColor;
    
//    [MBProgressHUD showHUDAddedTo:[kApplicationDelegate window] animated:YES];
    
//    JCRBlurView *blurView1 = [JCRBlurView new];
//    [blurView1 setTintColor:[UIColor colorWithRed:4.0/255 green:20.0/255 blue:82.0/255 alpha:1.0]];
//    [blurView1 setFrame:CGRectMake(0.0f,0.0f, _vTop.frame.size.width, _vTop.frame.size.height)];
//    blurView1.alpha = 0.98;
//    [_vTop addSubview:blurView1];
//    
//    [_vTop sendSubviewToBack:blurView1];
    
//    JCRBlurView *blurView2 = [JCRBlurView new];
//    [blurView2 setBlurTintColor:[UIColor colorWithWhite:1.0 alpha:0.5]];
//    [blurView2 setFrame:CGRectMake(0.0f,0.0f, _vBottom.frame.size.width, _vBottom.frame.size.height)];
//    blurView2.alpha = 0.98;
//    [_vBottom addSubview:blurView2];
//    
//    [_vBottom sendSubviewToBack:blurView2];
    
//    FXBlurView *blur = [[FXBlurView alloc] initWithFrame:CGRectMake(0.0f, 0.0, _vBottom.frame.size.width, _vBottom.frame.size.height)];
//    [blur setBlurRadius:10.0];
//    [blur setBlurEnabled:YES];
//    blur.dynamic = YES;
////    blur.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:blur];
////    [self.view bringSubviewToFront:_vBottom];
////    [self.view sendSubviewToBack:blur];
//    
//    _vBottom.hidden = YES;
    
//    _blurView = [[FXBlurView alloc] initWithFrame:CGRectMake(0.0f, 0.0, _vBottom.frame.size.width, _vBottom.frame.size.height)];
//    _blurView.tintColor = [UIColor whiteColor];
//    _blurView.updateInterval = 1;
//    _blurView.blurRadius = 10.f;
//    _blurView.dynamic = YES;
//    [self.view addSubview:_blurView];
//    
//    [self.view bringSubviewToFront:_vBottom];
    
    [_btnRetake.titleLabel setFont:[UIFont fontWithName:@"Roboto-Regular" size:18.0]];
    [_btnUseImv.titleLabel setFont:[UIFont fontWithName:@"Roboto-Regular" size:18.0]];
    
//    vMask = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
//    vMask.center = CGPointMake(self.view.center.x, self.view.center.y - addIOS7/2 - 44.0/2);
//    vMask.backgroundColor = [UIColor clearColor];
//    vMask.layer.borderWidth = 1;
//    vMask.layer.borderColor = [UIColor redColor].CGColor;
//    [self.view addSubview:vMask];
//    
//    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
//    [vMask addGestureRecognizer:pan];
    
    _imvReview.contentMode = UIViewContentModeScaleAspectFit;
}

-(void)handlePan:(UIPanGestureRecognizer *)panGesture{
    CGRect rect = vMask.frame;
    
    rect.origin.y = [panGesture locationInView:self.view].y;
    vMask.frame = rect;
}

-(void)singleTapOnView{
    
}

- (void)loadAssets {
    
    // Initialise
    _assets = [NSMutableArray new];
    _assetLibrary = [[ALAssetsLibrary alloc] init];
    
    // Run in the background as it takes a while to get all assets from the library
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableArray *assetGroups = [[NSMutableArray alloc] init];
        NSMutableArray *assetURLDictionaries = [[NSMutableArray alloc] init];
        
        // Process assets
        void (^assetEnumerator)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result != nil) {
                if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                    [assetURLDictionaries addObject:[result valueForProperty:ALAssetPropertyURLs]];
                    NSURL *url = result.defaultRepresentation.url;
                    [_assetLibrary assetForURL:url
                                   resultBlock:^(ALAsset *asset) {
                                       if (asset) {
                                           @synchronized(_assets) {
                                               [_assets addObject:asset];
                                           }
                                       }
                                   }
                                  failureBlock:^(NSError *error){
                                      NSLog(@"operation was not successfull!");
                                  }];
                    
                }
            }
        };
        
        // Process groups
        void (^ assetGroupEnumerator) (ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) {
            if (group != nil) {
                [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:assetEnumerator];
                [assetGroups addObject:group];
            }
        };
        
        // Process!
        [self.assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                         usingBlock:assetGroupEnumerator
                                       failureBlock:^(NSError *error) {
                                           NSLog(@"There is an error");
                                           [MBProgressHUD hideAllHUDsForView:[kApplicationDelegate window] animated:YES];
                                       }];
        
    });
    [MBProgressHUD hideAllHUDsForView:[kApplicationDelegate window] animated:YES];
}

-(UIImage *)saveImageDish{
    CGRect rectt = CGRectMake(0, 0, _imvReview.frame.size.width, _imvReview.frame.size.height);
    UIGraphicsBeginImageContext(rectt.size);
    [_imvReview.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [self squareImageWithImage:viewImage scaledToSize:CGSizeMake(320.0, 320.0)];
}

- (UIImage *)squareImageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    double ratio;
    double delta;
    CGPoint offset;
    
    //make a new square size, that is the resized imaged width
    CGSize sz = CGSizeMake(newSize.width, newSize.height);
    
    //figure out if the picture is landscape or portrait, then
    //calculate scale factor and offset
    if (image.size.width > image.size.height) {
        ratio = newSize.width / image.size.width;
        delta = (ratio*image.size.width - ratio*image.size.height);
        offset = CGPointMake(delta/2, 0);
    } else {
        ratio = newSize.width / image.size.height;
        delta = (ratio*image.size.height - ratio*image.size.width);
        offset = CGPointMake(0, delta/2);
    }
    
    //make the final clipping rect based on the calculated values
    CGRect clipRect = CGRectMake(-offset.x, -offset.y,
                                 (ratio * image.size.width) + delta,
                                 (ratio * image.size.height) + delta);
    
    
    //start a new context, with scale factor 0.0 so retina displays get
    //high quality image
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(sz, YES, 0.0);
    } else {
        UIGraphicsBeginImageContext(sz);
    }
    UIRectClip(clipRect);
    [image drawInRect:clipRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize andImage:(UIImage *)imv andPos:(CGPoint)point
{
    UIImage *sourceImage = imv;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
        {
            scaleFactor = widthFactor; // scale to fit height
        }
        else
        {
            scaleFactor = heightFactor; // scale to fit width
        }
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
        {
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
        }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = CGPointMake(0.0, self.view.center.y - 320.0);
    thumbnailRect.size.width  = 320;
    thumbnailRect.size.height = 320;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil)
    {
        NSLog(@"could not scale image");
    }
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    
    return newImage;
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [_session stopRunning];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    #if TARGET_IPHONE_SIMULATOR
    return;
    #endif
    
    
    if (![_session isRunning] && _imvReview.isHidden){
        [_session startRunning];
    }
    if (_session) return;
    
    [self startScanner];
    
    [[SDImageCache sharedImageCache] clearDisk];
    [[SDImageCache sharedImageCache] clearMemory];
    [self loadAssets];
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    // Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.
    [library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        // Within the group enumeration block, filter to enumerate just photos.
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        
        // Chooses the photo at the last index
        [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
            // The end of the enumeration is signaled by asset == nil.
            if (alAsset) {
                UIImage *latestPhotoThumbnail =  [UIImage imageWithCGImage:[alAsset thumbnail]];
                
                // Stop the enumerations
                *stop = YES; *innerStop = YES;
                
                _imvPreview.image = latestPhotoThumbnail;
                
                // Do something interesting with the AV asset.
                //[self sendTweet:latestPhoto];
            }
        }];
    } failureBlock: ^(NSError *error) {
        // Typically you should handle an error more gracefully than this.
        NSLog(@"No groups");
        
        
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Gobbl" message:@"Gobbl is not allowed to access your photos. This may be the result of your device's privacy settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        _btnUse.hidden = YES;
        _imvPreview.hidden = YES;
        
        [MBProgressHUD hideAllHUDsForView:[kApplicationDelegate window] animated:YES];
    }];
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

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection
{
    
}

- (void)startScanner{
//    [_timerScan invalidate];
//    _timerScan = nil;
//    
//    _timerScan = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(startScanner) userInfo:nil repeats:NO];
    
    _session = [[AVCaptureSession alloc] init];
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    _session.sessionPreset = AVCaptureSessionPresetPhoto;
    
    NSError *error = nil;
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:_device
                                                                        error:&error];
    if (input) {
        [_session addInput:input];
    } else {
        NSLog(@"Error: %@", error);
    }
    
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [_session addOutput:output];
    //    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    if (!_previewLayer) _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _previewLayer.frame = _overlayView.bounds;
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [_overlayView.layer addSublayer:_previewLayer];
    
    stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [stillImageOutput setOutputSettings:outputSettings];
    [_session addOutput:stillImageOutput];
    
    [_session startRunning];
}

// Find a camera with the specified AVCaptureDevicePosition, returning nil if one is not found
- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == position) return device;
    }
    return nil;
}

- (UIImage *)cropImage:(UIImage *)imageToCrop {
	CGSize size = [imageToCrop size];
	int padding = 0;
	int pictureSize;
	int startCroppingPosition;
	if (size.height > size.width) {
        pictureSize = size.width - (2.0 * padding);
        startCroppingPosition = (size.height - pictureSize) / 2.0;
	} else {
        pictureSize = size.height - (2.0 * padding);
        startCroppingPosition = (size.width - pictureSize) / 2.0;
	}
	CGRect cropRect = CGRectMake(startCroppingPosition, padding, pictureSize, pictureSize);
	CGImageRef imageRef = CGImageCreateWithImageInRect([imageToCrop CGImage], cropRect);
	UIImage *newImage = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:imageToCrop.imageOrientation];
	return newImage;
}

- (IBAction)keyPress:(UIButton *)sender{
    if (sender == _btnUse) {
        
        [_session stopRunning];
        
        NSMutableArray *photos = [[NSMutableArray alloc] init];
        NSMutableArray *thumbs = [[NSMutableArray alloc] init];
        
        BOOL displayActionButton = YES;
        BOOL displaySelectionButtons = NO;
        BOOL displayNavArrows = NO;
        BOOL enableGrid = YES;
        BOOL startOnGrid = NO;
        
        @synchronized(_assets) {
            NSMutableArray *copy = [_assets copy];
            for (ALAsset *asset in copy) {
                [photos addObject:[MWPhoto photoWithURL:asset.defaultRepresentation.url]];
                [thumbs addObject:[MWPhoto photoWithImage:[UIImage imageWithCGImage:asset.thumbnail]]];
            }
        }
        
        self.photos = photos;
        self.thumbs = thumbs;
        
        displayActionButton = NO;
        displaySelectionButtons = YES;
        startOnGrid = YES;
        enableGrid = NO;
        
        // Create browser
        MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
        browser.displayActionButton = displayActionButton;
        browser.displayNavArrows = displayNavArrows;
        browser.displaySelectionButtons = displaySelectionButtons;
        browser.alwaysShowControls = displaySelectionButtons;
        browser.zoomPhotosToFill = YES;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
        browser.wantsFullScreenLayout = YES;
#endif
        browser.enableGrid = enableGrid;
        browser.startOnGrid = startOnGrid;
        browser.enableSwipeToDismiss = YES;
        [browser setCurrentPhotoIndex:0];
        
        
        
        // Reset selections
        if (displaySelectionButtons) {
            _selections = [NSMutableArray new];
            for (int i = 0; i < photos.count; i++) {
                [_selections addObject:[NSNumber numberWithBool:NO]];
            }
        }
        
        // Show
        // Modal
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
        nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:nc animated:YES completion:nil];
        
        // Release
        
        // Test reloading of data after delay
        double delayInSeconds = 3;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            //        // Test removing an object
            //        [_photos removeLastObject];
            //        [browser reloadData];
            //
            //        // Test all new
            //        [_photos removeAllObjects];
            //        [_photos addObject:[MWPhoto photoWithFilePath:[[NSBundle mainBundle] pathForResource:@"photo3" ofType:@"jpg"]]];
            //        [browser reloadData];
            //
            //        // Test changing photo index
            //        [browser setCurrentPhotoIndex:9];
            
            //        // Test updating selections
            //        _selections = [NSMutableArray new];
            //        for (int i = 0; i < [self numberOfPhotosInPhotoBrowser:browser]; i++) {
            //            [_selections addObject:[NSNumber numberWithBool:YES]];
            //        }
            //        [browser reloadData];
            
        });
        
        return;
        
        
        [_session stopRunning];
        FAEntryViewController *entry = [self.storyboard instantiateViewControllerWithIdentifier:@"Entry"];
        
        //        [(UINavigationController *)[kApplicationDelegate window].rootViewController pushViewController:entry animated:YES];
        //        [self performSegueWithIdentifier:@"CustomUnwindSegue" sender:sender];
        
        [self presentViewController:entry animated:YES completion:^{
            //            [self performSegueWithIdentifier:@"CustomUnwindSegue" sender:sender];
            entry.imvView.image = _imvPreview.image;
        }];
    }
    else if(sender == _btnCamera){
        #if TARGET_IPHONE_SIMULATOR
        [_session stopRunning];
        
        [UIView animateWithDuration:0.35 animations:^{
            _vBottom.alpha = 0.0;
            _vOK.alpha = 1.0;
        }];
        
//        FAEntryViewController *entry = [self.storyboard instantiateViewControllerWithIdentifier:@"Entry"];
//        
//        [self presentViewController:entry animated:YES completion:^{
//            entry.imvView.image = [UIImage imageNamed:@"rome@2x.jpg"];
//        }];
        
        
        #else
        AVCaptureConnection *videoConnection = nil;
        for (AVCaptureConnection *connection in stillImageOutput.connections)
        {
            for (AVCaptureInputPort *port in [connection inputPorts])
            {
                if ([[port mediaType] isEqual:AVMediaTypeVideo] )
                {
                    videoConnection = connection;
                    break;
                }
            }
            if (videoConnection) { break; }
        }
        
        NSLog(@"about to request a capture from: %@", stillImageOutput);
        [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
         {
             CFDictionaryRef exifAttachments = CMGetAttachment( imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
             if (exifAttachments)
             {
                 // Do something with the attachments.
                 NSLog(@"attachements: %@", exifAttachments);
             }
             else
                 NSLog(@"no attachments");
             
             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
             UIImage *image = [[UIImage alloc] initWithData:imageData];
             
             CGImageRef cgRef = image.CGImage;
             image = [[UIImage alloc] initWithCGImage:cgRef scale:1.0 orientation:image.imageOrientation];
             
             _imvReview.contentMode = UIViewContentModeScaleAspectFill;
             _imvReview.image = image;
             
             
             [_session stopRunning];
             
             [self.view bringSubviewToFront:_imvReview];
             [self.view bringSubviewToFront:_vTop];
             [self.view bringSubviewToFront:_vBottom];
             [self.view bringSubviewToFront:_vOK];
             [self.view bringSubviewToFront:vMask];
             [self.view bringSubviewToFront:_topMask];
             
             _imvReview.hidden = NO;
             
             [UIView animateWithDuration:0.35 animations:^{
                 _vBottom.alpha = 0.0;
                 _vOK.alpha = 1.0;
             }];
             
//             FAEntryViewController *entry = [self.storyboard instantiateViewControllerWithIdentifier:@"Entry"];
//
//             [self presentViewController:entry animated:YES completion:^{
//                 CGSize size = CGSizeMake(200.0, 200.0);
////                 if (IS_IPHONE5) {
////                     size = CGSizeMake(320.0, 406.0);
////                 }
//                 entry.imvView.image = [self imageByScalingAndCroppingForSize:size andImage:image];
//             }];
             
         }];
        #endif
    }
    else if(sender == _btnTorch){
        if (_isTorch) {
            _isTorch = NO;
        }
        else{
            _isTorch = YES;
        }
        
        [_device lockForConfiguration:nil];
        if ( [_device hasTorch] ) {
            if ( _isTorch ) {
                [_device setTorchMode:AVCaptureTorchModeOn];
            } else {
                [_device setTorchMode:AVCaptureTorchModeOff];
            }
        }
        [_device unlockForConfiguration];
    }
    else if(sender == _btnSwitch){
        //Change camera source
        if(_session)
        {
            //Indicate that some changes will be made to the session
            [_session beginConfiguration];
            
            //Remove existing input
            AVCaptureInput* currentCameraInput = [_session.inputs objectAtIndex:0];
            [_session removeInput:currentCameraInput];
            
            //Get new input
            AVCaptureDevice *newCamera = nil;
            if(((AVCaptureDeviceInput*)currentCameraInput).device.position == AVCaptureDevicePositionBack)
            {
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            }
            else
            {
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            }
            
            //Add input to session
            AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:newCamera error:nil];
            [_session addInput:newVideoInput];
            
            //Commit all the configuration changes at once
            [_session commitConfiguration];
        }
    }
    else if(sender == _btnRetake){
        _vBottom.alpha = 1.0;
        _vOK.alpha = 0.0;
        _imvReview.hidden = YES;
        
        [_session startRunning];
        
    }
    else if(sender == _btnUseImv){
        if (![ASIHTTPRequest isNetworkReachable]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Whoops! No Internet connection found. Please check your connection or try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
        else{
            FAEntryViewController *entry = [self.storyboard instantiateViewControllerWithIdentifier:@"Entry"];
//            entry.imvFromCamera = [self squareImageWithImage:_imvReview.image scaledToSize:CGSizeMake(320.0, 320.0)];
            entry.imvFromCamera = [self saveImageDish];
            [self presentViewController:entry animated:YES completion:^{
                entry.imvView.image = [self saveImageDish];
            }];
        }
        
    }
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    if (index < _thumbs.count)
        return [_thumbs objectAtIndex:index];
    return nil;
}

//- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index {
//    MWPhoto *photo = [self.photos objectAtIndex:index];
//    MWCaptionView *captionView = [[MWCaptionView alloc] initWithPhoto:photo];
//    return [captionView autorelease];
//}

//- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index {
//    NSLog(@"ACTION!");
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    NSLog(@"Did start viewing photo at index %lu", (unsigned long)index);
}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
    return [[_selections objectAtIndex:index] boolValue];
}

//- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index {
//    return [NSString stringWithFormat:@"Photo %lu", (unsigned long)index+1];
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
    [_selections replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:selected]];
    NSLog(@"Photo at index %lu selected %@", (unsigned long)index, selected ? @"YES" : @"NO");
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    // If we subscribe to this method we must dismiss the view controller ourselves
    NSLog(@"Did finish modal presentation");
    [self dismissViewControllerAnimated:YES completion:^{
        NSInteger index = -1;
        for (int i=0; i < _selections.count; i++) {
            if ([[_selections objectAtIndex:i] boolValue]) {
                index = i;
                break;
            }
        }
        if (index == -1) {
            [_session startRunning];
        }
        else{
            [_session stopRunning];
            
            ALAsset *alAsset = [_assets objectAtIndex:index];
            ALAssetRepresentation *representation = [alAsset defaultRepresentation];
            UIImage *selectedPhoto = [UIImage imageWithCGImage:[representation fullScreenImage]];
            if (selectedPhoto.size.height > _imvReview.frame.size.height) {
                _imvReview.contentMode = UIViewContentModeScaleAspectFill;
            }
            else{
                _imvReview.contentMode = UIViewContentModeScaleAspectFit;
            }
            _imvReview.image = selectedPhoto;
            
            [self.view bringSubviewToFront:_imvReview];
            [self.view bringSubviewToFront:_vTop];
            [self.view bringSubviewToFront:_vBottom];
            [self.view bringSubviewToFront:_vOK];
            [self.view bringSubviewToFront:vMask];
            [self.view bringSubviewToFront:_topMask];
            
            _imvReview.hidden = NO;
            
            [UIView animateWithDuration:0.35 animations:^{
                _vOK.alpha = 1.0;
                _vBottom.alpha = 0.0;
            }];
            
            
            
//            FAEntryViewController *entry = [self.storyboard instantiateViewControllerWithIdentifier:@"Entry"];
//            
//            [self presentViewController:entry animated:YES completion:^{
//                ALAsset *alAsset = [_assets objectAtIndex:index];
//                ALAssetRepresentation *representation = [alAsset defaultRepresentation];
//                UIImage *selectedPhoto = [UIImage imageWithCGImage:[representation fullScreenImage]];
//                
//                CGSize size = CGSizeMake(200.0, 200.0);
////                if (IS_IPHONE5) {
////                    size = CGSizeMake(320.0, 406.0);
////                }
//                entry.imvView.image = [self imageByScalingAndCroppingForSize:size andImage:selectedPhoto];
//                [_session stopRunning];
//            }];
        }
    }];
    
    
}

@end