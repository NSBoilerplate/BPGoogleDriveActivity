//
//  BPGoogleDriveDestinationSelectionViewController.m
//
//  Created by Jeffrey Sambells on 2014-04-07.
//  Copyright (c) 2014 Jeffrey Sambells. All rights reserved.
//

#import "BPGoogleDriveDestinationSelectionViewController.h"
#import "BPGoogleDrive.h"

#define kGoogleDriveConnectionMaxRetries 2

@interface BPGoogleDriveDestinationSelectionViewController ()
@property (nonatomic) BOOL isLoading;
@property (nonatomic, strong) NSArray *subdirectories;
@property (nonatomic, strong) BPGoogleDrive *driveClient;
@property (nonatomic) NSUInteger driveConnectionRetryCount;
@end

@implementation BPGoogleDriveDestinationSelectionViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _isLoading = YES;
        self.driveConnectionRetryCount = 0;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                           target:self
                                                                                           action:@selector(handleCancel)];
    
    self.toolbarItems = @[
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
        [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Choose", @"Title for button that user taps to specify the current folder as the storage location for uploads.")
                                         style:UIBarButtonItemStyleDone
                                        target:self
                                        action:@selector(handleSelectDestination)]
    ];
    
    [self.navigationController setToolbarHidden:NO];
    self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
    self.navigationController.toolbar.tintColor = [UIColor darkGrayColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleApplicationBecameActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateChooseButton];
    
    if (self.rootFolderID == nil)
        self.rootFolderID = @"root";
    
    if ([self.rootFolderID isEqualToString:@"root"]) {
        self.title = @"Google Drive";
    } else {
        self.title = [self.rootFolderID lastPathComponent];
    }
    self.navigationItem.prompt = NSLocalizedString(@"Choose a destination for uploads.", @"Prompt asking user to select a destination folder on Google Drive to which uploads will be saved.") ;
    self.isLoading = YES;
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void) updateChooseButton {
    NSArray* toolbarButtons = self.toolbarItems;
    if(toolbarButtons.count < 2) {
        //Not found
        return;
    }
    UIBarButtonItem *item = toolbarButtons[1];
    BOOL hasValidData = [self hasValidData];
    item.enabled = hasValidData;
}

- (BOOL) hasValidData {
    BOOL valid = self.subdirectories != nil && self.isLoading == NO;
    return valid;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![[BPGoogleDrive sharedDrive] isLinked]) {
        [self showLoginDialogOrCancel];
    } else {
        [self loadMetadata:self.rootFolderID];
    }
}

- (void) showLoginDialogOrCancel {
    if(self.driveConnectionRetryCount < kGoogleDriveConnectionMaxRetries) {
        self.driveConnectionRetryCount++;
        //disable cancel button, as if the user pressed it while we're presenting
        //the loging viewcontroller (async), UIKit crashes with multiple viewcontroller
        //animations
        self.navigationItem.rightBarButtonItem.enabled = NO;
        [[BPGoogleDrive sharedDrive] linkFromController:self];
    } else {
        [self.delegate driveDestinationSelectionViewControllerDidCancel:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        return YES;
    
    return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (BPGoogleDrive *)driveClient
{
    if (_driveClient == nil && [BPGoogleDrive sharedDrive] != nil) {
        _driveClient = [BPGoogleDrive sharedDrive];
    }
    return _driveClient;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (![self hasValidData] || self.subdirectories.count < 1) return 1;

    return [self.subdirectories count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    if (self.isLoading) {
        cell.textLabel.text = NSLocalizedString(@"Loading...", @"Progress message while app is loading a list of folders from Google Drive");
    } else if (self.subdirectories == nil) {
        cell.textLabel.text = NSLocalizedString(@"Error loading folder contents", @"Error message if the app couldn't load a list of a folder's contents from Google Drive");
    } else if ([self.subdirectories count] == 0) {
        cell.textLabel.text = NSLocalizedString(@"Contains no folders", @"Status message when the current folder contains no sub-folders");
    } else {
        GTLDriveFile *file = [self.subdirectories objectAtIndex:indexPath.row];
        cell.textLabel.text =  file.title;
        cell.imageView.image = [UIImage imageNamed:@"folder-icon.png"];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 56.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.subdirectories count] > indexPath.row) {
        GTLDriveFile *file = [self.subdirectories objectAtIndex:indexPath.row];

        BPGoogleDriveDestinationSelectionViewController *vc = [[BPGoogleDriveDestinationSelectionViewController alloc] init];
        vc.delegate = self.delegate;
        vc.rootFolderID = file.identifier;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - Google Drive client delegate methods

- (void)loadMetadata:(NSString *)parentID {
    
    [self.driveClient loadMetadata:parentID completion:^(NSArray *items) {
        self.subdirectories = items ?: [NSArray new];
        self.isLoading = NO;
        [self updateChooseButton];
    } failure:^(NSError *error) {
        // Error 401 gets returned if a token is invalid, e.g. if the user has deleted
        // the app from their list of authorized apps at drive.com
        if (error.code == 401) {
            [self showLoginDialogOrCancel];
        } else {
            self.isLoading = NO;
        }
        [self updateChooseButton];
        
    }];
    
}

- (void)setIsLoading:(BOOL)isLoading
{
    if (_isLoading != isLoading) {
        _isLoading = isLoading;
        [self.tableView reloadData];
    }
}

- (void)handleCancel
{
    id<BPGoogleDriveDestinationSelectionViewControllerDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(driveDestinationSelectionViewControllerDidCancel:)]) {
        [delegate driveDestinationSelectionViewControllerDidCancel:self];
    }
}

- (void)handleSelectDestination
{
    id<BPGoogleDriveDestinationSelectionViewControllerDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(driveDestinationSelectionViewController:didSelectDestinationParentID:)]) {
        [delegate driveDestinationSelectionViewController:self
                                   didSelectDestinationParentID:self.rootFolderID];
    }
}

- (void)handleApplicationBecameActive:(NSNotification *)notification
{
    //[self.driveClient loadMetadata:self.rootPath];
    //self.isLoading = YES;
    //self.navigationItem.rightBarButtonItem.enabled = YES;
}

@end
