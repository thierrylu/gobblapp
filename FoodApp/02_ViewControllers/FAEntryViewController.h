//
//  FAEntryViewController.h
//  FoodApp
//
//  Created by CHINH LE on 6/25/14.
//  Copyright (c) 2014 chinhlt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IZValueSelectorView.h"
#import "DLStarRatingControl.h"
#import "RMTLocationDetailViewController.h"

@interface FAEntryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, RMTLocationDetailViewDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate, DLStarRatingDelegate, UITextViewDelegate>{
    NSInteger _currentSelectRestaurant;
    NSInteger _currentSelectedDish;
    NSInteger _currentSelectedTag;
    NSInteger _currentStep;
    
    DLStarRatingControl *customNumberOfStars;
    
    NSMutableArray *arrRestaurant;
    NSMutableArray *arrDish;
    NSMutableArray *arrTag;
    
    BOOL searchingRest;
    BOOL searchingDish;
    
    NSMutableArray *arrSearchRest;
    NSMutableArray *arrSearchDish;
    
    NSInteger _remCurrentSelectRestaurant;
    NSInteger _remCurrentSelectedDish;
    
    UITextField *txtTag;
    
    UIImage *_imvFromCamera;
    NSMutableDictionary *_dataItem;
    
    NSHTTPCookie *cookie;
    NSInteger currentRating;
    BOOL _finalStep;
    
    NSInteger _currentPageIndexAutoComplete;
    BOOL _isLoadingMore;
    
    NSTimer *timerInput;
    
    NSInteger _currentPageIndexRest;
    NSInteger _currentPageIndexSearchRest;
}

@property (strong, nonatomic) UIImage *imvFromCamera;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;

@property (weak, nonatomic) IBOutlet UIView *statusBarOverlay;
@property (weak, nonatomic) IBOutlet UINavigationBar *topNavBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *topBarItem;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *selectionView;

@property (weak, nonatomic) IBOutlet UITableView *tblRestaurant;
@property (weak, nonatomic) IBOutlet UITableView *tblDish;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBarDish;

@property (weak, nonatomic) IBOutlet UIImageView *imvIcn1;
@property (weak, nonatomic) IBOutlet UIImageView *imvIcn2;

@property (weak, nonatomic) IBOutlet UILabel *restaurantLabel;
@property (weak, nonatomic) IBOutlet UILabel *dishLabel;

@property (weak, nonatomic) IBOutlet UIImageView *imvView;
@property (weak, nonatomic) IBOutlet UIView *ratingView;
@property (weak, nonatomic) IBOutlet UIScrollView *tagScrollView;
@property (weak, nonatomic) IBOutlet UIButton *okButton;

@property (weak, nonatomic) IBOutlet UIView *resultView;
@property (weak, nonatomic) IBOutlet UIButton *resultButton;

@property (weak, nonatomic) IBOutlet UIButton *mapButton;
@property (weak, nonatomic) IBOutlet UIView *mapView;
@property (weak, nonatomic) IBOutlet MKMapView *myMap;
@property (weak, nonatomic) IBOutlet UIButton *btnAddComment;
@property (weak, nonatomic) IBOutlet UIButton *btnOpenEditComment;

@property (weak, nonatomic) IBOutlet UIView *viewComment;
@property (weak, nonatomic) IBOutlet UILabel *restaurantLabelCom;
@property (weak, nonatomic) IBOutlet UILabel *dishLabelCom;
@property (weak, nonatomic) IBOutlet UITextView *txtComment;
@property (weak, nonatomic) IBOutlet UILabel *countCharCom;
@property (weak, nonatomic) IBOutlet UILabel *lblCom;

-(IBAction)keyPress:(UIButton *)sender;

@end
