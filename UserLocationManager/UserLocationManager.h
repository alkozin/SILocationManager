//
//  UserLocation.h
//  Flamp
//
//  Created by Alexander Kozin on 2/8/12.
//  Copyright (c) 2012 Cookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol UserLocationDelegate <NSObject>

@required
- (void)userLocationDidUpdate:(CLLocation*)location;
@optional
- (void)userLocationDidFailToUpdate:(NSError*)error;

@end

@interface UserLocationManager : NSObject <CLLocationManagerDelegate>

/**
 Adds object to list of location receivers
 
 @param delegate User location receiver
 */
+ (void)addLocationDelegate:(id <UserLocationDelegate>)delegate;

/**
 Removes object from list of location receivers
 
 @warning Should be called before object deallocation
 
 @param delegate User location receiver
 */
+ (void)removeLocationDelegate:(id <UserLocationDelegate>)delegate;

@end
