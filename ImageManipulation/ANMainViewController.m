//
//  ANFirstViewController.m
//  ImageManipulation
//
//  Created by Andrzej Naglik on 08.08.2013.
//  Copyright (c) 2013 Andrzej Naglik. All rights reserved.
//

#import "ANMainViewController.h"
#import <GLKit/GLKit.h>
#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>

@interface ANMainViewController(){
  EAGLContext *_eaglContext;
  CIContext *_cictx;
  GLKView *_viewForImage;
}
@end

@implementation ANMainViewController

- (void)loadView{
  UIView *mainView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  [self setView:mainView];
  [[self view] setBackgroundColor:[UIColor colorWithRed:0.169 green:0.553 blue:0.824 alpha:1.000]];
}

- (void)viewDidAppear:(BOOL)animated{
  [super viewDidAppear:animated];
  UIImage *entryImage = [UIImage imageNamed:@"entryImage.png"];
   //configuration (should be done in loadView
  _eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
  _viewForImage = [[GLKView alloc] initWithFrame:CGRectMake(0.0, 0.0, entryImage.size.width, entryImage.size.height)
                                         context:_eaglContext];
  _cictx = [CIContext contextWithEAGLContext:_eaglContext options:@{kCIContextWorkingColorSpace: [NSNull null]}];
  [[self view] addSubview:_viewForImage];
  [_viewForImage bindDrawable];

  //applying filer
  CIImage *image = [CIImage imageWithCGImage:[entryImage CGImage]];
  CIFilter *filter = [CIFilter filterWithName:@"CIMaskToAlpha"];
  [filter setValue:image forKey:kCIInputImageKey];
  CIImage *resultImage = [filter valueForKey:kCIOutputImageKey];
  
  //set GLKView's background color same as main view's background color.
  //lazy solution: [[_viewForImage layer] setOpaque:NO];
  const CGFloat *colorValues = CGColorGetComponents([[[self view] backgroundColor] CGColor]);
  glClearColor(colorValues[0], colorValues[1], colorValues[2], colorValues[3]);
  glClear(GL_COLOR_BUFFER_BIT);
  
  // setup GL blend mode if needed
  glEnable(GL_BLEND);
  glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
  
  //drawing output image to CIContext based on EAGLContext
  CGRect rectInPixels = CGRectMake(0.0, 0.0,_viewForImage.drawableWidth,_viewForImage.drawableHeight);
  [_cictx drawImage:resultImage inRect:rectInPixels fromRect:[image extent]];
  [_viewForImage display];
}


/* Easy way but not so efficient
 //  CIContext *context = [CIContext contextWithOptions:nil];
 //  UIImage *entryImage = [UIImage imageNamed:@"someImage.png"];
 //  CIImage *image = [CIImage imageWithCGImage:[entryImage CGImage]];
 //  CIFilter *filter = [CIFilter filterWithName:@"CIMaskToAlpha"];
 //  [filter setValue:image forKey:kCIInputImageKey];
 //  CIImage *result = [filter valueForKey:kCIOutputImageKey];
 //  CGImageRef cgImage = [context createCGImage:result fromRect:[result extent]];
 //
 //  UIImageView *imageView = [[UIImageView alloc] initWithImage: [UIImage imageWithCGImage:cgImage scale:[entryImage scale]
 //                                                                             orientation:UIImageOrientationUp]];
 //  [[self view] addSubview:imageView];
 */

@end
