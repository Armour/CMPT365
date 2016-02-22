//
//  ChangeColorViewController.h
//  JPEG_Compression
//
//  Created by Armour on 2/20/16.
//  Copyright © 2016 SFU. All rights reserved.
//

#import <UIKit/UIKit.h>

#define GET_Y_FROME_RGB  (65.481 * R + 128.553 * G + 24.966 * B + 16)
#define GET_Cb_FROME_RGB (-37.797 * R - 74.203 * G + 112 * B + 128)
#define GET_Cr_FROME_RGB (112 * R - 93.786 * G - 18.214 * B + 128)

@interface ChangeColorViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>

@property (strong, nonatomic) UIImage *originalImage;

@end