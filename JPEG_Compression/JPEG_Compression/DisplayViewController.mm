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

- (void)initImageView;
- (void)initSizeLabel;

@end

@implementation DisplayViewController

#pragma mark - Init Function

- (void)initImageView {
    [self.view layoutIfNeeded];

    [self.YImageView setImage:[MatConvert UIImageFromCVMat:self.YImage]];
    [self.YImageView setBackgroundColor:[UIColor blackColor]];
    [self.YImageView setContentMode:UIViewContentModeScaleAspectFit];

    [self.CbImageView setImage:[MatConvert UIImageFromCVMat:self.CbImage]];
    [self.CbImageView setBackgroundColor:[UIColor blackColor]];
    [self.CbImageView setContentMode:UIViewContentModeScaleAspectFit];

    [self.CrImageView setImage:[MatConvert UIImageFromCVMat:self.CrImage]];
    [self.CrImageView setBackgroundColor:[UIColor blackColor]];
    [self.CrImageView setContentMode:UIViewContentModeScaleAspectFit];
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
    [self initSizeLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
