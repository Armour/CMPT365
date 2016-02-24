//
//  FinalResultViewController.m
//  JPEG_Compression
//
//  Created by Armour on 2/22/16.
//  Copyright © 2016 SFU. All rights reserved.
//

#import "FinalResultViewController.h"
#import "MatConvert.h"

@interface FinalResultViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *originalImageView;
@property (strong, nonatomic) IBOutlet UIImageView *finalImageView;
@property (strong, nonatomic) IBOutlet UIPickerView *quantizationMatrixPickerView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *quantizationMatrixPickerTopToolBarConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *quantizationMatrixPickerTopImageViewConstraint;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *chooseQuantizationMatrixButton;
@property (strong, nonatomic) IBOutlet UIToolbar *toolBar;

@property (strong, nonatomic) NSArray *quantizationMatrixPickerData;
@property (nonatomic) BOOL isChoosingQuantizationMatrix;
@property (nonatomic) CGPoint originalQuantizationMatrixPickerViewCenterPoint;

- (void)initImageView;
- (void)initPickerView;

@end


@implementation FinalResultViewController

#pragma mark - Init Function

- (void)initImageView {
    [self.view layoutIfNeeded];

    [self.originalImageView setImage:[MatConvert UIImageFromCVMat:self.originalImage]];
    [self.originalImageView setBackgroundColor:[UIColor blackColor]];
    [self.originalImageView setContentMode:UIViewContentModeScaleAspectFit];

    [self.finalImageView setImage:[MatConvert UIImageFromCVMat:finalImage[self.quantizationMatrixChoosedNumber]]];
    [self.finalImageView setBackgroundColor:[UIColor blackColor]];
    [self.finalImageView setContentMode:UIViewContentModeScaleAspectFit];
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

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initImageView];
    [self initPickerView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Tap Gesture Event

- (IBAction)TapGestureEvent:(UITapGestureRecognizer *)sender {
    if (self.isChoosingQuantizationMatrix) {
        self.isChoosingQuantizationMatrix = false;
        self.quantizationMatrixPickerTopToolBarConstraint.constant += [self.quantizationMatrixPickerView frame].size.height;
        self.quantizationMatrixPickerTopImageViewConstraint.constant += [self.toolBar frame].size.height;
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
        self.quantizationMatrixPickerTopToolBarConstraint.constant -= [self.quantizationMatrixPickerView frame].size.height;
        self.quantizationMatrixPickerTopImageViewConstraint.constant -= [self.toolBar frame].size.height;
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options:UIViewAnimationCurveEaseIn
                         animations:^{
                             [self.view layoutIfNeeded];
                         } completion:^(BOOL finished) {
                         }];
    }
}

- (IBAction)backToMainPage:(UIBarButtonItem *)sender {
    [self.navigationController popToRootViewControllerAnimated:true];
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
    [self.finalImageView setImage:[MatConvert UIImageFromCVMat:finalImage[self.quantizationMatrixChoosedNumber]]];
}

@end
