//
//  ChangeColorViewController.h
//  JPEG_Compression
//
//  Created by Armour on 2/20/16.
//  Copyright © 2016 SFU. All rights reserved.
//

#import <UIKit/UIKit.h>

//#define GET_Y_FROM_RGB  (65.481 * R + 128.553 * G + 24.966 * B + 16)
//#define GET_Cb_FROM_RGB (-37.797 * R - 74.203 * G + 112 * B + 128)
//#define GET_Cr_FROM_RGB (112 * R - 93.786 * G - 18.214 * B + 128)

#define GET_Y_FROM_RGB  (    0.299 * R +    0.587 * G +    0.114 * B +   0)
#define GET_Cb_FROM_RGB (-0.168736 * R - 0.331264 * G +      0.5 * B + 128)
#define GET_Cr_FROM_RGB (      0.5 * R - 0.418688 * G - 0.081312 * B + 128)

@interface ChangeColorViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>

@property (strong, nonatomic) UIImage *originalImage;

@end