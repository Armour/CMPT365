//
//  ChangeColorViewController.m
//  JPEG_Compression
//
//  Created by Armour on 2/20/16.
//  Copyright © 2016 SFU. All rights reserved.
//

#import "ChangeColorViewController.h"
#include <vector>

@interface ChangeColorViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *channelYImageView;
@property (strong, nonatomic) IBOutlet UIImageView *channelUImageView;
@property (strong, nonatomic) IBOutlet UIImageView *channelVImageView;
@property (strong, nonatomic) IBOutlet UIPickerView *chromaSubsamplingPickerView;

@property (nonatomic) cv::Mat RGBImage;
@property (nonatomic) cv::Mat YImage;
@property (nonatomic) cv::Mat UImage;
@property (nonatomic) cv::Mat VImage;

@property (strong, nonatomic) NSArray *subsamplingPickerData;
@property (nonatomic) BOOL isChoosingSubsamplingMethod;
@property (nonatomic) CGPoint originalSubsamplingPickerViewCenterPoint;

- (void)RGBtoYUV;

@end

@implementation ChangeColorViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self RGBtoYUV];

    self.chromaSubsamplingPickerView.delegate = self;
    self.chromaSubsamplingPickerView.dataSource = self;
    self.chromaSubsamplingPickerView.backgroundColor = [UIColor whiteColor];

    self.subsamplingPickerData = [[NSArray alloc] initWithObjects:@"Choose subsampling method", @"4:4:4", @"4:2:2", @"4:2:0", @"4:1:1", nil];

    self.isChoosingSubsamplingMethod = false;

    self.originalSubsamplingPickerViewCenterPoint = self.chromaSubsamplingPickerView.center;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.channelYImageView setImage:[MatConvert UIImageFromCVMat:self.YImage]];
    [self.channelYImageView setBackgroundColor:[UIColor blackColor]];
    [self.channelYImageView setContentMode:UIViewContentModeScaleAspectFit];

    [self.channelUImageView setImage:[MatConvert UIImageFromCVMat:self.UImage]];
    [self.channelUImageView setBackgroundColor:[UIColor blackColor]];
    [self.channelUImageView setContentMode:UIViewContentModeScaleAspectFit];

    [self.channelVImageView setImage:[MatConvert UIImageFromCVMat:self.VImage]];
    [self.channelVImageView setBackgroundColor:[UIColor blackColor]];
    [self.channelVImageView setContentMode:UIViewContentModeScaleAspectFit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - RGB To YUV

- (void)RGBtoYUV {
    std::vector<cv::Mat> RGBChannels;
    std::vector<cv::Mat> YUVChannels;
    self.RGBImage = [MatConvert cvMatFromUIImage:self.originalImage];

    cv::split(self.RGBImage, RGBChannels);
    cv::split(self.RGBImage, YUVChannels);

    cv::Size size = self.RGBImage.size();
    int imageWidth = size.width;
    int imageHeight = size.height;

    for (int i = 0; i < imageHeight; i++) {
        for (int j = 0; j < imageWidth; j++) {
            float R = (float)RGBChannels[0].at<uchar>(i, j) / 255;
            float G = (float)RGBChannels[1].at<uchar>(i, j) / 255;
            float B = (float)RGBChannels[2].at<uchar>(i, j) / 255;
            YUVChannels[0].at<uchar>(i, j) = (uchar)GET_Y_FROME_RGB;
            YUVChannels[1].at<uchar>(i, j) = (uchar)GET_Cb_FROME_RGB;
            YUVChannels[2].at<uchar>(i, j) = (uchar)GET_Cr_FROME_RGB;
        }
    }

    self.YImage = YUVChannels[0];
    self.UImage = YUVChannels[1];
    self.VImage = YUVChannels[2];
}

#pragma mark - Button Click Event

- (IBAction)chooseSubsampling:(UIBarButtonItem *)sender {
    if (!self.isChoosingSubsamplingMethod) {
        self.isChoosingSubsamplingMethod = true;
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options:UIViewAnimationTransitionNone
                         animations:^{
                             self.chromaSubsamplingPickerView.center =
                             CGPointMake(self.chromaSubsamplingPickerView.center.x,
                                         self.chromaSubsamplingPickerView.center.y
                                         - [self.chromaSubsamplingPickerView frame].size.height);
                         } completion:^(BOOL finished) {
                         }];
    }
}

#pragma mark - Tap Gesture Event

- (IBAction)TapGestureEvent:(UITapGestureRecognizer *)sender {
    if (self.isChoosingSubsamplingMethod) {
        self.isChoosingSubsamplingMethod = false;
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options:UIViewAnimationTransitionNone
                         animations:^{
                             self.chromaSubsamplingPickerView.center =
                             CGPointMake(self.chromaSubsamplingPickerView.center.x,
                                         self.chromaSubsamplingPickerView.center.y
                                         + [self.chromaSubsamplingPickerView frame].size.height);
                         } completion:^(BOOL finished) {
                         }];
    }
}

#pragma mark - UIPickerView Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.subsamplingPickerData count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.subsamplingPickerData objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {

}

@end