//
//  CJCViewController.m
//  CJC.FaceMaskingDemo
//
//  Created by Chris Cavanagh on 11/9/13.
//  Copyright (c) 2013 Chris Cavanagh. All rights reserved.
//

#import "CJCViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "CJCAnonymousFacesFilter.h"

@interface CJCViewController ()
{
	dispatch_queue_t _serialQueue;
}

@property (strong, nonatomic) EAGLContext *eaglContext;
@property (strong, nonatomic) CIContext *ciContext;
@property (strong, nonatomic) CJCAnonymousFacesFilter *filter;
@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) NSArray *facesMetadata;
@property (strong, nonatomic) IBOutlet UIImageView *faceView;
@property (strong, nonatomic) NSArray *faceImages;
@end

@implementation CJCViewController

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

	if ( !_eaglContext )
	{
		NSLog(@"Failed to create ES context");
	}

	self.ciContext = [CIContext contextWithEAGLContext:_eaglContext];

	GLKView *view = (GLKView *)self.view;
	view.context = _eaglContext;
	view.drawableDepthFormat = GLKViewDrawableDepthFormat24;

	_serialQueue = dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 );

	self.filter = [CJCAnonymousFacesFilter new];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	[self setupAVCapture];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[self tearDownAVCapture];

	[super viewWillDisappear:animated];
}

- (void)dealloc
{    
	[self tearDownAVCapture];
	
	if ([EAGLContext currentContext] == _eaglContext)
	{
		[EAGLContext setCurrentContext:nil];
	}
}

- (void)setupAVCapture
{
	AVCaptureSession *captureSession = [AVCaptureSession new];

	[captureSession beginConfiguration];

	NSError *error;

	// Input device

	AVCaptureDevice *captureDevice = [self frontOrDefaultCamera];
	AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];

	if ( [captureSession canAddInput:deviceInput] )
	{
		[captureSession addInput:deviceInput];
	}

	if ( [captureSession canSetSessionPreset:AVCaptureSessionPresetHigh] )
	{
		captureSession.sessionPreset = AVCaptureSessionPresetHigh;
	}

	// Video data output

	AVCaptureVideoDataOutput *videoDataOutput = [self createVideoDataOutput];

	if ( [captureSession canAddOutput:videoDataOutput] )
	{
		[captureSession addOutput:videoDataOutput];

		AVCaptureConnection *connection = videoDataOutput.connections[ 0 ];

		connection.videoOrientation = AVCaptureVideoOrientationPortrait;
	}

	// Metadata output

	AVCaptureMetadataOutput *metadataOutput = [self createMetadataOutput];

	if ( [captureSession canAddOutput:metadataOutput] )
	{
		[captureSession addOutput:metadataOutput];

		metadataOutput.metadataObjectTypes = [self metadataOutput:metadataOutput allowedObjectTypes:self.faceMetadataObjectTypes];
	}

	// Done

	[captureSession commitConfiguration];

	dispatch_async( _serialQueue,
				   ^{
					   [captureSession startRunning];
				   });

	_captureSession = captureSession;

//	[self updateVideoOrientation:self.interfaceOrientation];
}

- (void)tearDownAVCapture
{
	[_captureSession stopRunning];

	_captureSession = nil;
}

- (AVCaptureMetadataOutput *)createMetadataOutput
{
	AVCaptureMetadataOutput *metadataOutput = [AVCaptureMetadataOutput new];

	[metadataOutput setMetadataObjectsDelegate:self queue:_serialQueue];

	return metadataOutput;
}

- (NSArray *)metadataOutput:(AVCaptureMetadataOutput *)metadataOutput
		 allowedObjectTypes:(NSArray *)objectTypes
{
	NSSet *available = [NSSet setWithArray:metadataOutput.availableMetadataObjectTypes];

	[available intersectsSet:[NSSet setWithArray:objectTypes]];

	return [available allObjects];
}

- (NSArray *)barcodeMetadataObjectTypes
{
	return @
	[
	 AVMetadataObjectTypeUPCECode,
	 AVMetadataObjectTypeCode39Code,
	 AVMetadataObjectTypeCode39Mod43Code,
	 AVMetadataObjectTypeEAN13Code,
	 AVMetadataObjectTypeEAN8Code,
	 AVMetadataObjectTypeCode93Code,
	 AVMetadataObjectTypeCode128Code,
	 AVMetadataObjectTypePDF417Code,
	 AVMetadataObjectTypeQRCode,
	 AVMetadataObjectTypeAztecCode
	 ];
}

- (NSArray *)faceMetadataObjectTypes
{
	return @
	[
	 AVMetadataObjectTypeFace
	 ];
}

- (AVCaptureVideoDataOutput *)createVideoDataOutput
{
	AVCaptureVideoDataOutput *videoDataOutput = [AVCaptureVideoDataOutput new];

	[videoDataOutput setSampleBufferDelegate:self queue:_serialQueue];

	return videoDataOutput;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
//	[self updateVideoOrientation:toInterfaceOrientation];
}

- (void)updateVideoOrientation:(UIInterfaceOrientation)orientation
{
	AVCaptureConnection *connection = ( (AVCaptureOutput *)_captureSession.outputs[ 0 ] ).connections[ 0 ];

	if ( [connection isVideoOrientationSupported] )
	{
		connection.videoOrientation = [self videoOrientation:orientation];
	}
}

- (AVCaptureVideoOrientation)videoOrientation:(UIInterfaceOrientation)orientation
{
	switch ( orientation )
	{
		case UIDeviceOrientationPortrait: return AVCaptureVideoOrientationPortrait;
		case UIDeviceOrientationPortraitUpsideDown: return AVCaptureVideoOrientationPortraitUpsideDown;
		case UIDeviceOrientationLandscapeLeft: return AVCaptureVideoOrientationLandscapeRight;
		case UIDeviceOrientationLandscapeRight: return AVCaptureVideoOrientationLandscapeLeft;
		default: return AVCaptureVideoOrientationPortrait;
	}
}

- (AVCaptureDevice *)frontOrDefaultCamera
{
	NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];

	for ( AVCaptureDevice *device in devices )
	{
		if ( device.position == AVCaptureDevicePositionFront )
		{
			return device;
		}
	}

	return [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
}


- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	
	if ( [self isViewLoaded] && [[self view] window] == nil )
	{
		self.view = nil;
	
		[self tearDownAVCapture];
	
		if ( [EAGLContext currentContext] == _eaglContext )
		{
			[EAGLContext setCurrentContext:nil];
		}
	
		self.eaglContext = nil;
	}
	
	// Dispose of any resources that can be recreated.
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
}

#pragma mark Metadata capture

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
	_facesMetadata = metadataObjects;
}

#pragma mark Video data capture

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
	CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer( sampleBuffer );

	if ( pixelBuffer )
	{
		CFDictionaryRef attachments = CMCopyDictionaryOfAttachments( kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate );
		CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:(__bridge NSDictionary *)attachments];

		if ( attachments ) CFRelease( attachments );

		CGRect extent = ciImage.extent;

		_filter.inputImage = ciImage;
		_filter.inputFacesMetadata = _facesMetadata;

		CIImage *output = _filter.outputImage;

        if([_filter.faceImages count] > 0)
            [self setFaceImages:(NSArray *)_filter.faceImages];
        
		_filter.inputImage = nil;
		_filter.inputFacesMetadata = nil;

		dispatch_async( dispatch_get_main_queue(),
					   ^{
						   UIView *view = self.view;
						   CGRect bounds = view.bounds;
						   CGFloat scale = view.contentScaleFactor;

						   CGFloat extentFitWidth = extent.size.height / ( bounds.size.height / bounds.size.width );
						   CGRect extentFit = CGRectMake( ( extent.size.width - extentFitWidth ) / 2, 0, extentFitWidth, extent.size.height );

						   CGRect scaledBounds = CGRectMake( bounds.origin.x * scale, bounds.origin.y * scale, bounds.size.width * scale, bounds.size.height * scale );

						   [_ciContext drawImage:output inRect:scaledBounds fromRect:extentFit];
                           //[_ciContext render:output toCVPixelBuffer:pixelBuffer];

//						   [_eaglContext presentRenderbuffer:GL_RENDERBUFFER];
//						   [(GLKView *)self.view display];
                           
                           if([self.faceImages count] > 0){
                               for(int i = 0; i < [self.faceImages count]; i++){
                                   UIImage *_img = (UIImage *)self.faceImages[i];
                                   
                                   [self.faceView setImage:_img];
                               }
                           }

					   });
	}
}

- (BOOL)shouldAutorotate
{
	return NO;
}

@end