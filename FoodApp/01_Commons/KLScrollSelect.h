//
//  KLViewController.h
//  KLScrollSelectViewController
//
//  Created by Kieran Lafferty on 2013-04-02.
//  Copyright (c) 2013 KieranLafferty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DLStarRatingControl.h"

#define kDefaultCellImageEdgeInset UIEdgeInsetsMake(5, 5, 50, 5)


@class KLScrollSelectViewController, KLScrollingColumn, KLScrollSelect,KLIndexPath, KLImageCell;

@protocol KLImageCellDelegate <NSObject>
@optional
-(void)handlePinchInGesture:(UIGestureRecognizer *)recognizer;

@end

@protocol KLScrollingColumnDelegate <NSObject>
@optional
- (void) willUpdateContentOffsetForColumn: (KLScrollingColumn*) column;
- (void) didUpdateContentOffsetForColumn: (KLScrollingColumn*) column;
@end
@protocol KLScrollSelectDelegate <NSObject>
@optional
- (void)scrollSelect:(KLScrollSelect *)tableView didSelectCellAtIndexPath:(NSIndexPath *)indexPath andRect:(CGRect)rect;
@end
@protocol KLScrollSelectDataSource <NSObject>
@required
- (NSInteger)scrollSelect:(KLScrollSelect *)scrollSelect numberOfRowsInColumnAtIndex:(NSInteger)index;
- (UITableViewCell*) scrollSelect:(KLScrollSelect*) scrollSelect cellForRowAtIndexPath:(KLIndexPath *)indexPath;
@optional
- (CGFloat) scrollSelect: (KLScrollSelect*) scrollSelect heightForColumnAtIndex: (NSInteger) index;
- (CGFloat) scrollRateForColumnAtIndex: (NSInteger) index;
- (NSInteger)scrollSelect:(KLScrollSelect *)scrollSelect numberOfSectionsInColumnAtIndex:(NSInteger)index;
// Default is 1 if not implemented
- (NSInteger)numberOfColumnsInScrollSelect:(KLScrollSelectViewController *)scrollSelect;
@end

@interface KLScrollSelect : UIView <UITableViewDelegate, UITableViewDataSource, KLScrollingColumnDelegate>
@property (nonatomic, strong) NSArray* columns;
@property (nonatomic, weak) IBOutlet id<KLScrollSelectDataSource> dataSource;
@property (nonatomic, weak) IBOutlet id<KLScrollSelectDelegate> delegate;
- (NSInteger)scrollSelect:(KLScrollSelect *)scrollSelect numberOfRowsInColumnAtIndex:(NSInteger)index;
- (NSInteger)scrollSelect:(KLScrollSelect *)scrollSelect numberOfSectionsInColumnAtIndex:(NSInteger)index;
- (CGFloat) scrollSelect: (KLScrollSelect*) scrollSelect heightForColumnAtIndex: (NSInteger) index;

//Actions
- (UITableViewCell*) cellForRowAtIndexPath:(NSIndexPath *)indexPath withColumn:(NSInteger)theColumn;
- (NSInteger)numberOfColumnsInScrollSelect:(KLScrollSelect *)scrollSelect;
- (CGFloat) scrollRateForColumnAtIndex: (NSInteger) index;
- (KLScrollingColumn*) columnAtIndex:(NSInteger) index;

-(void) startScrollingDriver;
-(void) stopScrollingDriver;

@end


@interface KLScrollSelectViewController : UIViewController <KLScrollSelectDataSource, KLScrollSelectDelegate>
@property (nonatomic, strong) KLScrollSelect* scrollSelect;
@end

@interface KLScrollingColumn : UITableView <UIScrollViewDelegate, UITableViewDelegate>
@property (nonatomic, weak) id<KLScrollingColumnDelegate> columnDelegate;
@property (nonatomic) CGFloat offsetDelta;
@property (nonatomic) CGFloat scrollRate;
@property (nonatomic) CGFloat offsetAccumulator;
- (void)resetContentOffsetIfNeeded;
@end


@interface KLImageCell : UITableViewCell

@property (nonatomic, strong) UIImageView* image;
@property (nonatomic, strong) UIView* bottomView;
@property (nonatomic, strong) UILabel* label;
@property (nonatomic, strong) UILabel* subLabel;
@property (nonatomic, strong) UIImageView* heartImage;
@property (nonatomic, strong) UILabel* countLikeLabel;
@property (nonatomic, strong) DLStarRatingControl* averRatingStar;

@property (nonatomic, strong) NSNumber* remColum;
@property (nonatomic, strong) NSNumber* remSection;
@property (nonatomic, strong) NSNumber* remRow;

@property (nonatomic, weak) id<KLImageCellDelegate> cellDelegate;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchIn;

@end

@interface KLIndexPath : NSObject
+ (NSIndexPath *)indexPathForRow:(NSInteger) row
                       inSection:(NSInteger) section
                        inColumn:(NSInteger) column;

@property(nonatomic, readonly) NSInteger column;
@property(nonatomic,readonly) NSInteger section;
@property(nonatomic,readonly) NSInteger row;

-(NSIndexPath *)innerIndexPath;
@end