//
//  ViewController.m
//  FunnyDart
//
//  Created by Ssyong on 9/30/13.
//  Copyright (c) 2013 Entertaiment. All rights reserved.
//

#import "ViewController.h"
#import "PrivacyViewController.h"


@interface ViewController ()
{
    IBOutlet NSLayoutConstraint* _headHeightLayout;
    IBOutlet NSLayoutConstraint* _runButtonHeightLayout;
    IBOutlet NSLayoutConstraint* _shotButtonHeightLayout;
}

@end

@implementation ViewController
@synthesize imgViewDartBoard, imgViewHandShot;
@synthesize viewShowPoint, lblPoint;
@synthesize btnRunDart, btnShotDart;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _headHeightLayout.constant = [[UIApplication sharedApplication] statusBarFrame].size.height + 44.0f;
    
    if ([[UIApplication sharedApplication] statusBarFrame].size.height > 20)
    {
        _runButtonHeightLayout.constant = 24.0f;
        _shotButtonHeightLayout.constant = 24.0f;
    }
    
	// Do any additional setup after loading the view, typically from a nib.
    iNumImageEffect = 0;
    isRunning = FALSE;
    [btnRunDart setEnabled:YES];
    [btnShotDart setEnabled:NO];
    
    CGRect sizeRect = [UIScreen mainScreen].applicationFrame;
    float width = sizeRect.size.width;
    
    
    //tạo PlacementID
    FBAdView *adViewFB = [[FBAdView alloc] initWithPlacementID:@"318527088584787_318527351918094"
                                                        adSize:kFBAdSizeHeight50Banner
                                            rootViewController:self];
    
    //vị trí của banner ở trên (TOP)
    adViewFB.frame = CGRectMake(0, 40, width, 50);
    
    //vị trí banner ở dưới (BOTTOM)
//    adViewFB.frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - adViewFB.frame.size.height, width, 50);
    
    //Show banner
    //[adViewFB loadAd];
    //[self.view addSubview:adViewFB];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Click for Run DardBoard
- (IBAction)RunDartboard:(id)sender
{
    //Load Dartboard Run from effect
    if (!isRunning) {
        [self LoadDartBoard];
        isRunning = TRUE;
        [btnRunDart setEnabled:NO];
        [btnShotDart setEnabled:YES];
    }
}

//Shot on DartBoard
- (IBAction)ShotDartboard:(id)sender
{
    imgViewHandShot.hidden = TRUE;
    isRunning = FALSE;
    [btnShotDart setEnabled:NO];
    
    //Get Point and Dart
    int iPoint = [self shufflePoint];
    int iDart = [self shuffleDart];
    
    //Get point if shot on center
    iPoint = iPoint/5;
    if (iPoint == 21) {
        iPoint = 100;
    }
    
    //
//    NSLog(@"iPoint : %d", iPoint);
//    NSLog(@"iDart : %d", iDart);
    imgViewDartBoard.image = [UIImage imageNamed:[NSString stringWithFormat:@"p%d_%d", iPoint, iDart]];
    lblPoint.text = [NSString stringWithFormat:@"%d",iPoint];
    [self performSelector:@selector(showViewPoint) withObject:nil afterDelay:0.5];
}

//Load DartBoard from loadeffect
- (void) LoadDartBoard
{
    if (iNumImageEffect % 20 < 20) {
        
        [self performSelector:@selector(loadEffect) withObject:nil afterDelay:0.05];
    }
    else{
        //Set NumEffect for load image effect
        iNumImageEffect = 1;
        [self loadEffect];
    }
}

//Load Effect of dardboard Run
- (void)loadEffect
{
    if (isRunning) {
        imgViewDartBoard.image = [UIImage imageNamed:[NSString stringWithFormat:@"board%d.png", iNumImageEffect % 20 + 1] ];
        iNumImageEffect = iNumImageEffect + 1;
        [self LoadDartBoard];
    }
}

//Choose Point Random
-(int)shufflePoint
{
    NSInteger n = (arc4random() % 110);
    return n;
}

//Choose dart Random
-(int)shuffleDart
{
    NSInteger n = (arc4random() % 6);
    if (n != 0) {
        return n;
    }
    return 1;
}

//Show view get Point
- (void)showViewPoint
{
    
    viewShowPoint.hidden = NO;
    [self showBanner];
}

//Back To main view and see again result
- (IBAction)backToMainview:(id)sender
{
    viewShowPoint.hidden = YES;
    [self hidesBanner];
    isRunning = TRUE;
    [self performSelector:@selector(loadViewAgain) withObject:nil afterDelay:2.0];
}

//Load from beginning game
-(void)loadViewAgain
{
    imgViewDartBoard.image = [UIImage imageNamed:@"dartboard.png"];
    imgViewHandShot.hidden= FALSE;
    isRunning = FALSE;
    [btnRunDart setEnabled:YES];
}
#pragma mark iAd Delegate Methods

// Method is called when the iAd is loaded.
//-(void)bannerViewDidLoadAd:(ADBannerView *)banner {
//    
//    _bannerView.alpha = 1;
//    // Creates animation.
//    [UIView beginAnimations:nil context:nil];
//    
//    // Sets the duration of the animation to 1.
//    [UIView setAnimationDuration:1];
//    
//    // Sets the alpha to 1.
//    // We do this because we are going to have it set to 0 to start and setting it to 1 will cause the iAd to fade into view.
//    [banner setAlpha:1];
//    
//    //  Performs animation.
//    [UIView commitAnimations];
//    
//}

// Method is called when the iAd fails to load.
//-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
//    
//    // Creates animation.
//    [UIView beginAnimations:nil context:nil];
//    
//    // Sets the duration of the animation to 1.
//    [UIView setAnimationDuration:1];
//    
//    // Sets the alpha to 0.
//    // We do this because we are going to have it set to 1 to start and setting it to 0 will cause the iAd to fade out of view.
//    [banner setAlpha:0];
//    
//    //  Performs animation.
//    [UIView commitAnimations];
//    
//}

//Hide Native
-(void)hidesBanner {
    NSLog(@"Hide banner");
    if (_nativeAdView != nil) {
        [_nativeAdView removeFromSuperview];
        _nativeAdView = nil;
    }
}

//Show Native
-(void)showBanner {
    NSLog(@"Show banner");
    //Native
    [self getNativeAdTemplate];
}

//Native
- (void)getNativeAdTemplate
{
    if (nativeAd != nil) {
        [nativeAd unregisterView];
    }
    
    nativeAd = [[FBNativeAd alloc] initWithPlacementID:@"318527088584787_318532745250888"];
    nativeAd.delegate = self;
    [nativeAd loadAd];
}

- (void)nativeAdDidLoad:(FBNativeAd *)nativeAd
{
    FBNativeAdViewAttributes *attributes = nil;
    attributes.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
    attributes.buttonColor = [UIColor colorWithRed:0.4 green:0.9 blue:0.8 alpha:1.0];
    attributes.buttonTitleColor = UIColor.whiteColor;
    _nativeAdView = [FBNativeAdView nativeAdViewWithNativeAd:nativeAd
                                                    withType:FBNativeAdViewTypeGenericHeight400 withAttributes:attributes];
    _nativeAdView.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:_nativeAdView];
    
    CGSize size = self.view.bounds.size;
    CGFloat xOffset = 0;
    CGFloat yOffset = size.height - (size.height/3);
    _nativeAdView.frame = CGRectMake(xOffset, yOffset, size.width, (size.height/3));
    
    // Register the native ad view and its view controller with the native ad instance
    [nativeAd registerViewForInteraction:_nativeAdView withViewController:self];
}

- (IBAction)privacyButtonClicked:(id)sender
{
    PrivacyViewController* vc = [[[PrivacyViewController alloc] init] autorelease];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
