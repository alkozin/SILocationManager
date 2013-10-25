//
//  UserLocation.m
//
//  Created by Alexander Kozin on 2/8/12.
//  Copyright (c) 2012 Cookie. All rights reserved.
//

#import "SILocationManager.h"

@interface SILocationManager ()

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSMutableArray *locationDelegates;

@end

@implementation SILocationManager

+ (instancetype)sharedSILocationManager
{
    static SILocationManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
        [shared initSILocationManager];
    });
    
    return shared;
}

- (void)initSILocationManager
{
    [self configureLocationManager];
    [self prepareDelegatesArray];
}

+ (void)addLocationDelegate:(id <UserLocationDelegate>)delegate
{
    [[self sharedSILocationManager] addLocationDelegate:delegate];
}

- (void)addLocationDelegate:(id <UserLocationDelegate>)delegate
{
    if (delegate) {
        // Start location updating if object is first in receivers list
        if (self.locationDelegates.count == 0)
            [self.locationManager startUpdatingLocation];
    
        [self.locationDelegates addObject:delegate];
        
        // Notify receiver if location already exists
        CLLocation *location = self.locationManager.location;
        if (location)
            [self notifyDelegate:delegate];
    }
}

+ (void)removeLocationDelegate:(id <UserLocationDelegate>)delegate
{
    [[self sharedSILocationManager] removeLocationDelegate:delegate];
}

- (void)removeLocationDelegate:(id <UserLocationDelegate>)delegate
{
    if (delegate) {
        [self.locationDelegates removeObject:delegate];
        
        // Stop location updating if object is last in receivers list
        if (self.locationDelegates.count == 0)
            [self.locationManager stopUpdatingLocation];
    }
}

- (void)configureLocationManager
{
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    // Set the value of the filter to prevent too frequent location sending
    [locationManager setDistanceFilter:100.f];

    if ([locationManager respondsToSelector:@selector(setPausesLocationUpdatesAutomatically:)])
        [locationManager setPausesLocationUpdatesAutomatically:TRUE];
    
    [self setLocationManager:locationManager];
}

- (void)prepareDelegatesArray
{
    [self setLocationDelegates:[NSMutableArray array]];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    for (id <UserLocationDelegate> delegate in self.locationDelegates)
        [self notifyDelegate:delegate];
    
    [self sendLocationToAnalyticsService];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    for (id <UserLocationDelegate> delegate in self.locationDelegates) {
        if ([delegate respondsToSelector:@selector(userLocationDidFailToUpdate:)])
            [delegate userLocationDidFailToUpdate:error];
    }
}

- (void)notifyDelegate:(id <UserLocationDelegate>)delegate
{
    [delegate userLocationDidUpdate:self.locationManager.location];
}

#pragma mark - Analytics location

- (void)sendLocationToAnalyticsService
{
// Override point for customization location sending
//    CLLocationCoordinate2D coordinate = self.locationManager.location.coordinate;
//    [Flurry setLatitude:coordinate.latitude
//              longitude:coordinate.longitude
//     horizontalAccuracy:location.horizontalAccuracy
//       verticalAccuracy:location.verticalAccuracy];
}

@end
