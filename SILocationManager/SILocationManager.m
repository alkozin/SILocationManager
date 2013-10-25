//
// SILocationManager.m
//
// Created by Alexander Kozin (https://github.com/alkozin )
// Copyright (c) 2013 (http://Siberian.pro )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

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

+ (void)addLocationDelegate:(id <SIUserLocationDelegate>)delegate
{
    [[self sharedSILocationManager] addLocationDelegate:delegate];
}

- (void)addLocationDelegate:(id <SIUserLocationDelegate>)delegate
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

+ (void)removeLocationDelegate:(id <SIUserLocationDelegate>)delegate
{
    [[self sharedSILocationManager] removeLocationDelegate:delegate];
}

- (void)removeLocationDelegate:(id <SIUserLocationDelegate>)delegate
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
    for (id <SIUserLocationDelegate> delegate in self.locationDelegates)
        [self notifyDelegate:delegate];
    
    [self sendLocationToAnalyticsService];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    for (id <SIUserLocationDelegate> delegate in self.locationDelegates) {
        if ([delegate respondsToSelector:@selector(userLocationDidFailToUpdate:)])
            [delegate userLocationDidFailToUpdate:error];
    }
}

- (void)notifyDelegate:(id <SIUserLocationDelegate>)delegate
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
