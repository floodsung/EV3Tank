//
//  ViewController.m
//  EV3Tank
//
//  Created by FloodSurge on 6/2/14.
//  Copyright (c) 2014 FloodSurge. All rights reserved.
//

#import "ViewController.h"
#import "EV3WifiManager.h"
#import "EV3WifiBrowserViewController.h"
#import <CoreMotion/CoreMotion.h>

@interface ViewController ()

@property (nonatomic,strong) EV3WifiManager *ev3WifiManager;
@property (nonatomic,strong) CMMotionManager *motionManager;
@property (nonatomic,strong) NSTimer *timer;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.ev3WifiManager = [EV3WifiManager sharedInstance];
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.deviceMotionUpdateInterval = 0.01f;

    if (self.motionManager.isDeviceMotionAvailable) {
        if (!self.motionManager.isDeviceMotionActive) {
            [self.motionManager startDeviceMotionUpdates];
            
            NSLog(@"Start device motion");
            
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateMotion) userInfo:nil repeats:YES];
            
        }
    } else NSLog(@"Device motion unavailable");
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.motionManager.isDeviceMotionAvailable) {
        if (!self.motionManager.isDeviceMotionActive) {
            [self.motionManager startDeviceMotionUpdates];
            
            NSLog(@"Start device motion");
            
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateMotion) userInfo:nil repeats:YES];
            
        }
    } else NSLog(@"Device motion unavailable");
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (self.motionManager.isDeviceMotionAvailable) {
        if (self.motionManager.isDeviceMotionActive) {
            [self.motionManager stopDeviceMotionUpdates];
            NSLog(@"Stop device motion");
            [self.timer invalidate];
        }
    } else NSLog(@"Device motion unavailable");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)connect:(id)sender
{
    EV3WifiBrowserViewController *browserViewController = [[EV3WifiBrowserViewController alloc] init];
    
    [self presentViewController:browserViewController animated:YES completion:nil];
}

- (IBAction)leftMotorOn:(id)sender
{
    EV3Device *device = self.ev3WifiManager.devices.allValues.lastObject;
    [device turnMotorAtPort:EV3OutputPortC power:60];
    NSLog(@"Left Motor On!");

    
}



- (IBAction)leftMotorOff:(id)sender
{
    EV3Device *device = self.ev3WifiManager.devices.allValues.lastObject;
    [device stopMotorAtPort:EV3OutputPortC];
    NSLog(@"Left Motor Off!");

}

- (IBAction)rightMotorOn:(id)sender
{
    EV3Device *device = self.ev3WifiManager.devices.allValues.lastObject;
    [device turnMotorAtPort:EV3OutputPortB power:60];
    NSLog(@"Right Motor On!");
}

- (IBAction)rightMotorOff:(id)sender
{
    EV3Device *device = self.ev3WifiManager.devices.allValues.lastObject;
    [device stopMotorAtPort:EV3OutputPortB];
    NSLog(@"Right Motor Off!");

}

- (void)updateMotion
{
    float pitch = self.motionManager.deviceMotion.attitude.pitch / M_PI * 180.0f;
    float yaw = self.motionManager.deviceMotion.attitude.yaw / M_PI * 180.0f;
    float roll = self.motionManager.deviceMotion.attitude.roll / M_PI * 180.0f;
    
    //NSLog(@"pitch倾斜:%f,yaw偏航:%f,roll滚转:%f",pitch,yaw,roll);
    
    
    int meanPower = (int)(- roll * 3);
    
    int offsetPower = (int)(yaw);
    
    int leftPower = meanPower - offsetPower;
    int rightPower = meanPower + offsetPower;
    
    NSLog(@"leftpower:%d,rightpower:%d",leftPower, rightPower);
    
    EV3Device *device = self.ev3WifiManager.devices.allValues.lastObject;
    if (device != nil) {
        [device turnMotorAtPort:EV3OutputPortC power:leftPower];
        [device turnMotorAtPort:EV3OutputPortB power:rightPower];
    }
    
    
    
}

- (IBAction)start:(id)sender
{
    [self viewDidAppear:FALSE];
    
}

- (IBAction)stop:(id)sender {
    [self viewDidDisappear:NO];
    [self leftMotorOff:nil];
    [self rightMotorOff:nil];
}

- (IBAction)calibrate:(id)sender
{
    [self.motionManager stopDeviceMotionUpdates];
    [self.motionManager startDeviceMotionUpdates];
}

@end
