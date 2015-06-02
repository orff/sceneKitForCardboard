//
//  GameViewController.m
//  VRSceneKit
//
//  Created by Hill, Michael on 6/2/15.
//  Copyright (c) 2015 Hill, Michael. All rights reserved.
//

#import "GameViewController.h"

@implementation GameViewController {
    SCNScene *_scene;
}

-(void)updateCameraWithMotion:(CMDeviceMotion *)data {    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    int orientationMultiplier = 1;
    if(orientation == UIInterfaceOrientationLandscapeRight) orientationMultiplier = -1;
        
    SCNNode *camerasNode = [_scene.rootNode childNodeWithName:@"camerasNode" recursively:NO];
    camerasNode.eulerAngles = SCNVector3Make((data.attitude.roll * orientationMultiplier) - M_PI_2, data.attitude.yaw, data.attitude.pitch);
}

- (CMMotionManager*) motionManager {
    if (!_motionManager) {
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.deviceMotionUpdateInterval = 1/60;
    }
    return _motionManager;
}

- (void)startMotionDetect {
    [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical toQueue:[[NSOperationQueue alloc] init] withHandler:^(CMDeviceMotion *motion, NSError *error) {
        [self updateCameraWithMotion:motion];
    }];
}

-(void)stopMotionDetection {
    [self.motionManager stopDeviceMotionUpdates];
}

-(void)viewDidAppear:(BOOL)animated {
    [self startMotionDetect];
}

-(void)viewWillDisappear:(BOOL)animated {
    [self stopMotionDetection];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // create a new scene
    _scene = [SCNScene sceneNamed:@"art.scnassets/ship.dae"];

    // create and add a camera to the left scene
    SCNNode *leftCameraNode = [SCNNode node];
    leftCameraNode.camera = [SCNCamera camera];
    leftCameraNode.camera.xFov = 45;
    leftCameraNode.camera.yFov = 45;
    
    // create and add a camera to the right scene
    SCNNode *rightCameraNode = [SCNNode node];
    rightCameraNode.camera = [SCNCamera camera];
    rightCameraNode.camera.xFov = 45;
    rightCameraNode.camera.yFov = 45;
    
    // place the cameras
    leftCameraNode.position = SCNVector3Make(-0.5, 0, 15);
    rightCameraNode.position = SCNVector3Make(0.5, 0, 15);
    
    SCNNode *camerasNode = [SCNNode node];
    [camerasNode addChildNode:leftCameraNode];
    [camerasNode addChildNode:rightCameraNode];

    //add the main cameras node
    camerasNode.name = @"camerasNode";
    [_scene.rootNode addChildNode:camerasNode];
    
    // create and add a light to the scene
    SCNNode *lightNode = [SCNNode node];
    lightNode.light = [SCNLight light];
    lightNode.light.type = SCNLightTypeOmni;
    lightNode.position = SCNVector3Make(0, 10, 10);
    [_scene.rootNode addChildNode:lightNode];
    
    // create and add an ambient light to the scene
    SCNNode *ambientLightNode = [SCNNode node];
    ambientLightNode.light = [SCNLight light];
    ambientLightNode.light.type = SCNLightTypeAmbient;
    ambientLightNode.light.color = [UIColor darkGrayColor];
    [_scene.rootNode addChildNode:ambientLightNode];
    
    // retrieve the ship node
    SCNNode *ship = [_scene.rootNode childNodeWithName:@"ship" recursively:YES];
    
    // animate the 3d object
    [ship runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:2 z:0 duration:1]]];
    
    // set the scene to the view
    self.leftView.scene = _scene;
    self.rightView.scene = _scene;
    
    //IMPORTANT for VR
    self.leftView.pointOfView = leftCameraNode;
    self.rightView.pointOfView = rightCameraNode;
    
    //force to keep running
    self.leftView.playing = YES;
    self.rightView.playing = YES;
    
    // allows the user to manipulate the camera
    //self.leftView.allowsCameraControl = YES;
        
    // show statistics such as fps and timing information
    //self.leftView.showsStatistics = YES;

    // configure the view
    self.leftView.backgroundColor = [UIColor blackColor];
    self.rightView.backgroundColor = [UIColor blackColor];
    
    // add a tap gesture recognizer
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    NSMutableArray *gestureRecognizers = [NSMutableArray array];
    [gestureRecognizers addObject:tapGesture];
    [gestureRecognizers addObjectsFromArray:self.view.gestureRecognizers];
    self.view.gestureRecognizers = gestureRecognizers;
}

- (void) handleTap:(UIGestureRecognizer*)gestureRecognize
{
    // retrieve the SCNView
    SCNView *scnView = self.leftView;
    
    // check what nodes are tapped
    CGPoint p = [gestureRecognize locationInView:scnView];
    NSArray *hitResults = [scnView hitTest:p options:nil];
    
    // check that we clicked on at least one object
    if([hitResults count] > 0){
        // retrieved the first clicked object
        SCNHitTestResult *result = [hitResults objectAtIndex:0];
        
        // get its material
        SCNMaterial *material = result.node.geometry.firstMaterial;
        
        // highlight it
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:0.5];
        
        // on completion - unhighlight
        [SCNTransaction setCompletionBlock:^{
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.5];
            
            material.emission.contents = [UIColor blackColor];
            
            [SCNTransaction commit];
        }];
        
        material.emission.contents = [UIColor redColor];
        
        [SCNTransaction commit];
    }
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
