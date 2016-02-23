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

- (void)initImageView;

@end


@implementation FinalResultViewController

#pragma mark - Init Function

- (void)initImageView {
    [self.view layoutIfNeeded];

    [self.originalImageView setImage:[MatConvert UIImageFromCVMat:self.originalImage]];
    [self.originalImageView setBackgroundColor:[UIColor blackColor]];
    [self.originalImageView setContentMode:UIViewContentModeScaleAspectFit];

    [self.finalImageView setImage:[MatConvert UIImageFromCVMat:self.finalImage]];
    [self.finalImageView setBackgroundColor:[UIColor blackColor]];
    [self.finalImageView setContentMode:UIViewContentModeScaleAspectFit];
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initImageView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Click Event

- (IBAction)backToMainPage:(UIBarButtonItem *)sender {
    [self.navigationController popToRootViewControllerAnimated:true];
}

@end
