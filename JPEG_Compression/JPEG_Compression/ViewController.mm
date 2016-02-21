//
//  ViewController.m
//  JPEG_Compression
//
//  Created by Armour on 2/19/16.
//  Copyright © 2016 SFU. All rights reserved.
//

#import "ViewController.h"
#import "ChangeColorViewController.h"

#import <opencv2/opencv.hpp>
#import <MobileCoreServices/MobileCoreServices.h>

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UIBarButtonItem *addImageButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *takePhotoButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *beginCompressionButton;
@property (strong, nonatomic) IBOutlet UIToolbar *toolBar;

@property (strong, nonatomic) UIImagePickerController *imagePickerController;
@property (strong, nonatomic) UIImage *capturedImage;

@end


@implementation ViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // If there is not a camera on this device, don't show the camera button.
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSMutableArray *toolbarItems = [[self.toolBar items] mutableCopy];
        [toolbarItems removeObjectAtIndex:4];
        [self.toolBar setItems:toolbarItems animated:NO];
    }

    [self.mainPageImageView setImage:NULL];
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Event

- (IBAction)addImage:(UIBarButtonItem *)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        self.imagePickerController.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
        self.imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
        self.imagePickerController.allowsEditing = true;
        self.imagePickerController.modalPresentationStyle = UIModalPresentationOverFullScreen;
        self.imagePickerController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:self.imagePickerController animated:YES completion:nil];
    }
}

- (IBAction)takePhoto:(UIBarButtonItem *)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.imagePickerController.sourceType =  UIImagePickerControllerSourceTypeCamera;
        self.imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
        self.imagePickerController.allowsEditing = true;
        self.imagePickerController.modalPresentationStyle = UIModalPresentationOverFullScreen;
        self.imagePickerController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:self.imagePickerController animated:YES completion:nil];
    }
}

- (IBAction)beginCompression:(UIBarButtonItem *)sender {
    if ([self.mainPageImageView image] != NULL) {
        [self performSegueWithIdentifier:@"segueToChangeColor" sender:self];
    }
}

#pragma mark - UIImagePickerController Delegate

// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    [self.mainPageImageView setBackgroundColor:[UIColor blackColor]];
    [self.mainPageImageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.mainPageImageView setImage:image];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Prepare Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"segueToChangeColor"]) {
        ChangeColorViewController *destViewController = [segue destinationViewController];
        [destViewController setOriginalImage:[self.mainPageImageView image]];
    }
}

@end
