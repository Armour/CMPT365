//
//  ViewController.h
//  JPEG_Compression
//
//  Created by Armour on 2/19/16.
//  Copyright © 2016 SFU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/opencv.hpp>
#import <MobileCoreServices/MobileCoreServices.h>

@interface ViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *mainPageImageView;

@end