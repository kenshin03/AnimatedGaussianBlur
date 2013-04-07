//
//  AGBHomeViewController.m
//  AnimatedGaussianBlur
//
//  Created by Kenny Tang on 4/7/13.
//  Copyright (c) 2013 corgitoergosum. All rights reserved.
//

#import "AGBHomeViewController.h"
#import "GPUImageGaussianBlurFilter.h"
#import "GPUImageFastBlurFilter.h"
#import "AGBTweetSheetView.h"
#include <mach/mach_time.h>

@interface AGBHomeViewController ()

@property (nonatomic, weak) IBOutlet UIImageView * backgroundImageView;

// blured images
@property (nonatomic, strong) CIContext * context;
@property (nonatomic, strong) NSMutableArray * blurredBackgroundImagesArray;
@property (nonatomic, strong) UIImageView * blurredImageView;

@property (nonatomic, strong) AGBTweetSheetView * tweetSheetView;
@property (nonatomic) BOOL isTweetSheetShowing;

@end

@implementation AGBHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initCustomTweetSheet];
    
    UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showHideCustomTweetSheet:)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [self initGaussianBlurWithGPUImageFastBlurFilter];
//        [self initGaussianBlurWithGPUImageGaussianBlurFilter];
        
        if (self.context == nil){
            self.context = [CIContext contextWithOptions:nil];
        }
        [self initGaussianBlurWithCIGaussianBlurFilter];
 
    });
    self.isTweetSheetShowing = NO;
    self.blurredBackgroundImagesArray = [@[] mutableCopy];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - show modal view

- (void) initCustomTweetSheet {
    self.tweetSheetView = [[AGBTweetSheetView alloc] initWithFrame:CGRectMake(10.0f, 1000.0f, 300.0f, 160.0f)];
    
}



- (void) showHideCustomTweetSheet:(id)sender {
    
    if (!self.isTweetSheetShowing){
        [self showBlurredImageBackground];
        
        [self.view addSubview:self.tweetSheetView];
        
        
        CGRect finalFrame = self.tweetSheetView.frame;
        finalFrame.origin.y = 250.0f;
        
        [UIView animateWithDuration:0.4f animations:^{
            self.tweetSheetView.frame = finalFrame;
        } completion:^(BOOL finished) {
            self.isTweetSheetShowing = YES;
            [self.blurredImageView stopAnimating];
        }];
        
    }else{
        [self hideBlurredImageBackground];
        
        CGRect finalFrame = self.tweetSheetView.frame;
        finalFrame.origin.y = 1000.0f;
        
        [UIView animateWithDuration:0.4f animations:^{
            self.tweetSheetView.frame = finalFrame;
        } completion:^(BOOL finished) {
            //
            [self.tweetSheetView removeFromSuperview];
            self.isTweetSheetShowing = NO;
        }];
    }
    
    
}

-(void) initGaussianBlurWithGPUImageGaussianBlurFilter {
    
    CGRect originalRect = self.backgroundImageView.bounds;
    
    // screenshot of background image view
    UIImage * homeViewImage = nil;
    if ([[UIScreen mainScreen] scale] == 2.0) {
        UIGraphicsBeginImageContextWithOptions(originalRect.size, NO, 1.0);
    } else {
        UIGraphicsBeginImageContext(originalRect.size);
    }
    CGContextRef cgContext = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(cgContext, kCGInterpolationNone);
    [[self.backgroundImageView layer] renderInContext:cgContext];
    homeViewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
     uint64_t start = mach_absolute_time();
    
    // build an array of images at different filter levels
    GPUImageGaussianBlurFilter * blurFilter = [[GPUImageGaussianBlurFilter alloc] init];
    for (NSInteger index = 1; index < 15; index++){
        blurFilter.blurSize = index*0.1;
        UIImage * filteredImage = [blurFilter imageByFilteringImage:homeViewImage];
        [self.blurredBackgroundImagesArray addObject:filteredImage];
    }
    
    uint64_t end = mach_absolute_time();
    uint64_t elapsed = end - start;
    mach_timebase_info_data_t info;
    if (mach_timebase_info (&info) != KERN_SUCCESS) {
    }
    
    uint64_t nanosecs = elapsed * info.numer / info.denom;
    uint64_t millisecs = nanosecs / 1000000;
    NSLog(@"GPUImageGaussianBlurFilter process Time: %f milisecond", [[NSNumber numberWithUnsignedLongLong:millisecs] floatValue]);
}

-(void) initGaussianBlurWithGPUImageFastBlurFilter {
    
    CGRect originalRect = self.backgroundImageView.bounds;
    
    // screenshot of background image view
    UIImage * homeViewImage = nil;
    if ([[UIScreen mainScreen] scale] == 2.0) {
        UIGraphicsBeginImageContextWithOptions(originalRect.size, NO, 1.0);
    } else {
        UIGraphicsBeginImageContext(originalRect.size);
    }
    CGContextRef cgContext = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(cgContext, kCGInterpolationNone);
    [[self.backgroundImageView layer] renderInContext:cgContext];
    homeViewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    uint64_t start = mach_absolute_time();
    
    // build an array of images at different filter levels
    GPUImageFastBlurFilter * blurFilter = [[GPUImageFastBlurFilter alloc] init];
    for (NSInteger index = 1; index < 15; index++){
        blurFilter.blurSize = index*0.2;
        UIImage * filteredImage = [blurFilter imageByFilteringImage:homeViewImage];
        [self.blurredBackgroundImagesArray addObject:filteredImage];
    }
    
    uint64_t end = mach_absolute_time();
    uint64_t elapsed = end - start;
    mach_timebase_info_data_t info;
    if (mach_timebase_info (&info) != KERN_SUCCESS) {
    }
    
    uint64_t nanosecs = elapsed * info.numer / info.denom;
    uint64_t millisecs = nanosecs / 1000000;
    NSLog(@"GPUImageFastBlurFilter process Time: %f milisecond", [[NSNumber numberWithUnsignedLongLong:millisecs] floatValue]);
}



-(void) initGaussianBlurWithCIGaussianBlurFilter {
    
    CGRect originalRect = self.backgroundImageView.bounds;
    
    // screenshot of background image view
    UIImage * homeViewImage = nil;
    if ([[UIScreen mainScreen] scale] == 2.0) {
        UIGraphicsBeginImageContextWithOptions(originalRect.size, NO, 1.0);
    } else {
        UIGraphicsBeginImageContext(originalRect.size);
    }
    CGContextRef cgContext = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(cgContext, kCGInterpolationNone);
    [[self.backgroundImageView layer] renderInContext:cgContext];
    homeViewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    uint64_t start = mach_absolute_time();
    
    CIImage * inputImage = [CIImage imageWithCGImage:homeViewImage.CGImage];
    
    // build an array of images at different filter levels
    for (NSInteger index = 1; index < 15; index++){
        
        CIFilter * blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"
                                           keysAndValues:kCIInputImageKey, inputImage,
                                 @"inputRadius", @(index*0.22), nil];
        CIImage * outputImage = blurFilter.outputImage;
        CGImageRef outImage = [self.context createCGImage:outputImage fromRect:[outputImage extent]];
        [self.blurredBackgroundImagesArray addObject:[UIImage imageWithCGImage:outImage]];
    }
    
    uint64_t end = mach_absolute_time();
    uint64_t elapsed = end - start;
    mach_timebase_info_data_t info;
    if (mach_timebase_info (&info) != KERN_SUCCESS) {
    }
    
    uint64_t nanosecs = elapsed * info.numer / info.denom;
    uint64_t millisecs = nanosecs / 1000000;
    NSLog(@"initGaussianBlurWithCIGaussianBlurFilter process Time: %f milisecond", [[NSNumber numberWithUnsignedLongLong:millisecs] floatValue]);
}


- (void) showBlurredImageBackground {
    
    // create a UIImageView from the array of blurred images, add to view
    
    UIImageView * blurView = [[UIImageView alloc] initWithFrame:self.backgroundImageView.frame];
    blurView.animationImages = self.blurredBackgroundImagesArray;
    blurView.animationDuration=.5;
    blurView.animationRepeatCount=1;
    blurView.image = [self.blurredBackgroundImagesArray lastObject];
    [blurView startAnimating];
    
    self.blurredImageView = blurView;
    [self.view insertSubview:self.blurredImageView aboveSubview:self.backgroundImageView];
}

- (void) hideBlurredImageBackground {
    
    // create a UIImageView from the reversed array of blurred images, add to view
    
    NSArray * reversedImagesArray = [[self.blurredBackgroundImagesArray reverseObjectEnumerator] allObjects];
    
    UIImageView * blurView = [[UIImageView alloc] initWithFrame:self.backgroundImageView.frame];
    blurView.animationImages = reversedImagesArray;
    blurView.animationDuration=.5;
    blurView.animationRepeatCount=1;
    blurView.image = [reversedImagesArray lastObject];
    [blurView startAnimating];
    
    [self.blurredImageView removeFromSuperview];
    
    self.blurredImageView = blurView;
    [self.view insertSubview:self.blurredImageView aboveSubview:self.backgroundImageView];
    
    double delayInSeconds = .6;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.blurredImageView removeFromSuperview];
    });
    
}


@end
