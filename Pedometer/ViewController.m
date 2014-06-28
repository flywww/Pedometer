//
//  ViewController.m
//  Pedometer
//
//  Created by 林盈志 on 6/18/14.
//  Copyright (c) 2014 林盈志. All rights reserved.
//

#import "ViewController.h"
#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>



@interface ViewController ()
{
    float px;
    float py;
    float pz;
    BOOL isSleeping;
    int numSteps;
}
@property (weak, nonatomic) IBOutlet UILabel *stepLebel;
@property (weak, nonatomic) IBOutlet UILabel *stepLebelM7;

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *confidenceLabel;
@property (nonatomic, strong) NSOperationQueue *operationQueue;



@property (nonatomic) CMMotionManager* motionManager;

@property (nonatomic, strong) CMStepCounter *stepCounter;

@property (nonatomic, strong) CMMotionActivityManager *activityManager;



@property (nonatomic) CLLocationManager* locationManager;
@property (nonatomic) NSMutableArray* lacation;


@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self StepCountingUpdate];
}

-(NSInteger)StepCountingUpdate
{
    __block NSInteger steps;
    __weak ViewController *weakSelf = self;
    
    //M7 Device
    if (([CMStepCounter isStepCountingAvailable] || [CMMotionActivityManager isActivityAvailable]))
    {
        self.operationQueue = [[NSOperationQueue alloc] init];
        [self.stepCounter startStepCountingUpdatesToQueue:self.operationQueue
                                                 updateOn:1
                                              withHandler:^(NSInteger numberOfSteps, NSDate *timestamp, NSError *error)
         {
              steps=numberOfSteps;
             dispatch_async(dispatch_get_main_queue(), ^
            {
                weakSelf.stepLebelM7.text = [NSString stringWithFormat:@"M7步數: %ld", (long)numberOfSteps];
            });
         }];
    }
    //non M7 Device
    if([CMMotionActivityManager isActivityAvailable])
    {
        [self.motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc]init] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error)
         {
             float xx = accelerometerData.acceleration.x;
             float yy = accelerometerData.acceleration.y;
             float zz = accelerometerData.acceleration.z;
             
             float dot = (px * xx) + (py * yy) + (pz * zz);
             float a = ABS(sqrt(px * px + py * py + pz * pz));
             float b = ABS(sqrt(xx * xx + yy * yy + zz * zz));
             
             dot /= (a * b);
             
             if (dot <= 0.82)
             {
                 if (!isSleeping)
                 {
                     isSleeping = YES;
                     dispatch_after(dispatch_time(DISPATCH_TIME_NOW,0.2 * NSEC_PER_SEC), dispatch_get_main_queue(),^
                    {
                        isSleeping = NO;
                        numSteps += 1;
                        steps=numSteps;
                        weakSelf.stepLebel.text=[NSString stringWithFormat:@"演算法步數: %ld", (long)steps];
                    });
                 }
                 
             }
             px = xx; py = yy; pz = zz;
         }];
    }
    
    return steps;
}


-(CMStepCounter *)stepCounter
{
    if (!_stepCounter)
    {
        _stepCounter=[[CMStepCounter alloc] init];
    }
    return _stepCounter;
}


- (NSString *)statusForActivity:(CMMotionActivity *)activity
{
    
    NSMutableString *status = @"".mutableCopy;
    
    if (activity.stationary) {
        
        [status appendString:@"not moving"];
    }
    
    if (activity.walking) {
        
        if (status.length) [status appendString:@", "];
        
        [status appendString:@"on a walking person"];
    }
    
    if (activity.running) {
        
        if (status.length) [status appendString:@", "];
        
        [status appendString:@"on a running person"];
    }
    
    if (activity.automotive) {
        
        if (status.length) [status appendString:@", "];
        
        [status appendString:@"in a vehicle"];
    }
    
    if (activity.unknown || !status.length) {
        
        [status appendString:@"unknown"];
    }
    
    return status;
}
- (NSString *)stringFromConfidence:(CMMotionActivityConfidence)confidence {
    
    switch (confidence)
    {
            
        case CMMotionActivityConfidenceLow:
            
            return @"Low";
            
        case CMMotionActivityConfidenceMedium:
            
            return @"Medium";
            
        case CMMotionActivityConfidenceHigh:
            
            return @"High";
            
        default:
            
            return nil;
    }
}



-(CMMotionManager *)motionManager
{
    if (!_motionManager)
    {
        _motionManager=[[CMMotionManager alloc]init];
        _motionManager.accelerometerUpdateInterval = 1/60;
    }
    return _motionManager;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
