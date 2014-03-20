//
//  JSAppDelegate.m
//  LocalNotifications
//
//  Created by Johnny on 3/18/14.
//  Copyright (c) 2014 Johnny Slagle. All rights reserved.
//

#import "JSAppDelegate.h"

// Class Extension
@interface JSAppDelegate ()

@property (nonatomic, assign) UIBackgroundTaskIdentifier bgTask;

@end


@implementation JSAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Note: It isn't best practice to put all this subview logic in the AppDelegate but it works for this example.
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Create then apply a gradient to the background so it isn't a boring white
    UIColor * startColor = [UIColor colorWithRed:0.9843 green:0.0196 blue:0.4824 alpha:1.0];
    UIColor * endColor = [UIColor colorWithRed:1 green:0.0745 blue:0 alpha:1.0];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.window.bounds;
    gradientLayer.colors = @[(id)(startColor.CGColor), (id)(endColor.CGColor)];
    [self.window.layer insertSublayer:gradientLayer atIndex:0];
    
    // Add Label
    UILabel *textLabel = [[UILabel alloc] initWithFrame:self.window.bounds];
    
    textLabel.text = @"Close to schedule the notification";
    
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.textColor = [UIColor whiteColor];
    textLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:38.0f];
    textLabel.numberOfLines = 0;
    textLabel.userInteractionEnabled = NO;
    
    [self.window addSubview:textLabel];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(suspendMe)];
    [self.window addGestureRecognizer:gestureRecognizer];
    
    // Show Window
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)suspendMe {
    // Note: This is a private API, I think? I would guess the app wouldn't get approved if you use this.
    UIApplication *app = [UIApplication sharedApplication];
    [app performSelector:@selector(suspend)];
}

// Schedule a Notification to fire the instant the app goes into the background (pushing the home button).
- (void)applicationDidEnterBackground:(UIApplication *)application {

    // Create the background task with expiration code to end the task
    self.bgTask = [application beginBackgroundTaskWithExpirationHandler: ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [application endBackgroundTask:self.bgTask];
            self.bgTask = UIBackgroundTaskInvalid;
        });
    }];
    
    // Execute the following notification code on the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // Create the Local Notification
        UILocalNotification *localNotif = [UILocalNotification new];
        
        // Set the notification body, action, badge number, and custom sound.
        localNotif.alertBody = [NSString stringWithFormat:@"Johnny has a message for you."];
        localNotif.alertAction = @"Read Message";
        localNotif.applicationIconBadgeNumber = 1337;
        localNotif.soundName = @"refresh.caf";

        // Present the notification
        [application presentLocalNotificationNow:localNotif];
        
        // End and invalidate the background task
        [application endBackgroundTask:self.bgTask];
        self.bgTask = UIBackgroundTaskInvalid;
    });
}


@end
