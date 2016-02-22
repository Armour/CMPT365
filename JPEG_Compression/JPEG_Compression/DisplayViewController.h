//
//  DisplayViewController.h
//  JPEG_Compression
//
//  Created by Armour on 2/22/16.
//  Copyright © 2016 SFU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/opencv.hpp>

@interface DisplayViewController : UIViewController

@property (nonatomic) cv::Mat YImage;
@property (nonatomic) cv::Mat CbImage;
@property (nonatomic) cv::Mat CrImage;

@end
