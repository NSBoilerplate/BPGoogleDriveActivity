//
//  BPViewController.m
//  BPGoogleDriveDemoApp
//
//  Created by Jeffrey Sambells on 2014-04-07.
//  Copyright (c) 2014 Jeffrey Sambells. All rights reserved.
//

#import "BPViewController.h"
#import <BPGoogleDriveActivity/BPGoogleDriveActivity.h>
#import <BPGoogleDriveActivity/BPGoogleDriveUploader.h>

@interface BPViewController ()

@property (nonatomic, retain) UIPopoverController *activityPopoverController;
@property (nonatomic, strong) IBOutlet UIProgressView *progressView;

@end

@implementation BPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.progressView.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleGoogleDriveFileProgressNotification:)
                                                 name:BPGoogleDriveUploaderDidGetProgressUpdateNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleGoogleDriveUploadDidStartNotification:)
                                                 name:BPGoogleDriveUploaderDidStartUploadingFileNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleGoogleDriveUploadDidFinishNotification:)
                                                 name:BPGoogleDriveUploaderDidFinishUploadingFileNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleGoogleDriveUploadDidFailNotification:)
                                                 name:BPGoogleDriveUploaderDidFailNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)shareKitten:(id)sender
{
    NSURL *kittenFileURL = [[NSBundle mainBundle] URLForResource:@"kitten.jpg" withExtension:nil];
    NSArray *objectsToShare = @[
        kittenFileURL
    ];
    NSArray *activities = @[
        [[BPGoogleDriveActivity alloc] init]
    ];
    
    UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare
                                                                     applicationActivities:activities];
    
    // Exclude some default activity types to keep this demo clean and simple.
    vc.excludedActivityTypes = @[
        UIActivityTypeAssignToContact,
        UIActivityTypeCopyToPasteboard,
        UIActivityTypePostToFacebook,
        UIActivityTypePostToTwitter,
        UIActivityTypePostToWeibo,
        UIActivityTypePrint,
    ];
    
    if (isIpad) {
        if (self.activityPopoverController.isPopoverVisible) {
            // If the popover's visible, hide it
            [self.activityPopoverController dismissPopoverAnimated:YES];
        } else {
            if (self.activityPopoverController == nil) {
                self.activityPopoverController = [[UIPopoverController alloc] initWithContentViewController:vc];
            } else {
                self.activityPopoverController.contentViewController = vc;
            }
            
            // Set a completion handler to dismiss the popover
            [vc setCompletionHandler:^(NSString *activityType, BOOL completed){
                [self.activityPopoverController dismissPopoverAnimated:YES];
            }];
            
            [[self activityPopoverController] presentPopoverFromRect:[((UIControl*)sender) frame] inView:[self view] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    } else {
        [self presentViewController:vc animated:YES completion:NULL];
    }
}

- (void)handleGoogleDriveFileProgressNotification:(NSNotification *)notification
{
    NSURL *fileURL = notification.userInfo[BPGoogleDriveUploaderFileURLKey];
    float progress = [notification.userInfo[BPGoogleDriveUploaderProgressKey] floatValue];
    NSLog(@"Upload of %@ now at %.0f%%", fileURL.absoluteString, progress * 100);
    
    self.progressView.progress = progress;
}

- (void)handleGoogleDriveUploadDidStartNotification:(NSNotification *)notification
{
    NSURL *fileURL = notification.userInfo[BPGoogleDriveUploaderFileURLKey];
    NSLog(@"Started uploading %@", fileURL.absoluteString);

    self.progressView.progress = 0.0;
    self.progressView.hidden = NO;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)handleGoogleDriveUploadDidFinishNotification:(NSNotification *)notification
{
    NSURL *fileURL = notification.userInfo[BPGoogleDriveUploaderFileURLKey];
    NSLog(@"Finished uploading %@", fileURL.absoluteString);
    
    self.progressView.hidden = YES;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)handleGoogleDriveUploadDidFailNotification:(NSNotification *)notification
{
    NSURL *fileURL = notification.userInfo[BPGoogleDriveUploaderFileURLKey];
    NSLog(@"Failed to upload %@", fileURL.absoluteString);

    self.progressView.hidden = YES;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end
