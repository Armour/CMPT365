//
//  DisplayViewController.h
//  JPEG_Compression
//
//  Created by Armour on 2/22/16.
//  Copyright © 2016 SFU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/opencv.hpp>

@interface DisplayViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource> {
  @public
    std::vector<cv::Mat> YImage;
    std::vector<cv::Mat> CbImage;
    std::vector<cv::Mat> CrImage;
}

@property (nonatomic) NSInteger quantizationMatrixChoosedNumber;

@end
