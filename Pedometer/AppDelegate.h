//
//  AppDelegate.h
//  Pedometer
//
//  Created by 林盈志 on 6/18/14.
//  Copyright (c) 2014 林盈志. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property   (nonatomic) UIBackgroundTaskIdentifier backgroundTask;

@property (nonatomic) CLLocationManager* locationManager;


@property  (nonatomic) int32_t count;
@property (nonatomic) NSTimer* locateTimer;


@property (nonatomic) UILocalNotification* debugNotification;


@end
