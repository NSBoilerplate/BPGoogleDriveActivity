//
//  BPGoogleDriveActivity.m
//
//  Created by Jeffrey Sambells on 2014-04-07.
//  Copyright (c) 2014 Jeffrey Sambells. All rights reserved.
//

#import "BPGoogleDriveActivity.h"
#import "BPGoogleDriveDestinationSelectionViewController.h"
#import "BPGoogleDriveUploader.h"

@interface BPGoogleDriveActivity() <BPGoogleDriveDestinationSelectionViewControllerDelegate>

@property (nonatomic, copy) NSArray *activityItems;
@property (nonatomic, retain) BPGoogleDriveDestinationSelectionViewController *driveDestinationViewController;
@end

@implementation BPGoogleDriveActivity

+ (NSString *)activityTypeString
{
    return @"com.nsboilerplace.GoogleDriveActivity";
}

- (NSString *)activityType {
    return [BPGoogleDriveActivity activityTypeString];
}

- (NSString *)activityTitle {
    return @"Google Drive";
}
- (UIImage *)activityImage {
    if ([[[[UIDevice currentDevice] systemVersion] substringToIndex:1] integerValue] <= 6) {
        return [UIImage imageNamed:@"BPGoogleDriveActivityIcon-iOS6"];
    } else {
        return [UIImage imageNamed:@"BPGoogleDriveActivityIcon"];
    }
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    for (id obj in activityItems) {
        if ([obj isKindOfClass:[NSURL class]]) {
            return YES;
        }
    }
    return NO;
};

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    // Filter out any items that aren't NSURL objects
    NSMutableArray *urlItems = [NSMutableArray arrayWithCapacity:[activityItems count]];
    for (id object in activityItems) {
        if ([object isKindOfClass:[NSURL class]]) {
            [urlItems addObject:object];
        }
    }
    self.activityItems = [NSArray arrayWithArray:urlItems];
}

- (UIViewController *)activityViewController {
    BPGoogleDriveDestinationSelectionViewController *vc = [[BPGoogleDriveDestinationSelectionViewController alloc] initWithStyle:UITableViewStylePlain];
    vc.delegate = self;

    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    nc.modalPresentationStyle = UIModalPresentationFormSheet;
    
    return nc;
}

#pragma mark - BPGoogleDriveDestinationSelectionViewController delegate methods

- (void)driveDestinationSelectionViewController:(BPGoogleDriveDestinationSelectionViewController *)viewController
                         didSelectDestinationParentID:(NSString *)parentID
{
    for (NSURL *fileURL in self.activityItems) {
        // TODO need mime type
        [[BPGoogleDriveUploader sharedUploader] uploadFileWithURL:fileURL toParentID:parentID mimeType:@"image/jpg"];
    }
    self.activityItems = nil;
    [self activityDidFinish:YES];
}

- (void)driveDestinationSelectionViewControllerDidCancel:(BPGoogleDriveDestinationSelectionViewController *)viewController
{
    self.activityItems = nil;
    [self activityDidFinish:NO];
}

@end
