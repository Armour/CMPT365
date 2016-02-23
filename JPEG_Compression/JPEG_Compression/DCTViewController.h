//
//  DCTViewController.h
//  JPEG_Compression
//
//  Created by Armour on 2/21/16.
//  Copyright © 2016 SFU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/opencv.hpp>

#define GET_R_FROM_YCbCr (Y +                          1.402 * (Cr - 128))
#define GET_G_FROM_YCbCr (Y - 0.34414 * (Cb - 128) - 0.71414 * (Cr - 128))
#define GET_B_FROM_YCbCr (Y +   1.772 * (Cb - 128)                       )

@interface DCTViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate>

@property (nonatomic) cv::Mat originalImage;
@property (nonatomic) cv::Mat YImage;
@property (nonatomic) cv::Mat CbImage;
@property (nonatomic) cv::Mat CrImage;

@end