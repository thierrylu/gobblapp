//
//  SynLocationManager.m
//  Syn
//
//  Created by Phuc, Tran Huu on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



#import "LocationManager.h"

@interface LocationManager () {
	
	BOOL _isStarted;
}

@end


@implementation LocationManager


static __strong LocationManager *_LocationManager;


@synthesize locationStatus=_locationStatus, address=_address, countryISO2=_countryISO2, gmt=_gmt, currentLocation=_currentLocation;


+ (void)initialize {
	_LocationManager = nil;
}


#pragma mark - Class's static constructors
+ (__autoreleasing LocationManager *)locationManager {
	if (_LocationManager) return _LocationManager;
	
	@synchronized (self) {
		if (!_LocationManager) _LocationManager = [[LocationManager alloc] init];
	}
	return _LocationManager;
}


#pragma mark - Class's constructors
- (id)init {
	self = [super init];
	if (self) {
		_LocationManager = self;
		
		_locationStatus	 = kCLAuthorizationStatusNotDetermined;
		_currentLocation = nil;
		_isStarted = NO;
		
		// Initialize location manager
		_locationManager = [[CLLocationManager alloc] init];
		[_locationManager setDistanceFilter:kCLLocationAccuracyNearestTenMeters];
		[_locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
        //        [_locationManager setDistanceFilter:kCLLocationAccuracyBest];
        //		[_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
		[_locationManager setDelegate:self];
        
        CLLocationCoordinate2D coord;
        coord.latitude   = 0.0;
        coord.longitude  = 0.0;
        _currentLocation = [[CLLocation alloc] initWithCoordinate:coord
                                                         altitude:0
                                               horizontalAccuracy:0
                                                 verticalAccuracy:0
                                                        timestamp:[NSDate date]];
        
		if (!_address) {
			_address = @"";
		}
		if (!_countryISO2) {
			_countryISO2 = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
		}
		if (!_gmt) {
			_gmt = [NSNumber numberWithInteger:[[NSTimeZone localTimeZone] secondsFromGMT] / 3600];
		}
		if (!_currentLocation) {
			CLLocationCoordinate2D coord;
			coord.latitude   = 0.0;
			coord.longitude  = 0.0;
			
			_currentLocation = [[CLLocation alloc] initWithCoordinate:coord
															 altitude:0.0
												   horizontalAccuracy:0
													 verticalAccuracy:0
															timestamp:[NSDate date]];
		}

		// Update location
		[self _updateInfo];
	}
	return self;
}


#pragma mark - Class's public methods
- (void)startLocation {
    if (_locationStatus == kCLAuthorizationStatusDenied) {
    }
    else {
        if (_isStarted) return;
        
        [_locationManager startUpdatingLocation];
        _isStarted = YES;
    }
}
- (void)stopLocation {
	[_locationManager stopUpdatingLocation];
	_isStarted = NO;
}
- (void)updateLocation {
	/* Condition validation */
	if (_locationStatus != kCLAuthorizationStatusAuthorized) return;
	
	if ([[NSThread currentThread] isMainThread]) {
		[self performSelectorInBackground:@selector(updateLocation)
							   withObject:nil];
	}
	else {
		@autoreleasepool {
//			__autoreleasing CLLocation *location = _locationManager.location;
            
            //Hard code location
            CLLocationCoordinate2D coord;
            coord.latitude   = 38.8951;
            coord.longitude  = -77.0367;
            
            __autoreleasing CLLocation *location = [[CLLocation alloc] initWithCoordinate:coord
                                                                                 altitude:0.0
                                                                       horizontalAccuracy:0
                                                                         verticalAccuracy:0
                                                                                timestamp:[NSDate date]];
            
			if (location) [self locationManager:_locationManager didUpdateLocations:[NSArray arrayWithObject:location]];
		}
	}
}

- (void)lookupAddress:(__autoreleasing NSString *)address {
	if ([[NSThread currentThread] isMainThread]) {
		[self performSelectorInBackground:@selector(lookupAddress:)
							   withObject:address];
	}
	else {
		@autoreleasepool {
			/** Get location */
            
            CLGeocoder *geocoder = [[CLGeocoder alloc] init];
            
            [geocoder geocodeAddressString:address
                         completionHandler:^(NSArray *placemarks, NSError *error) {
                             if (placemarks.count > 0) {
                                 CLPlacemark *geocodedPlacemark = [placemarks objectAtIndex:0];
                                 
                                 // Get coordinate
                                 CLLocationCoordinate2D coord = geocodedPlacemark.location.coordinate;
                                 if (_currentLocation) _currentLocation = nil;
                                 
                                 _currentLocation = [[CLLocation alloc] initWithCoordinate:coord
                                                                                  altitude:0.0
                                                                        horizontalAccuracy:0
                                                                          verticalAccuracy:0
                                                                                 timestamp:[NSDate date]];
                             }
                             else{
                                 if (error) {
                                    
                                 }
                             }
                         }];
		}
	}
}

// Revert Location by using CLGeocoder instead maps.google.com
-(void) _revertLocation:(CLLocation*) location
{
    
    CLGeocoder *reverseGeocoder = [[CLGeocoder alloc] init];
    [reverseGeocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (error){
             return;
         }
         
         CLPlacemark *myPlacemark = [placemarks objectAtIndex:0];
         _countryISO2 = myPlacemark.ISOcountryCode;
         
//         _address =[NSString stringWithFormat:@"%@, %@, %@, %@", [myPlacemark.addressDictionary objectForPath:@"Street"], [myPlacemark.addressDictionary objectForPath:@"SubAdministrativeArea"], [myPlacemark.addressDictionary objectForPath:@"City"], [myPlacemark.addressDictionary objectForPath:@"Country"]];
         
         //NSLog(@"%@", _address);
         
         // Get timezone
         
//         __autoreleasing NSString *urlTimezone = [NSString stringWithFormat:@"http://api.geonames.org/timezoneJSON?lat=%f&lng=%f&username=limonapp", myPlacemark.location.coordinate.latitude, myPlacemark.location.coordinate.longitude];
//         __autoreleasing NSData	 *timezone	  = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlTimezone]];
//         __autoreleasing NSDictionary *info	  = [SynJSONObject ObjectFromData:timezone];
         
         // Get GMT
         if (!_gmt) _gmt = [NSNumber numberWithInteger:[[NSTimeZone localTimeZone] secondsFromGMT] / 3600];
         
     }];
}


- (void)_updateInfo {
	if ([[NSThread currentThread] isMainThread]) {
		[self performSelectorInBackground:@selector(_updateInfo)
							   withObject:nil];
	}
	else {
		@autoreleasepool {
//			__autoreleasing CLLocation *location = _locationManager.location;
            
            //Hard code location
            CLLocationCoordinate2D coord;
            coord.latitude   = 38.8951;
            coord.longitude  = -77.0367;
            
            __autoreleasing CLLocation *location = [[CLLocation alloc] initWithCoordinate:coord
                                                                                 altitude:0.0
                                                                       horizontalAccuracy:0
                                                                         verticalAccuracy:0
                                                                                timestamp:[NSDate date]];
            
            
			if (location) [self locationManager:_locationManager didUpdateLocations:[NSArray arrayWithObject:location]];
			else {
			}
		}
	}
}

#pragma mark - CLLocationManagerDelegate's members
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
}
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    _locationStatus = status;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Notification_LocationService" object:nil];
}

- (void)locationManager:(CLLocationManager *)manager
	 didUpdateLocations:(NSArray *)locations{
    
    __autoreleasing CLLocation *newLocation = [locations objectAtIndex:0];
    
    CLLocationDistance distance = 0.0;
	if (_currentLocation) {
        distance = [newLocation distanceFromLocation:_currentLocation];
		if (distance < 10) return;
	}
    
	if (_currentLocation) _currentLocation = nil;
	_currentLocation = newLocation;
    
    if(distance>1000)
    {
        [self performSelectorInBackground:@selector(_revertLocation:) withObject:_currentLocation];
    }
}

@end
