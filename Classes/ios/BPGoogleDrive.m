//
//  BPGoogleDrive.m
//  BPGoogleDriveDemoApp
//
//  Created by Jeffrey Sambells on 2014-04-07.
//  Copyright (c) 2014 Jeffrey Sambells. All rights reserved.
//

#import <objc/runtime.h>
#import <gtm-oauth2/GTMOAuth2ViewControllerTouch.h>

#import "BPGoogleDrive.h"
#import "BPGoogleDriveUploader.h"

#define KEYCHAIN_NAME @"com.nsboilerplate.BPGoogleDrive"

@interface BPGoogleDrive()

@property (strong, nonatomic) NSString *clientID;
@property (strong, nonatomic) NSString *appSecret;
@property (strong, nonatomic) NSString *scope;

@property (strong, nonatomic) GTLServiceTicket *currentTicket;

@end

@implementation BPGoogleDrive

#pragma mark - Intitalization

- (id)initWithClientID:(NSString *)clientID appSecret:(NSString *)appSecret scope:(NSString *)scope
{
    if ((self = [super init])) {
        // TODO
        self.clientID = clientID;
        self.appSecret = appSecret;
        self.scope = scope;
        self.authorizer = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:KEYCHAIN_NAME clientID:clientID clientSecret:appSecret];
        self.shouldFetchNextPages = YES;
        self.retryEnabled = YES;
    }
    return self;
}

- (void)cancelAllRequests
{
    [[BPGoogleDriveUploader sharedUploader] cancelAll];
    [self.currentTicket cancelTicket];
}

#pragma mark - Shared Drive

+ (void)setSharedDrive:(BPGoogleDrive *)drive
{
    objc_setAssociatedObject(self, @selector(sharedDrive), drive, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (BPGoogleDrive *)sharedDrive
{
    return objc_getAssociatedObject(self, @selector(sharedDrive));
}

#pragma mark - Authentication

- (BOOL)isLinked
{
    return [((GTMOAuth2Authentication *)self.authorizer) canAuthorize];
}

- (void)linkFromController:(UIViewController *)controller
{
    [controller presentViewController:[self createAuthController] animated:YES completion:nil];
}

// Creates the auth controller for authorizing access to Google Drive.
- (GTMOAuth2ViewControllerTouch *)createAuthController
{
    GTMOAuth2ViewControllerTouch *authController;
    authController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:self.scope
                                                                clientID:self.clientID
                                                            clientSecret:self.appSecret
                                                        keychainItemName:KEYCHAIN_NAME
                                                                delegate:self
                                                        finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    return authController;
}

// Handle completion of the authorization process, and updates the Drive service
// with the new credentials.
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)authResult
                 error:(NSError *)error
{
    if (error != nil)
    {
        [self showAlert:@"Authentication Error" message:error.localizedDescription];
        self.authorizer = nil;
    }
    else
    {
        self.authorizer = authResult;
    }
    
    [viewController.presentingViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - Loading Folder Meta Data

- (GTLServiceTicket *)loadMetadata:(NSString *)parentId completion:(void (^)(NSArray *items))completion failure:(void (^)(NSError *error))failure
{
    GTLServiceDrive *drive = self;
    NSString *parents = parentId ?: @"root";
    
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesList];
    query.q = [NSString stringWithFormat:@"mimeType='application/vnd.google-apps.folder' and '%@' in parents and trashed=false", parents];
    
    GTLServiceTicket *queryTicket =
    [drive executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLDriveFileList *files, NSError *error) {
        if (error == nil) {
            NSLog(@"Have results");
            // Iterate over files.items array
            if (completion) {
                completion(files.items);
            }
        } else {
            NSLog(@"An error occurred: %@", error);
            if (failure) {
                failure(error);
            }
        }
    }];
    
    self.currentTicket = queryTicket;
    return queryTicket;
}

#pragma mark - Uploading

- (GTLServiceTicket *)uploadFile:(NSString *)filename
          mimeType:(NSString *)mimeType
        toParentID:(NSString *)toParentID
          fromPath:(NSString *)fromPath
        completion:(void (^)(GTLDriveFile *file))completion
           failure:(void (^)(NSError *error))failure
          progress:(void (^)(CGFloat progress))progress
{
    GTLDriveFile *file = [GTLDriveFile object];
    
    file.title = filename;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"'Uploaded on ('EEEE MMMM d, YYYY h:mm a, zzz')"];

    file.descriptionProperty = [dateFormat stringFromDate:[NSDate date]];
    file.mimeType = mimeType;

    GTLDriveParentReference *parentRef = [GTLDriveParentReference object];
    parentRef.identifier = toParentID;
    file.parents = @[ parentRef ];
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:fromPath]];

    GTLUploadParameters *uploadParameters =
    [GTLUploadParameters uploadParametersWithData:data MIMEType:mimeType];
    GTLQueryDrive *query =
    [GTLQueryDrive queryForFilesInsertWithObject:file
                                uploadParameters:uploadParameters];
    
    // TODO cancel query ticket if necessary.
    
    GTLServiceTicket *queryTicket =
    [self executeQuery:query
     completionHandler:^(GTLServiceTicket *ticket,
                         GTLDriveFile *insertedFile, NSError *error) {
         
         if (error == nil) {
             completion(insertedFile);
             
         } else {
             //NSLog(@"An error occurred: %@", error);
             failure(error);
         }
     }];
    
    queryTicket.uploadProgressBlock = ^(GTLServiceTicket *ticket,
                                        unsigned long long numberOfBytesRead,
                                        unsigned long long dataLength) {
        float myprogress = (1.0 / dataLength * numberOfBytesRead);
        NSLog(@"progress => %f",myprogress);
        progress(myprogress);
    };

    self.currentTicket = queryTicket;
    return queryTicket;
}

- (NSString *)getParentIdForPath:(NSString *)remotePath
{
    // TODO
    if ([remotePath isEqualToString:@"/"]) {
        return @"root";
    }
    return @"root";
}

- (NSString *)getOrCreateParentIdForPath:(NSString *)remotePath
{
    // TODO
    return @"root";
}

// Helper for showing an alert
- (void)showAlert:(NSString *)title message:(NSString *)message
{
    UIAlertView *alert;
    alert = [[UIAlertView alloc] initWithTitle: title
                                       message: message
                                      delegate: nil
                             cancelButtonTitle: @"OK"
                             otherButtonTitles: nil];
    [alert show];
}


@end
