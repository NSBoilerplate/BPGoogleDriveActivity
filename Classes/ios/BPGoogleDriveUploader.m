//
//  BPGoogleDriveUploader.m
//
//  Created by Jeffrey Sambells on 2014-04-07.
//  Copyright (c) 2014 Jeffrey Sambells. All rights reserved.
//

#import "BPGoogleDriveUploader.h"
#import "BPGoogleDriveUploadJob.h"
#import "BPGoogleDrive.h"

NSString *const BPGoogleDriveUploaderDidStartUploadingFileNotification = @"BPGoogleDriveUploaderDidStartUploadingFileNotification";
NSString *const BPGoogleDriveUploaderDidFinishUploadingFileNotification = @"BPGoogleDriveUploaderDidFinishUploadingFileNotification";
NSString *const BPGoogleDriveUploaderDidGetProgressUpdateNotification = @"BPGoogleDriveUploaderDidGetProgressUpdateNotification";
NSString *const BPGoogleDriveUploaderDidFailNotification = @"BPGoogleDriveUploaderDidFailNotification";

NSString *const BPGoogleDriveUploaderFileURLKey = @"BPGoogleDriveUploaderFileURLKey";
NSString *const BPGoogleDriveUploaderProgressKey = @"BPGoogleDriveUploaderProgressKey";

@interface BPGoogleDriveUploader()

// inFlightUploadJob: the file wrapper currently being uploaded
@property (nonatomic, strong) BPGoogleDriveUploadJob *_inFlightUploadJob;
@property (nonatomic, strong) NSMutableArray *_uploadQueue;
@property (nonatomic, strong) BPGoogleDrive *_driveClient;

- (void)_serviceQueue;

@end

@implementation BPGoogleDriveUploader

- (id)init
{
    self = [super init];
    if (self) {
        self._uploadQueue = [NSMutableArray array];
    }
    return self;
}

+ (BPGoogleDriveUploader *)sharedUploader
{
    static dispatch_once_t once;
    static BPGoogleDriveUploader *singleton;
    dispatch_once(&once, ^ { singleton = [[BPGoogleDriveUploader alloc] init]; });
    return singleton;
}

- (void)uploadFileWithURL:(NSURL *)fileURL toParentID:(NSString *)parentID mimeType:(NSString *)mimeType
{
    [self._uploadQueue addObject:[BPGoogleDriveUploadJob uploadJobWithFileURL:fileURL
                                                           andDestinationParentID:parentID
                                                                  andMimeType:mimeType]];
    [self _serviceQueue];
}

- (void)start
{
    [self _serviceQueue];
}

- (void)_serviceQueue
{
    if ([self._uploadQueue count] > 0 && self._inFlightUploadJob == nil) {
        @synchronized(self) {
            self._inFlightUploadJob = [self._uploadQueue objectAtIndex:0];
            [self._uploadQueue removeObjectAtIndex:0];
        }

        [[NSNotificationCenter defaultCenter] postNotificationName:BPGoogleDriveUploaderDidStartUploadingFileNotification
                                                            object:self
                                                          userInfo:@{BPGoogleDriveUploaderFileURLKey: self._inFlightUploadJob.fileURL}];
        
        [self._driveClient uploadFile:self._inFlightUploadJob.fileURL.lastPathComponent
                             mimeType:self._inFlightUploadJob.mimeType
                           toParentID:self._inFlightUploadJob.destinationParentID
                             fromPath:self._inFlightUploadJob.fileURL.path
                           completion:^(GTLDriveFile *file) {
                               [[NSNotificationCenter defaultCenter] postNotificationName:BPGoogleDriveUploaderDidFinishUploadingFileNotification
                                                                                   object:self
                                                                                 userInfo:@{BPGoogleDriveUploaderFileURLKey: self._inFlightUploadJob.fileURL}];
                               self._inFlightUploadJob = nil;
                               [self _serviceQueue];
                              } failure:^(NSError *error) {
                                  [[NSNotificationCenter defaultCenter] postNotificationName:BPGoogleDriveUploaderDidFailNotification
                                                                                      object:self
                                                                                    userInfo:@{BPGoogleDriveUploaderFileURLKey: self._inFlightUploadJob.fileURL}];
                                  self._inFlightUploadJob = nil;
                                  [self _serviceQueue];
                              } progress:^(CGFloat progress) {
                                  NSDictionary *userInfo = @{
                                                             BPGoogleDriveUploaderFileURLKey: self._inFlightUploadJob.fileURL,
                                                             BPGoogleDriveUploaderProgressKey: @(progress),
                                                             };
                                  [[NSNotificationCenter defaultCenter] postNotificationName:BPGoogleDriveUploaderDidGetProgressUpdateNotification
                                                                                      object:self
                                                                                    userInfo:userInfo];
                              }];
    }
}

- (NSUInteger)pendingUploadCount
{
    return [self._uploadQueue count];
}

- (void)cancelAll
{
    NSLog(@"Cancelling Google Drive uploads");
    [self._uploadQueue removeAllObjects];
    [self._driveClient cancelAllRequests];
    self._inFlightUploadJob = nil;
}

- (BPGoogleDrive *)_driveClient
{
    if (__driveClient == nil && [BPGoogleDrive sharedDrive] != nil) {
        __driveClient = [BPGoogleDrive sharedDrive];
    }
    return __driveClient;
}


@end
