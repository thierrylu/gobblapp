//
//  FAHomeViewController.h
//  FoodApp
//
//  Created by CHINH LE on 6/9/14.
//  Copyright (c) 2014 chinhlt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KLScrollSelect.h"
#import "WCGalleryView.h"

#import "FACellDish.h"
#import "TWSpringyFlowLayout.h"
#import "MxoDoubleSidedView.h"

#import "ASINetworkQueue.h"

#import "DMLazyScrollView.h"

@interface FAHomeViewController : UIViewController <KLScrollSelectDataSource, KLScrollSelectDelegate, KLImageCellDelegate, UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, FACellDishDelegate, MKMapViewDelegate, WCGalleryDelegate, UIScrollViewDelegate, DMLazyScrollViewDelegate>{
    
    BOOL searching;
    NSMutableArray *arrSearch;
    NSInteger _currentSelectedSearchType;
    
    NSMutableData *_responseData;
    
    BOOL _isLeft;
    NSInteger _currentSelectedItem;
    
    __weak IBOutlet UICollectionView *_rightCollectionView;
    __weak IBOutlet UICollectionView *_leftCollectionView;
    
    WCGalleryView *_galleryView;
    UILabel *_lblResultSearch;
    
    NSHTTPCookie *cookie;
    NSInteger currentSelectSearch;
    
    __weak IBOutlet UITableView *_tblSearch;
    
    UIImageView *imvZoom;
    CGPoint remPoint;
    MxoDoubleSidedView *doubleSide;
    
    __weak IBOutlet UIView *_vShowNew;
    __weak IBOutlet UIView *_vShowTrending;
    __weak IBOutlet UILabel *_lblShowNew;
    __weak IBOutlet UILabel *_lblShowTrending;
    
    BOOL _isScrollNew;
    BOOL _isScrollTrend;
    
    float lastOffsetNew;
    float lastOffsetTrend;
    
    NSMutableArray *_arrNews;
    NSMutableArray *_arrTrends;
    
    float currentPanPoint;
    BOOL _isRotate;
    BOOL _isSwipeNext;
    
    __weak IBOutlet UIView *_resultSearchView;
    WCGalleryView *_searchGalleryView;
    NSMutableArray *_arrGallerySearch;
    
    __weak IBOutlet UILabel *_lblSearchDishName;
    
    NSMutableArray *tmpArrData;
    NSInteger _currentIndex;
    
    NSMutableDictionary *_currentItemDishData;
    NSMutableArray *_arrLikes;
    NSIndexPath *_currentIndexPath;
    
    UIScrollView *_vScrollLeft;
    UIScrollView *_vScrollRight;
    
    NSTimer *_timerSchedule;
    NSMutableArray *_arrDataNews;
    
    BOOL _flagGotoDetailOnNotMatch;
    BOOL _flagGotoDetailOnHaveMatch;
    
    NSInteger currentSnapNewsPageIndex;
    NSInteger currentSnapTrendingPageIndex;
    
    UIImageView *_imgvcChild;
    BOOL _isOpenRightSide;
    NSInteger _currentPageIndexAutoComplete;
    
    BOOL _isLoadingMore;
    BOOL _isInsertNewDish;
    
    NSMutableDictionary *_insertSnapData;
    
    ASINetworkQueue *queueAll;
    BOOL _isAnimation;
    
    BOOL _isOpenMap;
    BOOL _isOpeningDetail;
    
    DMLazyScrollView *_scrollList;
    float _currentContentOffset;
    BOOL _flagWillLoadData;
    
    NSTimer *_timerDownloadData;
    NSMutableArray *viewControllerArray;
    
    CGPoint _lastScrollPosition;
    CGPoint _currentScrollPosition;
    
    NSTimer *timerInput;
    
    __weak IBOutlet UITextField *_txtSearchField;
}

@property (weak, nonatomic) IBOutlet UIView *statusBarOverlay;
@property (weak, nonatomic) IBOutlet UINavigationBar *topNavBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *topBarItem;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *detailView;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (strong, nonatomic) IBOutlet KLScrollSelect *scrollSelect;
@property (nonatomic, strong) NSArray* leftColumnData;
@property (nonatomic, strong) NSArray* rightColumnData;

@property (weak, nonatomic) IBOutlet UIImageView *imvFull;
@property (weak, nonatomic) IBOutlet UILabel *lblDishName;
@property (weak, nonatomic) IBOutlet UIButton *lblRestaurantName;
@property (weak, nonatomic) IBOutlet UIImageView *imvHeart;
@property (weak, nonatomic) IBOutlet UILabel *lblCountLike;
@property (weak, nonatomic) IBOutlet UIImageView *imvRate1;
@property (weak, nonatomic) IBOutlet UIImageView *imvRate2;
@property (weak, nonatomic) IBOutlet UIImageView *imvRate3;
@property (weak, nonatomic) IBOutlet UILabel *lblLike;
@property (weak, nonatomic) IBOutlet UILabel *lblUploaded;

@property (weak, nonatomic) IBOutlet UIView *menuView;
@property (weak, nonatomic) IBOutlet UIButton *btnMenu1;
@property (weak, nonatomic) IBOutlet UIButton *btnMenu2;
@property (weak, nonatomic) IBOutlet UIButton *btnMenu3;

@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

//@property (weak, nonatomic) IBOutlet FXBlurView *menuFlur;

- (IBAction)keyPress:(UIButton *)sender;

@end
