//
//  KLViewController.m
//  KLScrollSelectViewController
//
//  Created by Kieran Lafferty on 2013-04-02.
//  Copyright (c) 2013 KieranLafferty. All rights reserved.
//

#import "KLScrollSelect.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

#define TRANSLATED_INDEX_PATH( __INDEXPATH__, __TOTALROWS__ ) [self translatedIndexPath:__INDEXPATH__ forTotalRows:__TOTALROWS__]
#define ROUND_NEAREST_HALF(__NUM__)
@implementation KLScrollSelectViewController
-(void) viewDidLoad {
    [super viewDidLoad];
    self.scrollSelect = [[KLScrollSelect alloc] initWithFrame: self.view.bounds];
    [self.scrollSelect setDataSource: self];
    [self.scrollSelect setDelegate: self];
    [self.view addSubview:self.scrollSelect];
}
- (NSInteger)scrollSelect:(KLScrollSelect *)scrollSelect numberOfRowsInColumnAtIndex:(NSInteger)index {
    return 0;
}
- (UITableViewCell*) scrollSelect:(KLScrollSelect*) scrollSelect cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}
@end
@interface KLScrollSelect()
-(void) populateColumns;
-(NSIndexPath*) translatedIndexPath: (NSIndexPath*) indexPath forTotalRows:(NSInteger) totalRows;
-(NSInteger) indexOfColumn:(KLScrollingColumn*) column;
-(void) synchronizeContentOffsetsWithDriver:(KLScrollingColumn*) drivingColumn;
-(void) startScrollingDriver;
-(void) stopScrollingDriver;


-(NSArray*) columnsWithoutColumn:(KLScrollingColumn*) column;
-(void) updateDriverOffset;


@property (nonatomic) BOOL shouldResumeAnimating;
@property (nonatomic,strong) NSArray* passengers;
@property (nonatomic,strong) KLScrollingColumn* driver;
@property (nonatomic,strong) KLScrollingColumn* smallestColumn;
@property (nonatomic, strong) NSTimer* animationTimer;

-(BOOL) animating;
@end
@implementation KLScrollSelect
-(BOOL) animating {
    return  (BOOL)self.animationTimer;
}
-(NSArray*) passengers {
    return [self columnsWithoutColumn: self.driver];
}
-(NSArray*) columnsWithoutColumn:(KLScrollingColumn*) column {
    return [self.columns filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return evaluatedObject != column;
    }]];
}
-(void) layoutSubviews {
    [super layoutSubviews];
    [self populateColumns];
    [self startScrollingDriver];
    
}

-(void) synchronizeColumnsForMainDriver {
    [self synchronizeContentOffsetsWithDriver: self.driver];
}
-(void) populateColumns {
    NSInteger numberOfColumns = [self numberOfColumnsInScrollSelect:self];
    NSMutableArray* columns = [[NSMutableArray alloc] initWithCapacity:numberOfColumns];
    CGFloat columnWidth = self.frame.size.width/[self numberOfColumnsInScrollSelect:self];
    
    for (NSInteger count = 0; count < numberOfColumns;  count++) {
        //Make the frame the entire height and the width the width of the superview divided by number of columns
        CGRect columnFrame = CGRectMake(columnWidth * count, 0, columnWidth, self.frame.size.height);
        KLScrollingColumn* column = [[KLScrollingColumn alloc] initWithFrame:columnFrame style:UITableViewStylePlain];
        
        [column setDataSource:self];
        [column setRowHeight: [self scrollSelect:self heightForColumnAtIndex:count]];
        [column setSeparatorStyle: UITableViewCellSeparatorStyleNone];
        [column setBackgroundColor:[UIColor clearColor]];
        [column setColumnDelegate:self];
        [column setScrollRate: [self.dataSource scrollRateForColumnAtIndex: count]];
        [column setDelegate:self];
        [columns addObject: column];
        
        if (![[self subviews] containsObject: column]) {
            [self addSubview:column];
        }
    }
    self.columns = columns;
    NSInteger smallestCount = -1;
    for (KLScrollingColumn* column in self.columns) {
        NSInteger currentNumRows =  [self tableView:column numberOfRowsInSection:0];
        if (smallestCount < 0 || currentNumRows < smallestCount) {
            smallestCount = currentNumRows;
            self.smallestColumn = column;
        }
    }
    
}

#pragma mark - Driver & Passenger animation implementation
-(void) synchronizeContentOffsetsWithDriver:(KLScrollingColumn*) drivingColumn {
    if (self.driver.offsetDelta == 0)
        return;
    for (KLScrollingColumn* currentColumn in self.passengers) {
        CGPoint currentOffset = currentColumn.contentOffset;
        CGFloat relativeScrollRate = currentColumn.scrollRate / drivingColumn.scrollRate;
        currentOffset.y += drivingColumn.offsetDelta* relativeScrollRate;
        
        //Only move passenger when offset has accumulated to the min pixel movement threshold (0.5)
        currentColumn.offsetAccumulator += fabs(drivingColumn.offsetDelta * relativeScrollRate);
        if (currentColumn.offsetAccumulator >= 0.5) {
            [currentColumn setContentOffset: currentOffset];
            currentColumn.offsetAccumulator = 0;
        }
    }
}
-(void) startScrollingDriver {
    return;
    
    self.driver = self.columns[0];
    
    if (self.animating) {
        return;
    }
    CGFloat animationDuration = 0.5f / self.driver.scrollRate;
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval: animationDuration
                                                           target:self
                                                         selector:@selector(updateDriverAnimation)
                                                         userInfo:nil
                                                          repeats:YES];
    [self.animationTimer fire];
}

-(void) updateDriverAnimation {
    [self updateDriverOffset];
}
-(void) updateDriverOffset {
    CGFloat pointChange = 0.5;
    CGPoint newOffset = self.driver.contentOffset;
    newOffset.y = newOffset.y + pointChange;
    [self.driver setContentOffset: newOffset];
}

- (void)stopScrollingDriver {
    if (!self.animating) {
        return;
    }
    [self.driver.layer removeAllAnimations];
    [self.animationTimer invalidate];
    self.animationTimer = nil;
}

#pragma mark - UIScrollViewDelegate implementation
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    //Stop animating driver
    [self setDriver: (KLScrollingColumn*) scrollView];
    [self stopScrollingDriver];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //Start animating driver
    [self startScrollingDriver];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self startScrollingDriver];
    }
}

#pragma  UITableViewDataSource implementation
//Column data source implementation
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger columnIndex = [self indexOfColumn: (KLScrollingColumn*)tableView];
    NSInteger numberOfRows = [self scrollSelect:self numberOfRowsInColumnAtIndex: columnIndex] * 3;
    return numberOfRows;
}

-(NSInteger) numberOfSectionsInTableView:(KLScrollingColumn *)tableView {
    return [self scrollSelect:self numberOfSectionsInColumnAtIndex:[self indexOfColumn: tableView]];
}
-(UITableViewCell*) tableView:(KLScrollingColumn *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger columnIndex = [self indexOfColumn:tableView];
    NSIndexPath* translatedIndex = TRANSLATED_INDEX_PATH(indexPath, [self scrollSelect:self
                                                           numberOfRowsInColumnAtIndex:columnIndex]);

    return [self cellForRowAtIndexPath:translatedIndex withColumn:columnIndex];

}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger columnIndex = [self indexOfColumn: (KLScrollingColumn*)tableView];
    NSIndexPath* translatedIndex = TRANSLATED_INDEX_PATH(indexPath, [self scrollSelect: self
                                                           numberOfRowsInColumnAtIndex: columnIndex]);
    
    CGRect cellFrameInSuperview = [tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:(long)indexPath.row inSection:0]];
    NSLog(@"aa2:%f, %f", tableView.contentOffset.y, cellFrameInSuperview.origin.y);
    
    cellFrameInSuperview = [tableView convertRect:cellFrameInSuperview toView:self];
    NSLog(@"aa3:%f, %f", tableView.contentOffset.y, cellFrameInSuperview.origin.y);
    
    if (cellFrameInSuperview.origin.y < 0) {
        cellFrameInSuperview = CGRectMake(cellFrameInSuperview.origin.x, 0, cellFrameInSuperview.size.width, cellFrameInSuperview.size.height);
    }
    
    cellFrameInSuperview = CGRectMake(cellFrameInSuperview.origin.x, cellFrameInSuperview.origin.y + self.frame.origin.y, cellFrameInSuperview.size.width, cellFrameInSuperview.size.height);
    
    if ([self.delegate respondsToSelector:@selector(scrollSelect:didSelectCellAtIndexPath:andRect:)]) {
        [self.delegate scrollSelect:self didSelectCellAtIndexPath:[KLIndexPath indexPathForRow: translatedIndex.row
                                                                                     inSection: translatedIndex.section
                                                                                      inColumn: columnIndex] andRect:cellFrameInSuperview];
    }
}

#pragma mark - Delegate Implementation
- (CGFloat) scrollSelect: (KLScrollSelect*) scrollSelect heightForColumnAtIndex: (NSInteger) index {
    if ([self.dataSource respondsToSelector:@selector(scrollSelect:heightForColumnAtIndex:)]) {
        return [self.dataSource scrollSelect:self heightForColumnAtIndex:index];
    }
    else return 150.0;
}
-(NSIndexPath*) translatedIndexPath: (NSIndexPath*) indexPath forTotalRows:(NSInteger) totalRows{
    return [NSIndexPath indexPathForRow: indexPath.row % totalRows
                              inSection: indexPath.section];
}

#pragma mark - Datasource Implementation
- (NSInteger)scrollSelect:(KLScrollSelect *)scrollSelect numberOfRowsInColumnAtIndex:(NSInteger)index {
    return [self.dataSource scrollSelect: self
             numberOfRowsInColumnAtIndex: index];
}
- (NSInteger)scrollSelect:(KLScrollSelect *)scrollSelect numberOfSectionsInColumnAtIndex:(NSInteger)index {
    if ([self.dataSource respondsToSelector:@selector(scrollSelect:numberOfSectionsInColumnAtIndex:)]) {
        return [self.dataSource scrollSelect:self numberOfSectionsInColumnAtIndex: index];
    }
    else return 1;
}

-(NSInteger) numberOfColumnsInScrollSelect:(KLScrollSelectViewController *)scrollSelect {
    if ([self.dataSource respondsToSelector:@selector(numberOfColumnsInScrollSelect:)]) {
        return [self.dataSource numberOfColumnsInScrollSelect:scrollSelect];
    }
    else return 1;
}
- (UITableViewCell*) cellForRowAtIndexPath:(NSIndexPath *)indexPath withColumn:(NSInteger)theColumn {

    KLIndexPath *kl_indexPath = (KLIndexPath *)[KLIndexPath indexPathForRow:indexPath.row inSection:indexPath.section inColumn:theColumn];
    
    return [self.dataSource scrollSelect:self cellForRowAtIndexPath:kl_indexPath];

}
- (KLScrollingColumn*) columnAtIndex:(NSInteger) index {
    return [self.columns objectAtIndex:index];
}
- (CGFloat) scrollRateForColumnAtIndex: (NSInteger) index {
    if ([self.dataSource respondsToSelector:@selector(scrollRateForColumnAtIndex:)]) {
        return [self.dataSource scrollRateForColumnAtIndex:index];
    }
    else return 10.0;
}
-(NSInteger) indexOfColumn:(KLScrollingColumn*) column {
    return [self.columns indexOfObject: column];
}
- (void) willUpdateContentOffsetForColumn: (KLScrollingColumn*) column {
    if (column == self.driver) {
    }
}
- (void) didUpdateContentOffsetForColumn: (KLScrollingColumn*) column {
    if (column == self.driver) {
        [self synchronizeColumnsForMainDriver];
    }
}
@end


@interface KLScrollingColumn()
{
    int mTotalCellsVisible;
    BOOL isResettingContent;
    NSInteger _totalRows;
}
- (void) resetContentOffsetIfNeeded;
- (BOOL) didReachBottomBounds;
- (BOOL) didReachTopBounds;
@end

@implementation KLScrollingColumn
- (BOOL) didReachTopBounds {
    return self.contentOffset.y <= 0.0;
}
- (BOOL) didReachBottomBounds {
    return self.contentOffset.y >= ( self.contentSize.height - self.bounds.size.height);
}
- (void)resetContentOffsetIfNeeded
{
    CGPoint contentOffset  = self.contentOffset;
    //check the top condition
    //check if the scroll view reached its top.. if so.. move it to center.. remember center is the start of the data repeating for 2nd time.
    if ([self didReachTopBounds] || [self didReachBottomBounds]) {
        isResettingContent = YES;
        if([self didReachTopBounds])
            contentOffset.y = self.contentSize.height/3.0f;
        else if([self didReachBottomBounds] )//scrollview content offset reached bottom minus the height of the tableview
            //this scenario is same as the data repeating for 2nd time minus the height of the table view
            contentOffset.y = self.contentSize.height/3.0f - self.bounds.size.height;
        [self setContentOffset: contentOffset];
        isResettingContent = NO;
    }
}

//The heart of this app.
//this function iterates through all visible cells and lay them in a circular shape
#pragma mark Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    mTotalCellsVisible = self.frame.size.height / self.rowHeight;
    [self resetContentOffsetIfNeeded];
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    [self setShowsHorizontalScrollIndicator:NO];
    [self setShowsVerticalScrollIndicator:NO];
}

#pragma mark - Touch methods
-(void) setContentOffset:(CGPoint)contentOffset {
    
    if ([self.columnDelegate respondsToSelector:@selector(willUpdateContentOffsetForColumn:)] && !isResettingContent) {
        [self.columnDelegate willUpdateContentOffsetForColumn:self];
    }
    if (!isResettingContent) {
        self.offsetDelta = contentOffset.y - self.contentOffset.y;
    }
    [super setContentOffset: contentOffset];
    if ([self.columnDelegate respondsToSelector:@selector(didUpdateContentOffsetForColumn:)] && !isResettingContent) {
        [self.columnDelegate didUpdateContentOffsetForColumn:self];
    }
}
@end

@implementation KLImageCell

-(void) willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    // On iOS 5 willMoveToSuperview method always gets called, so by checking existence of self.image ,
    // we prevent imageView initialization of reused cells otherwise we face with low performance while scrolling
    if (self.image == nil) {
        self.backgroundColor = [UIColor clearColor];
        self.image = [[UIImageView alloc] initWithFrame: CGRectMake( kDefaultCellImageEdgeInset.left,
                                                                    kDefaultCellImageEdgeInset.top,
                                                                    self.frame.size.width - (kDefaultCellImageEdgeInset.left + kDefaultCellImageEdgeInset.right),
                                                                    self.frame.size.height - (kDefaultCellImageEdgeInset.top + kDefaultCellImageEdgeInset.bottom))];
        [self.image.layer setBorderWidth: 1.0];
        [self.image.layer setBorderColor: [UIColor colorWithRed: 1
                                                          green: 1
                                                           blue: 1
                                                          alpha: 0.4].CGColor];
//        [self.image.layer setCornerRadius:6.0];
        
        [self.image setClipsToBounds:YES];
        
        [self addSubview: self.image];
        
        self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(self.image.frame.origin.x,
                                                                   self.image.frame.size.height,
                                                                   self.image.frame.size.width,
                                                                   self.frame.size.height - self.image.frame.size.height)];
        self.bottomView.backgroundColor = [UIColor whiteColor];
//        [kApplicationDelegate setMaskTo:self.bottomView byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight angleCorner:6.0];
        [self addSubview:self.bottomView];
        
        self.label = [[UILabel alloc] initWithFrame: CGRectMake(5.0, 5.0, self.bottomView.frame.size.width - 10.0, 15.0)];
        self.label.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.label setBackgroundColor:[UIColor clearColor]];
        [self.label setTextColor:[UIColor colorWithRed:96.0/255 green:99.0/255 blue:102.0/255 alpha:1.0]];
        [self.label setTextAlignment:NSTextAlignmentLeft];
        [self.label setFont:[UIFont fontWithName:@"MyriadPro-Regular" size:11.0]];
        [self.bottomView addSubview:self.label];
        
        self.subLabel = [[UILabel alloc] initWithFrame: CGRectMake(5.0, 20.0, self.bottomView.frame.size.width - 10.0, 15.0)];
        self.subLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.subLabel setBackgroundColor:[UIColor clearColor]];
        [self.subLabel setTextColor:[UIColor colorWithRed:202.0/255 green:193.0/255 blue:191.0/255 alpha:1.0]];
        [self.subLabel setTextAlignment:NSTextAlignmentLeft];
        [self.subLabel setFont:[UIFont fontWithName:@"MyriadPro-Regular" size:8.0]];
        [self.bottomView addSubview:self.subLabel];
        
        self.heartImage = [[UIImageView alloc] initWithFrame:CGRectMake(5.0, 40.0, 10, 10)];
        self.heartImage.image = [UIImage imageNamed:@"like.png"];
        self.heartImage.contentMode = UIViewContentModeScaleAspectFit;
        [self.bottomView addSubview:self.heartImage];
        
        self.countLikeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 35.0, 40.0, 20)];
        self.countLikeLabel.textColor = [UIColor colorWithRed:120.0/255 green:120.0/255 blue:120.0/255 alpha:1.0];
        [self.countLikeLabel setFont:[UIFont fontWithName:@"MyriadPro-Regular" size:12.0]];
        [self.bottomView addSubview:self.countLikeLabel];
        
        self.averRatingStar = [[DLStarRatingControl alloc] initWithFrame:CGRectMake(65.0, 35.0, self.bottomView.frame.size.width - 60.0, 20) andStars:5 isFractional:NO andScale:1.5];
        self.averRatingStar.backgroundColor = [UIColor clearColor];
        self.averRatingStar.rating = 2;
        self.averRatingStar.userInteractionEnabled = NO;
        [self.bottomView addSubview:self.averRatingStar];
        
        [self.layer setShouldRasterize:YES];
        [self.layer setRasterizationScale: [UIScreen mainScreen].scale];
        
        UIPinchGestureRecognizer *pinchIn = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchInGesture:)];
        [self addGestureRecognizer:pinchIn];
    }
}

-(void)handlePinchInGesture:(UIGestureRecognizer *)recognizer{
    [self.cellDelegate handlePinchInGesture:recognizer];
}


@end

@interface KLIndexPath()
@property (nonatomic,strong ) NSIndexPath *innerIndexPath;
@end

@implementation KLIndexPath


- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _innerIndexPath = nil;
    }
    return self;
}

+ (KLIndexPath *)indexPathForRow:(NSInteger) row
                       inSection:(NSInteger) section
                        inColumn:(NSInteger) column
{
    
    KLIndexPath *retVal = [[self alloc] init];
    retVal->_innerIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
    retVal->_column = column;
    return retVal;
}

-(NSIndexPath *)innerIndexPath
{
    return self->_innerIndexPath;
}

-(NSInteger)  section
{
    return self->_innerIndexPath.section;
}
-(NSInteger)  row
{
    return self->_innerIndexPath.row;
}

@end