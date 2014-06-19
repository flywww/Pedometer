//
//  ViewController.m
//  Pedometer
//
//  Created by 林盈志 on 6/18/14.
//  Copyright (c) 2014 林盈志. All rights reserved.
//

#import "ViewController.h"
#import <CoreMotion/CoreMotion.h>


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


@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];


//    if (!([CMStepCounter isStepCountingAvailable] || [CMMotionActivityManager isActivityAvailable]))
//    {
    //Non M7 Device
    self.motionManager.accelerometerUpdateInterval = 1/60;
    [self.motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc]init] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error)
     {
         float xx = accelerometerData.acceleration.x;
         float yy = accelerometerData.acceleration.y;
         float zz = accelerometerData.acceleration.z;
         
         float dot = (px * xx) + (py * yy) + (pz * zz);
         float a = ABS(sqrt(px * px + py * py + pz * pz));
         float b = ABS(sqrt(xx * xx + yy * yy + zz * zz));
         
         dot /= (a * b);
         
         NSLog(@"%f",dot);
         
         //Make a weak slef, or the self will be referent repeatedly
         __weak ViewController *weakSelf=self;
         
         if (dot <= 0.82)
         {
             if (!isSleeping)
             {
                 isSleeping = YES;
                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW,0.2 * NSEC_PER_SEC), dispatch_get_main_queue(),^
                                {
                                    isSleeping = NO;
                                    numSteps += 1;
                                    weakSelf.stepLebel.text=[NSString stringWithFormat:@"%d", numSteps];
                                });
             }
             
         }
         px = xx; py = yy; pz = zz;
     }];

//    }
//    else
//    {
        __weak ViewController *weakSelf = self;
        
        //更新label
        if ([CMStepCounter isStepCountingAvailable])
        {
            
            self.operationQueue = [[NSOperationQueue alloc] init];
            self.stepCounter = [[CMStepCounter alloc] init];
            [self.stepCounter startStepCountingUpdatesToQueue:self.operationQueue
                                                     updateOn:1
                                                  withHandler:
             ^(NSInteger numberOfSteps, NSDate *timestamp, NSError *error)
             {
                 
                 dispatch_async(dispatch_get_main_queue(), ^
                                {
                                    
                                    if (error)
                                    {
                                        UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Opps!" message:@"error" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                        [error show];
                                    }
                                    else
                                    {
                                        
                                        NSString *text = [NSString stringWithFormat:@"步數: %ld", (long)numberOfSteps];
                                        
                                        weakSelf.stepLebelM7.text = text;
                                    }
                                });
             }];
            
            
            self.activityManager = [[CMMotionActivityManager alloc] init];
            
            [self.activityManager startActivityUpdatesToQueue:self.operationQueue
                                                  withHandler:
             ^(CMMotionActivity *activity)
             {
                 
                 dispatch_async(dispatch_get_main_queue(),
                                ^{
                                    
                                    NSString *status = [weakSelf statusForActivity:activity];
                                    NSString *confidence = [weakSelf stringFromConfidence:activity.confidence];
                                    
                                    weakSelf.statusLabel.text = [NSString stringWithFormat:@"狀態: %@", status];
                                    weakSelf.confidenceLabel.text = [NSString stringWithFormat:@"速度: %@", confidence];
                                });
             }];
            
        }
//    }
    

  
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
    }
    return _motionManager;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
