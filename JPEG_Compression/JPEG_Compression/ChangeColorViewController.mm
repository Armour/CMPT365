//
//  ChangeColorViewController.m
//  JPEG_Compression
//
//  Created by Armour on 2/20/16.
//  Copyright © 2016 SFU. All rights reserved.
//

#import "ChangeColorViewController.h"
#import "DCTViewController.h"
#import "MatConvert.h"

#include <vector>

#define DEFAULT_PICKERVIEW_OPTION "Choose subsampling method"

@interface ChangeColorViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *channelYImageView;
@property (strong, nonatomic) IBOutlet UIImageView *channelCbImageView;
@property (strong, nonatomic) IBOutlet UIImageView *channelCrImageView;

@property (strong, nonatomic) IBOutlet UIPickerView *chromaSubsamplingPickerView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *chooseSubsamplingButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *chromaSubsamplingPickerViewTopConstraint;

@property (strong, nonatomic) IBOutlet UILabel *YImageSizeLabel;
@property (strong, nonatomic) IBOutlet UILabel *CbImageSizeLabel;
@property (strong, nonatomic) IBOutlet UILabel *CrImageSizeLabel;

@property (nonatomic) cv::Mat RGBImage;
@property (nonatomic) cv::Mat YImage;
@property (nonatomic) cv::Mat CbImage444;
@property (nonatomic) cv::Mat CbImage422;
@property (nonatomic) cv::Mat CbImage420;
@property (nonatomic) cv::Mat CbImage411;
@property (nonatomic) cv::Mat CrImage444;
@property (nonatomic) cv::Mat CrImage422;
@property (nonatomic) cv::Mat CrImage420;
@property (nonatomic) cv::Mat CrImage411;

@property (nonatomic) BOOL isChoosingSubsamplingMethod;
@property (strong, nonatomic) NSArray *subsamplingPickerData;
@property (nonatomic) CGPoint originalSubsamplingPickerViewCenterPoint;

- (void)RGBtoYUV;
- (void)subsampling444;
- (void)subsampling422;
- (void)subsampling411;
- (void)subsampling420;
- (void)updateImageSizeLabel;
- (void)initImageView;
- (void)initPickerView;

@end


@implementation ChangeColorViewController

#pragma mark - Init & Update Functions

- (void)initImageView {
    [self.channelYImageView setImage:[MatConvert UIImageFromCVMat:self.YImage]];
    [self.channelYImageView setBackgroundColor:[UIColor blackColor]];
    [self.channelYImageView setContentMode:UIViewContentModeScaleAspectFit];

    [self.channelCbImageView setImage:[MatConvert UIImageFromCVMat:self.CbImage444]];
    [self.channelCbImageView setBackgroundColor:[UIColor blackColor]];
    [self.channelCbImageView setContentMode:UIViewContentModeScaleAspectFit];

    [self.channelCrImageView setImage:[MatConvert UIImageFromCVMat:self.CrImage444]];
    [self.channelCrImageView setBackgroundColor:[UIColor blackColor]];
    [self.channelCrImageView setContentMode:UIViewContentModeScaleAspectFit];
}

- (void)initPickerView {
    self.chromaSubsamplingPickerView.delegate = self;
    self.chromaSubsamplingPickerView.dataSource = self;
    self.chromaSubsamplingPickerView.backgroundColor = [UIColor whiteColor];

    self.subsamplingPickerData = [[NSArray alloc] initWithObjects:@DEFAULT_PICKERVIEW_OPTION, @"4:4:4", @"4:2:2", @"4:2:0", @"4:1:1", nil];

    self.isChoosingSubsamplingMethod = false;

    self.originalSubsamplingPickerViewCenterPoint = self.chromaSubsamplingPickerView.center;
}

- (void)updateImageSizeLabel {
    [self.YImageSizeLabel setText:[NSString stringWithFormat:@"  W:%d  H:%d",
                                   (int)[self.channelYImageView image].size.width, (int)[self.channelYImageView image].size.height]];
    [self.CbImageSizeLabel setText:[NSString stringWithFormat:@"  W:%d  H:%d",
                                    (int)[self.channelCbImageView image].size.width, (int)[self.channelCbImageView image].size.height]];
    [self.CrImageSizeLabel setText:[NSString stringWithFormat:@"  W:%d  H:%d",
                                    (int)[self.channelCrImageView image].size.width, (int)[self.channelCrImageView image].size.height]];
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self RGBtoYUV];
    [self initImageView];
    [self initPickerView];
    [self updateImageSizeLabel];
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
            float R = (float)RGBChannels[0].at<uchar>(i, j);
            float G = (float)RGBChannels[1].at<uchar>(i, j);
            float B = (float)RGBChannels[2].at<uchar>(i, j);
            YUVChannels[0].at<uchar>(i, j) = (uchar)GET_Y_FROM_RGB;
            YUVChannels[1].at<uchar>(i, j) = (uchar)GET_Cb_FROM_RGB;
            YUVChannels[2].at<uchar>(i, j) = (uchar)GET_Cr_FROM_RGB;
        }
    }

    self.YImage = YUVChannels[0];
    self.CbImage444 = YUVChannels[1];
    self.CrImage444 = YUVChannels[2];
}

#pragma mark - Subsampling Implementation

- (void)subsampling444 {
    [self.channelCbImageView setImage:[MatConvert UIImageFromCVMat:self.CbImage444]];
    [self.channelCrImageView setImage:[MatConvert UIImageFromCVMat:self.CrImage444]];
}

- (void)subsampling422 {
    cv::Size size = self.CbImage444.size();
    int imageWidth = size.width;
    int imageHeight = size.height;

    self.CbImage422 = cv::Mat(imageHeight, imageWidth / 2, CV_8UC1);
    self.CrImage422 = cv::Mat(imageHeight, imageWidth / 2, CV_8UC1);

    for (int i = 0; i < imageHeight; i++) {
        for (int j = 0; j < imageWidth / 2; j++) {
            self.CbImage422.at<uchar>(i, j) = self.CbImage444.at<uchar>(i, j * 2);
            self.CrImage422.at<uchar>(i, j) = self.CrImage444.at<uchar>(i, j * 2);
        }
    }

    [self.channelCbImageView setImage:[MatConvert UIImageFromCVMat:self.CbImage422]];
    [self.channelCrImageView setImage:[MatConvert UIImageFromCVMat:self.CrImage422]];
}

- (void)subsampling411 {
    cv::Size size = self.CbImage444.size();
    int imageWidth = size.width;
    int imageHeight = size.height;

    self.CbImage411 = cv::Mat(imageHeight, imageWidth / 4, CV_8UC1);
    self.CrImage411 = cv::Mat(imageHeight, imageWidth / 4, CV_8UC1);

    for (int i = 0; i < imageHeight; i++) {
        for (int j = 0; j < imageWidth / 4; j++) {
            self.CbImage411.at<uchar>(i, j) = self.CbImage444.at<uchar>(i, j * 4);
            self.CrImage411.at<uchar>(i, j) = self.CrImage444.at<uchar>(i, j * 4);
        }
    }

    [self.channelCbImageView setImage:[MatConvert UIImageFromCVMat:self.CbImage411]];
    [self.channelCrImageView setImage:[MatConvert UIImageFromCVMat:self.CrImage411]];
}

- (void)subsampling420 {
    cv::Size size = self.CbImage444.size();
    int imageWidth = size.width;
    int imageHeight = size.height;

    self.CbImage420 = cv::Mat(imageHeight / 2, imageWidth / 2, CV_8UC1);
    self.CrImage420 = cv::Mat(imageHeight / 2, imageWidth / 2, CV_8UC1);

    for (int i = 0; i < imageHeight / 2; i++) {
        for (int j = 0; j < imageWidth / 2; j++) {
            self.CbImage420.at<uchar>(i, j) = self.CbImage444.at<uchar>(i * 2, j * 2);
            self.CrImage420.at<uchar>(i, j) = self.CrImage444.at<uchar>(i * 2, j * 2);
        }
    }
    
    [self.channelCbImageView setImage:[MatConvert UIImageFromCVMat:self.CbImage420]];
    [self.channelCrImageView setImage:[MatConvert UIImageFromCVMat:self.CrImage420]];
}

#pragma mark - Button Click Event

- (IBAction)chooseSubsampling:(UIBarButtonItem *)sender {
    if (!self.isChoosingSubsamplingMethod) {
        self.isChoosingSubsamplingMethod = true;
        self.chromaSubsamplingPickerViewTopConstraint.constant -= [self.chromaSubsamplingPickerView frame].size.height;
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options:UIViewAnimationCurveEaseIn
                         animations:^{
                             [self.view layoutIfNeeded];
                         } completion:^(BOOL finished) {
                         }];
    }
}

- (IBAction)segueToDCT:(UIBarButtonItem *)sender {
    if (self.isChoosingSubsamplingMethod) {
        [self TapGestureEvent:nil];
        return;
    }
    if ([[self.chooseSubsamplingButton title] isEqualToString:@DEFAULT_PICKERVIEW_OPTION]) {
        [self popAlertWithTitle:@"Emmm..." message:@"You haven't select the subsampling algorithm :("];
    } else {
        [self performSegueWithIdentifier:@"segueToDCT" sender:self];
    }
}

#pragma mark - Tap Gesture Event

- (IBAction)TapGestureEvent:(UITapGestureRecognizer *)sender {
    if (self.isChoosingSubsamplingMethod) {
        self.isChoosingSubsamplingMethod = false;
        self.chromaSubsamplingPickerViewTopConstraint.constant += [self.chromaSubsamplingPickerView frame].size.height;
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options:UIViewAnimationCurveEaseOut
                         animations:^{
                             [self.view layoutIfNeeded];
                         } completion:^(BOOL finished) {
                         }];
    }
}

#pragma mark - Prepare Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"segueToDCT"]) {
        DCTViewController *destViewController = [segue destinationViewController];
        if ([[self.chooseSubsamplingButton title] isEqualToString:@"4:4:4"]) {
            [destViewController setCbImage:self.CbImage444];
            [destViewController setCrImage:self.CrImage444];
        } else if ([[self.chooseSubsamplingButton title] isEqualToString:@"4:2:2"]) {
            [destViewController setCbImage:self.CbImage422];
            [destViewController setCrImage:self.CrImage422];
        } else if ([[self.chooseSubsamplingButton title] isEqualToString:@"4:2:0"]) {
            [destViewController setCbImage:self.CbImage420];
            [destViewController setCrImage:self.CrImage420];
        } else if ([[self.chooseSubsamplingButton title] isEqualToString:@"4:1:1"]) {
            [destViewController setCbImage:self.CbImage411];
            [destViewController setCrImage:self.CrImage411];
        }
        [destViewController setYImage:self.YImage];
        [destViewController setOriginalImage:[MatConvert cvMatFromUIImage:self.originalImage]];
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
    [self.chooseSubsamplingButton setTitle:[self.subsamplingPickerData objectAtIndex:row]];
    switch (row) {
        case 2:
            [self subsampling422];
            break;
        case 3:
            [self subsampling420];
            break;
        case 4:
            [self subsampling411];
            break;
        default:
            [self subsampling444];
            break;
    }
    [self updateImageSizeLabel];
}

#pragma mark - Alert Controller

- (void)popAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];

    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end