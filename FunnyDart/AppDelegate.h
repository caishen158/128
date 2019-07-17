//
//  AppDelegate.h
//  FunnyDart
//
//  Created by Ssyong on 9/30/13.
//  Copyright (c) 2013 Entertaiment. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;
@property (strong, nonatomic) UINavigationController* navigationController;

@end
