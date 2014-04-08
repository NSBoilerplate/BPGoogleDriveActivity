//
//  BPGoogleDriveUploadJob.h
//
//  Created by Jeffrey Sambells on 2014-04-07.
//  Copyright (c) 2014 Jeffrey Sambells. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BPGoogleDriveUploadJob : NSObject

@property (nonatomic, strong) NSURL *fileURL;
@property (nonatomic, strong) NSString *destinationParentID;
@property (nonatomic, strong) NSString *mimeType;

+ (BPGoogleDriveUploadJob *)uploadJobWithFileURL:(NSURL *)fileURL andDestinationParentID:(NSString *)destinationParentID andMimeType:(NSString *)mimeType;

@end
