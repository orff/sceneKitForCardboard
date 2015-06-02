//
//  GameViewController.h
//  VRSceneKit
//

//  Copyright (c) 2015 Hill, Michael. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>
#import <CoreMotion/CoreMotion.h>

@interface GameViewController : UIViewController

@property (nonatomic, assign) IBOutlet SCNView *leftView;
@property (nonatomic, assign) IBOutlet SCNView *rightView;

@property (nonatomic, strong) CMMotionManager* motionManager;

@end
