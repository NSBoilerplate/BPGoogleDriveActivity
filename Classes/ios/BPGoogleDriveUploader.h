//
//  BPGoogleDriveUploader.h
//
//  Created by Jeffrey Sambells on 2014-04-07.
//  Copyright (c) 2014 Jeffrey Sambells. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BPGoogleDriveUploader : NSObject

/* NSNotification names */
extern NSString *const BPGoogleDriveUploaderDidStartUploadingFileNotification;
extern NSString *const BPGoogleDriveUploaderDidFinishUploadingFileNotification;
extern NSString *const BPGoogleDriveUploaderDidGetProgressUpdateNotification;
extern NSString *const BPGoogleDriveUploaderDidFailNotification;

/* UserInfo dictionary keys */
extern NSString *const BPGoogleDriveUploaderFileURLKey;
extern NSString *const BPGoogleDriveUploaderProgressKey;

/* The singleton Google Drive uploader - use this for all your Google Drive uploads */
+ (BPGoogleDriveUploader*)sharedUploader;

- (void)uploadFileWithURL:(NSURL *)fileURL toParentID:(NSString*)parentID mimeType:(NSString *)mimeType;

/* Uploads are processed one at a time. If you call uploadFileWithURL:toPath: while an upload's already in progress the new upload will be queued. pendingUploadCount returns the number of uploads currently in the queue pending processing. */
- (NSUInteger)pendingUploadCount;

/* Cancel all uploads, whether in flight or queued. */
- (void)cancelAll;

@end
