//
//  DisplayViewController.m
//  JPEG_Compression
//
//  Created by Armour on 2/22/16.
//  Copyright © 2016 SFU. All rights reserved.
//

#import "DisplayViewController.h"
#import "MatConvert.h"

@interface DisplayViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *YImageView;
@property (strong, nonatomic) IBOutlet UIImageView *CbImageView;
@property (strong, nonatomic) IBOutlet UIImageView *CrImageView;
@property (strong, nonatomic) IBOutlet UILabel *YImageSizeLabel;
@property (strong, nonatomic) IBOutlet UILabel *CbImageSizeLabel;
@property (strong, nonatomic) IBOutlet UILabel *CrImageSizeLabel;
@property (strong, nonatomic) IBOutlet UIPickerView *quantizationMatrixPickerView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *quantizationMatrixPickerTopConstraint;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *chooseQuantizationMatrixButton;

@property (strong, nonatomic) NSArray *quantizationMatrixPickerData;
@property (nonatomic) BOOL isChoosingQuantizationMatrix;
@property (nonatomic) CGPoint originalQuantizationMatrixPickerViewCenterPoint;

- (void)initImageView;
- (void)initPickerView;
- (void)initSizeLabel;

@end

@implementation DisplayViewController

#pragma mark - Init Function

- (void)initImageView {
    [self.view layoutIfNeeded];

    if (self.quantizationMatrixChoosedNumber < 0) {
        self.quantizationMatrixChoosedNumber = 0;
    }

    [self.YImageView setImage:[MatConvert UIImageFromCVMat:YImage[self.quantizationMatrixChoosedNumber]]];
    [self.YImageView setBackgroundColor:[UIColor blackColor]];
    [self.YImageView setContentMode:UIViewContentModeScaleAspectFit];

    [self.CbImageView setImage:[MatConvert UIImageFromCVMat:CbImage[self.quantizationMatrixChoosedNumber]]];
    [self.CbImageView setBackgroundColor:[UIColor blackColor]];
    [self.CbImageView setContentMode:UIViewContentModeScaleAspectFit];

    [self.CrImageView setImage:[MatConvert UIImageFromCVMat:CrImage[self.quantizationMatrixChoosedNumber]]];
    [self.CrImageView setBackgroundColor:[UIColor blackColor]];
    [self.CrImageView setContentMode:UIViewContentModeScaleAspectFit];
}

- (void)initPickerView {
    self.quantizationMatrixPickerView.delegate = self;
    self.quantizationMatrixPickerView.dataSource = self;
    self.quantizationMatrixPickerView.backgroundColor = [UIColor whiteColor];
    self.quantizationMatrixPickerView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.quantizationMatrixPickerView.layer.borderWidth = 1;

    self.quantizationMatrixPickerData = [[NSArray alloc] initWithObjects:@"non-uniform quantization", @"low non-uniform quantization", @"high non-uniform quantization", @"constant quantization", @"low constant quantization", @"high constant quantization", nil];

    self.isChoosingQuantizationMatrix = false;

    self.originalQuantizationMatrixPickerViewCenterPoint = self.quantizationMatrixPickerView.center;

    [self.quantizationMatrixPickerView selectRow:self.quantizationMatrixChoosedNumber inComponent:0 animated:YES];
    [self.chooseQuantizationMatrixButton setTitle: [self.quantizationMatrixPickerData objectAtIndex:self.quantizationMatrixChoosedNumber]];
}

- (void)initSizeLabel {
    [self.YImageSizeLabel setText:[NSString stringWithFormat:@"  W:%d  H:%d",
                                   (int)[self.YImageView image].size.width, (int)[self.YImageView image].size.height]];
    [self.CbImageSizeLabel setText:[NSString stringWithFormat:@"  W:%d  H:%d",
                                   (int)[self.CbImageView image].size.width, (int)[self.CbImageView image].size.height]];
    [self.CrImageSizeLabel setText:[NSString stringWithFormat:@"  W:%d  H:%d",
                                   (int)[self.CrImageView image].size.width, (int)[self.CrImageView image].size.height]];
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initImageView];
    [self initPickerView];
    [self initSizeLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Tap Gesture Event

- (IBAction)TapGestureEvent:(UITapGestureRecognizer *)sender {
    if (self.isChoosingQuantizationMatrix) {
        self.isChoosingQuantizationMatrix = false;
        self.quantizationMatrixPickerTopConstraint.constant += [self.quantizationMatrixPickerView frame].size.height;
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options:UIViewAnimationCurveEaseOut
                         animations:^{
                             [self.view layoutIfNeeded];
                         } completion:^(BOOL finished) {
                         }];
    }
}

#pragma mark - Button Click Event

- (IBAction)chooseQuantizationMatrix:(UIBarButtonItem *)sender {
    if (!self.isChoosingQuantizationMatrix) {
        self.isChoosingQuantizationMatrix = true;
        self.quantizationMatrixPickerTopConstraint.constant -= [self.quantizationMatrixPickerView frame].size.height;
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options:UIViewAnimationCurveEaseIn
                         animations:^{
                             [self.view layoutIfNeeded];
                         } completion:^(BOOL finished) {
                         }];
    }
}

#pragma mark - UIPickerView Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.quantizationMatrixPickerData count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.quantizationMatrixPickerData objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self.chooseQuantizationMatrixButton setTitle:[self.quantizationMatrixPickerData objectAtIndex:row]];
    self.quantizationMatrixChoosedNumber = row;
    [self.YImageView setImage:[MatConvert UIImageFromCVMat:YImage[self.quantizationMatrixChoosedNumber]]];
    [self.CbImageView setImage:[MatConvert UIImageFromCVMat:CbImage[self.quantizationMatrixChoosedNumber]]];
    [self.CrImageView setImage:[MatConvert UIImageFromCVMat:CrImage[self.quantizationMatrixChoosedNumber]]];
}

@end
