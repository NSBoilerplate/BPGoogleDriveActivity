# BPGoogleDriveActivity

[![Version](http://cocoapod-badges.herokuapp.com/v/BPGoogleDriveActivity/badge.png)](http://cocoadocs.org/docsets/BPGoogleDriveActivity)
[![Platform](http://cocoapod-badges.herokuapp.com/p/BPGoogleDriveActivity/badge.png)](http://cocoadocs.org/docsets/BPGoogleDriveActivity)

BPGoogleDriveActivity is an iOS UIActivity subclass for uploading to Dropbox.

The structure of the pod is based on [GSDropboxActivity](https://github.com/goosoftware/GSDropboxActivity) but has been reworked for Google Drive. 


## Usage

To run the example project; clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

## 1. Install BPGoogleDriveActivity

BPGoogleDriveActivity is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

    pod "BPGoogleDriveActivity"



## 2. Add initialize BPGoogleDrive in your app delegate:

```objective-c
#import <DropboxSDK/DropboxSDK.h>

...

DBSession* dbSession = [[DBSession alloc] initWithAppKey:@"APP_KEY"
                                               appSecret:@"APP_SECRET"
                                                    root:ACCESS_TYPE]; // either kDBRootAppFolder or kDBRootDropbox
[DBSession setSharedSession:dbSession];
```


## 3. Add a BPGoogleDriveActivity object to your list of custom activities and share some NSURL objects

BPGoogleDriveActivity can share NSURL objects where each object is the URL of a file on the local disk.

```objective-c
- (void)handleShareButton:(id)sender
{
    NSArray *itemsToShare = @[
        // Your items to share go here.
        // BPGoogleDriveActivity can share NSURL objects where each object is
        // the file URL to a file on disk.
    ];
    NSArray *applicationActivities = @[
        [[BPGoogleDriveActivity alloc] init]
    ];
    UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare
                                                                     applicationActivities:applicationActivities];

    // Present modally - suitable for iPhone.
    // On iPad, you should present in a UIPopoverController
    [self presentViewController:vc animated:YES completion:NULL];
}
```
## 4. Listen out for notifications

The following notifications are declared in `BPGoogleDriveUploader.h`:

### BPGoogleDriveUploaderDidStartUploadingFileNotification

Fired when a file starts uploading. 

**userInfo dictionary entries:**

* `BPGoogleDriveUploaderFileURLKey`: the URL of the file being uploaded

### BPGoogleDriveUploaderDidFinishUploadingFileNotification

Fired when a file finishes uploading. 

**userInfo dictionary entries:**

* `BPGoogleDriveUploaderFileURLKey`: the URL of the file being uploaded

### BPGoogleDriveUploaderDidGetProgressUpdateNotification

Fired periodically while a file is uploading. 

**userInfo dictionary entries:**

* `BPGoogleDriveUploaderFileURLKey`: the URL of the file being uploaded
* `BPGoogleDriveUploaderProgressKey`: the current upload progress; an `NSNumber` whose `floatValue` is between 0.0 and 1.0

### BPGoogleDriveUploaderDidFailNotification

Fired when a file fails to upload.

**userInfo dictionary entries:**

* `BPGoogleDriveUploaderFileURLKey`: the URL of the file being uploaded




## Author

Jeffrey Sambells, bp@tropicalpixels.com

## License


[![Creative Commons License][cc-by-30-icon]][cc-by-30]

This work is licensed under a [Creative Commons Attribution 3.0 Unported License][cc-by-30].

You're free to use this code in any project, including commercial. Please include the following text somewhere suitable, e.g. your app's About screen:

**Uses BPGoogleDriveActivity by Jeffrey Sambells based on GSDropboxActivity by Simon Whitaker**

[cc-by-30-icon]: http://i.creativecommons.org/l/by/3.0/88x31.png
[cc-by-30]: http://creativecommons.org/licenses/by/3.0/
[dropbox-ios-sdk]: https://www.dropbox.com/developers/reference/sdk

