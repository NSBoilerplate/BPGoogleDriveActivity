//
//  BPGoogleDriveDestinationSelectionViewController.h
//
//  Created by Jeffrey Sambells on 2014-04-07.
//  Copyright (c) 2014 Jeffrey Sambells. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BPGoogleDriveDestinationSelectionViewControllerDelegate;

@interface BPGoogleDriveDestinationSelectionViewController : UITableViewController

@property (nonatomic, strong) NSString *rootFolderID;
@property (nonatomic, weak) id<BPGoogleDriveDestinationSelectionViewControllerDelegate> delegate;

@end

@protocol BPGoogleDriveDestinationSelectionViewControllerDelegate <NSObject>

- (void)driveDestinationSelectionViewController:(BPGoogleDriveDestinationSelectionViewController*)viewController
                         didSelectDestinationParentID:(NSString *)parentID;
- (void)driveDestinationSelectionViewControllerDidCancel:(BPGoogleDriveDestinationSelectionViewController*)viewController;

@end