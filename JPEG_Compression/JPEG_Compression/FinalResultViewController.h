//
//  FinalResultViewController.h
//  JPEG_Compression
//
//  Created by Armour on 2/22/16.
//  Copyright © 2016 SFU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/opencv.hpp>

@interface FinalResultViewController : UIViewController

@property (nonatomic) cv::Mat originalImage;
@property (nonatomic) cv::Mat finalImage;

@end
