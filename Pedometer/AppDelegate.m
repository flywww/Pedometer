//
//  AppDelegate.m
//  Pedometer
//
//  Created by 林盈志 on 6/18/14.
//  Copyright (c) 2014 林盈志. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Location Timer launch
    [self locateTimer];
    return YES;
}

-(void)checkLocation
{
    DLog(@"runCounter=%d, RemainTime=%f",self.count,[UIApplication sharedApplication].backgroundTimeRemaining);
    
    if (!(self.count%170))
    {
        DLog(@"startUpdatingLocation");
        [self.locationManager startUpdatingLocation];
    }
    if (!(self.count%180))
    {
        DLog(@"stopUpdatingLocation");
        [self.locationManager stopUpdatingLocation];
    }
        self.count++;

}

- (void)applicationWillResignActive:(UIApplication *)application
{
   
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
   
        DLog(@"application Did Enter Background");
    
        self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:
        ^{
            DLog(@"Background handler called. Not running background tasks anymore.");
            //[[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
            self.backgroundTask = UIBackgroundTaskInvalid;
            
            //if application backgraound mode will end than call location update
            //[self.locationManager startUpdatingLocation];  
        }];

        // Start the long-running task and return immediately.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
        {
            [self locateTimer];
        });
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - Location delegate

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    DLog(@"update location err-\n%@", error);
}

// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation* location = [locations lastObject];
    DLog(@"location lat=%.3f  lon=%.3f ", location.coordinate.latitude, location.coordinate.longitude);
}

#pragma mark - property init

-(CLLocationManager *)locationManager
{
    if (!_locationManager)
    {
        _locationManager=[[CLLocationManager alloc]init];
        _locationManager.delegate=self;
        _locationManager.distanceFilter=kCLDistanceFilterNone;
        
    }
    return _locationManager;
}

-(NSTimer *)locateTimer
{
    if (!_locateTimer)
    {
        _locateTimer= [NSTimer scheduledTimerWithTimeInterval:1
                                                       target:self
                                                     selector:@selector(checkLocation)
                                                     userInfo:nil
                                                      repeats:YES];
    }
    return _locateTimer;
}

-(UILocalNotification *)debugNotification
{
    if (!_debugNotification)
    {
        _debugNotification=[[UILocalNotification alloc]init];
        _debugNotification.fireDate=[NSDate dateWithTimeIntervalSinceNow:1];
        _debugNotification.alertBody=[NSString stringWithFormat:@"runCounter=%d, RemainTime=%f",self.count,[UIApplication sharedApplication].backgroundTimeRemaining];
        _debugNotification.timeZone=[NSTimeZone defaultTimeZone];
    }
    return _debugNotification;
}


@end
