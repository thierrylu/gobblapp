//
//  FACameraViewController.h
//  FoodApp
//
//  Created by CHINH LE on 6/25/14.
//  Copyright (c) 2014 chinhlt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import <ImageIO/ImageIO.h>

#import <AssetsLibrary/AssetsLibrary.h>
#import "MWPhotoBrowser.h"

#import "FXBlurView.h"

@interface FACameraViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate, MWPhotoBrowserDelegate>{
    __weak IBOutlet UIView *_overlayView;
    __weak IBOutlet UIButton *_btnClose;
    __weak IBOutlet UIButton *_btnTorch;
    __weak IBOutlet UIButton *_btnSwitch;
    __weak IBOutlet UIButton *_btnCamera;
    __weak IBOutlet UIImageView *_imvPreview;
    __weak IBOutlet UIButton *_btnUse;
    
    __strong AVCaptureVideoPreviewLayer  *_previewLayer;
    AVCaptureSession *_session;
    AVCaptureDevice *_device;
    
    BOOL _isTorch;
    BOOL _isFront;
    
    NSTimer *_timerScan;
    AVCaptureStillImageOutput *stillImageOutput;
    
    NSMutableArray *_selections;
    
    __weak IBOutlet UIView *_vTop;
    __weak IBOutlet UIView *_vBottom;
    __weak IBOutlet UIView *_vOK;
    
    __weak IBOutlet UIButton *_btnRetake;
    __weak IBOutlet UIButton *_btnUseImv;
    
    FXBlurView *_blurView;
    
    __weak IBOutlet UIImageView *_imvReview;
    
    UIView *vMask;
    UIButton *imvDown;
    UIButton *imvUp;
    UIButton *imvLeft;
    UIButton *imvRight;
    
    __weak IBOutlet UIView *_topMask;
}

@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *thumbs;
@property (nonatomic, strong) ALAssetsLibrary *assetLibrary;
@property (nonatomic, strong) NSMutableArray *assets;

- (void)loadAssets;

- (IBAction)keyPress:(UIButton *)sender;

@end
