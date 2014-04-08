//
//  BPGoogleDrive.h
//  BPGoogleDriveDemoApp
//
//  Created by Jeffrey Sambells on 2014-04-07.
//  Copyright (c) 2014 Jeffrey Sambells. All rights reserved.
//

#import "GTLServiceDrive.h"
#import <Google-API-Client/GTLDrive.h>

@interface BPGoogleDrive : GTLServiceDrive

- (id)initWithClientID:(NSString *)clientID appSecret:(NSString *)appSecret scope:(NSString *)scope;
+ (void)setSharedDrive:(BPGoogleDrive *)drive;
+ (instancetype)sharedDrive;

- (void)cancelAllRequests;

- (BOOL)isLinked;
- (void)linkFromController:(UIViewController *)controller;

- (GTLServiceTicket *)loadMetadata:(NSString *)parentId
                        completion:(void (^)(NSArray *items))completion
                           failure:(void (^)(NSError *error))failure;

- (GTLServiceTicket *)uploadFile:(NSString *)filename
                        mimeType:(NSString *)mimeType
                      toParentID:(NSString *)toParentID
                        fromPath:(NSString *)fromPath
                      completion:(void (^)(GTLDriveFile *file))completion
                         failure:(void (^)(NSError *error))failure
                        progress:(void (^)(CGFloat progress))progress;
@end
