//
//  BPGoogleDriveUploadJob.m
//
//  Created by Jeffrey Sambells on 2014-04-07.
//  Copyright (c) 2014 Jeffrey Sambells. All rights reserved.
//

#import "BPGoogleDriveUploadJob.h"

@implementation BPGoogleDriveUploadJob

+ (BPGoogleDriveUploadJob *)uploadJobWithFileURL:(NSURL *)fileURL andDestinationParentID:(NSString *)destinationParentID andMimeType:(NSString *)mimeType
{
    BPGoogleDriveUploadJob *job = [[BPGoogleDriveUploadJob alloc] init];
    job.fileURL = fileURL;
    job.destinationParentID = destinationParentID;
    job.mimeType = mimeType;
    return job;
}

@end
