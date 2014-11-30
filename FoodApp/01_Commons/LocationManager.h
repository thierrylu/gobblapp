//
//  SynLocationManager.h
//  Syn
//
//  Created by Phuc, Tran Huu on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@interface LocationManager : NSObject<CLLocationManagerDelegate> {

@private
	CLAuthorizationStatus		_locationStatus;
	__strong CLLocationManager	*_locationManager;
	
	__strong NSNumber			*_gmt;
	__strong NSString			*_address;
	__strong NSString			*_countryISO2;
	__strong CLLocation			*_currentLocation;
}

@property (nonatomic, readonly) CLAuthorizationStatus locationStatus;

@property (strong, nonatomic, readonly) NSNumber   *gmt;
@property (strong, nonatomic, readonly) NSString   *address;
@property (strong, nonatomic, readonly) NSString   *countryISO2;
@property (strong, nonatomic, readonly) CLLocation *currentLocation;


/**
 * Create default location manager
 */
+ (__autoreleasing LocationManager *)locationManager;


/**
 * Start location service
 */
- (void)startLocation;

/**
 * Stop location service
 */
- (void)stopLocation;

/**
 * Look up the Google Map for specific input address
 */
- (void)lookupAddress:(__autoreleasing NSString *)address;

/**
 * Get current location
 */
- (void)updateLocation;

@end
