//
//  DCTViewController.m
//  JPEG_Compression
//
//  Created by Armour on 2/21/16.
//  Copyright © 2016 SFU. All rights reserved.
//

#import "DCTViewController.h"
#import "DisplayViewController.h"
#import "MatConvert.h"

#define PI 3.1415926535
#define DEFAULT_PICKERVIEW_OPTION "Choose quantization matrix"

#define QUANTIZATION_MATRIX_0 self.nonUniformQuantizationMatrix
#define QUANTIZATION_MATRIX_1 self.lowNonUniformQuantizationMatrix
#define QUANTIZATION_MATRIX_2 self.highNonUniformQuantizationMatrix
#define QUANTIZATION_MATRIX_3 self.constantQuantizationMatrix
#define QUANTIZATION_MATRIX_4 self.lowConstantQuantizationMatrix
#define QUANTIZATION_MATRIX_5 self.highConstantQuantizationMatrix

#define DCT_CELL        @"DCTCell"
#define QUANTIZED_CELL  @"QuantizedCell"
#define QUANTMAT_CELL   @"QuantizationMatrixCell"

@interface DCTViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *channelYImageView;
@property (strong, nonatomic) IBOutlet UIImageView *channelCbImageView;
@property (strong, nonatomic) IBOutlet UIImageView *channelCrImageView;
@property (strong, nonatomic) IBOutlet UIView *channelYUIView;
@property (strong, nonatomic) IBOutlet UIView *channelCbUIView;
@property (strong, nonatomic) IBOutlet UIView *channelCrUIView;
@property (strong, nonatomic) IBOutlet UIView *DCTUIView;
@property (strong, nonatomic) IBOutlet UIView *QuantizedUIView;
@property (strong, nonatomic) IBOutlet UIView *QuantizationMatrixUIView;
@property (strong, nonatomic) IBOutlet UIPickerView *quantizationMatrixPickerView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *quantizationMatrixPickerTopConstraint;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *chooseQuantizationMatrixButton;
@property (strong, nonatomic) IBOutlet UILabel *YImageSizeLabel;
@property (strong, nonatomic) IBOutlet UILabel *CbImageSizeLabel;
@property (strong, nonatomic) IBOutlet UILabel *CrImageSizeLabel;

@property (strong, nonatomic) NSArray *quantizationMatrixPickerData;
@property (nonatomic) BOOL isChoosingQuantizationMatrix;
@property (nonatomic) CGPoint originalQuantizationMatrixPickerViewCenterPoint;
@property (nonatomic) NSInteger quantizationMatrixNumber;

@property (nonatomic) cv::Mat nonUniformQuantizationMatrix;
@property (nonatomic) cv::Mat lowNonUniformQuantizationMatrix;
@property (nonatomic) cv::Mat highNonUniformQuantizationMatrix;
@property (nonatomic) cv::Mat constantQuantizationMatrix;
@property (nonatomic) cv::Mat lowConstantQuantizationMatrix;
@property (nonatomic) cv::Mat highConstantQuantizationMatrix;
@property (nonatomic) cv::Mat DCT8x8Matrix;
@property (nonatomic) cv::Mat YDCTMatrix;
@property (nonatomic) cv::Mat CbDCTMatrix;
@property (nonatomic) cv::Mat CrDCTMatrix;
@property (nonatomic) cv::Mat YQuantizedMatrix;
@property (nonatomic) cv::Mat CbQuantizedMatrix;
@property (nonatomic) cv::Mat CrQuantizedMatrix;
@property (nonatomic) cv::Mat YIDCTMatrix;
@property (nonatomic) cv::Mat CbIDCTMatrix;
@property (nonatomic) cv::Mat CrIDCTMatrix;

- (void)initImageView;
- (void)initPickerView;
- (void)initCollectionView;
- (void)initSizeLabel;
- (void)initDCTMatrix;
- (void)initQuantizationMatrix;
- (void)clipTo8nx8nMatrix;
- (void)runDCT;
- (void)runQuantization;
- (void)runInverseQuantization;
- (void)runInverseDCT;
//- (CGRect)calculateTheRectOfImageInUIImageView:(UIImageView *)imageView;

@end


@implementation DCTViewController

#pragma mark - Init & Update Functions

- (void)initImageView {
    [self.view layoutIfNeeded];

    [self.channelYImageView setImage:[MatConvert UIImageFromCVMat:self.YImage]];
    [self.channelYImageView setBackgroundColor:[UIColor blackColor]];
    [self.channelYImageView setContentMode:UIViewContentModeScaleAspectFit];

    [self.channelCbImageView setImage:[MatConvert UIImageFromCVMat:self.CbImage]];
    [self.channelCbImageView setBackgroundColor:[UIColor blackColor]];
    [self.channelCbImageView setContentMode:UIViewContentModeScaleAspectFit];

    [self.channelCrImageView setImage:[MatConvert UIImageFromCVMat:self.CrImage]];
    [self.channelCrImageView setBackgroundColor:[UIColor blackColor]];
    [self.channelCrImageView setContentMode:UIViewContentModeScaleAspectFit];
}

- (void)initPickerView {
    self.quantizationMatrixPickerView.delegate = self;
    self.quantizationMatrixPickerView.dataSource = self;
    self.quantizationMatrixPickerView.backgroundColor = [UIColor whiteColor];

    self.quantizationMatrixPickerData = [[NSArray alloc] initWithObjects:@DEFAULT_PICKERVIEW_OPTION, @"non-uniform quantization", @"low non-uniform quantization", @"high non-uniform quantization", @"constant quantization", @"low constant quantization", @"high constant quantization", nil];

    self.isChoosingQuantizationMatrix = false;
    self.quantizationMatrixNumber = -1;

    self.originalQuantizationMatrixPickerViewCenterPoint = self.quantizationMatrixPickerView.center;
}

- (void)initCollectionView {
    [self.view layoutIfNeeded];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];

    CGRect rectDCT = [self.DCTUIView bounds];
    UICollectionView *DCTCollectionView = [[UICollectionView alloc] initWithFrame:rectDCT collectionViewLayout:layout];
    DCTCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [DCTCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:DCT_CELL];
    DCTCollectionView.tag = 1;
    DCTCollectionView.delegate = self;
    DCTCollectionView.dataSource = self;
    DCTCollectionView.scrollEnabled = false;
    [DCTCollectionView setBackgroundColor:[UIColor clearColor]];

    CGRect rectQuantized = [self.QuantizedUIView bounds];
    UICollectionView *QuantizedCollectionView = [[UICollectionView alloc] initWithFrame:rectQuantized collectionViewLayout:layout];
    QuantizedCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [QuantizedCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:QUANTIZED_CELL];
    QuantizedCollectionView.tag = 2;
    QuantizedCollectionView.delegate = self;
    QuantizedCollectionView.dataSource = self;
    QuantizedCollectionView.scrollEnabled = false;
    [QuantizedCollectionView setBackgroundColor:[UIColor clearColor]];

    CGRect rectQuantizationMatrix = [self.QuantizationMatrixUIView bounds];
    UICollectionView *QuantizationMatrixCollectionView = [[UICollectionView alloc] initWithFrame:rectQuantizationMatrix collectionViewLayout:layout];
    QuantizationMatrixCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [QuantizationMatrixCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:QUANTMAT_CELL];
    QuantizationMatrixCollectionView.tag = 3;
    QuantizationMatrixCollectionView.delegate = self;
    QuantizationMatrixCollectionView.dataSource = self;
    QuantizationMatrixCollectionView.scrollEnabled = false;
    [QuantizationMatrixCollectionView setBackgroundColor:[UIColor clearColor]];

    [self.DCTUIView addSubview:DCTCollectionView];
    [self.QuantizedUIView addSubview:QuantizedCollectionView];
    [self.QuantizationMatrixUIView addSubview:QuantizationMatrixCollectionView];
}

- (void)initSizeLabel {
    [self.YImageSizeLabel setText:[NSString stringWithFormat:@"  W:%d  H:%d",
                                   (int)[self.channelYImageView image].size.width, (int)[self.channelYImageView image].size.height]];
    [self.CbImageSizeLabel setText:[NSString stringWithFormat:@"  W:%d  H:%d",
                                    (int)[self.channelCbImageView image].size.width, (int)[self.channelCbImageView image].size.height]];
    [self.CrImageSizeLabel setText:[NSString stringWithFormat:@"  W:%d  H:%d",
                                    (int)[self.channelCrImageView image].size.width, (int)[self.channelCrImageView image].size.height]];
}

- (void)initDCTMatrix {
    self.DCT8x8Matrix = cv::Mat(8, 8, CV_32F);
    for (int i = 0; i < 8; i++) {
        for (int j = 0; j < 8; j++) {
            if (i == 0) {
                self.DCT8x8Matrix.at<float>(i, j) = 1.0 / sqrt(8);
            } else {
                self.DCT8x8Matrix.at<float>(i, j) = 0.5 * cos(((2 * j + 1) * i * PI) / 16);
            }
        }
    }
}

- (void)initQuantizationMatrix {
    float data[8][8] = {{16, 11, 10, 16, 24, 40, 51, 61},
                        {12, 12, 14, 19, 26, 58, 60, 55},
                        {14, 13, 16, 24, 40, 57, 69, 56},
                        {14, 17, 22, 29, 51, 87, 80, 62},
                        {18, 22, 37, 56, 68, 109, 103, 77},
                        {24, 35, 55, 64, 81, 104, 113, 92},
                        {49, 64, 78, 87, 103, 121, 120, 101},
                        {72, 92, 95, 98, 112, 100, 103, 99}};

    self.nonUniformQuantizationMatrix = cv::Mat(8, 8, CV_32S);
    self.lowNonUniformQuantizationMatrix = cv::Mat(8, 8, CV_32S);
    self.highNonUniformQuantizationMatrix = cv::Mat(8, 8, CV_32S);
    self.constantQuantizationMatrix = cv::Mat(8, 8, CV_32S);
    self.lowConstantQuantizationMatrix = cv::Mat(8, 8, CV_32S);
    self.highConstantQuantizationMatrix = cv::Mat(8, 8, CV_32S);

    for (int i = 0; i < 8; i++) {
        for (int j = 0; j < 8; j++) {
            self.nonUniformQuantizationMatrix.at<int>(i, j) = data[i][j];
            self.lowNonUniformQuantizationMatrix.at<int>(i, j) = data[i][j];
            self.highNonUniformQuantizationMatrix.at<int>(i, j) = data[i][j];
            self.constantQuantizationMatrix.at<int>(i, j) = data[i][j];
            self.lowConstantQuantizationMatrix.at<int>(i, j) = data[i][j];
            self.highConstantQuantizationMatrix.at<int>(i, j) = data[i][j];
        }
    }
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self clipTo8nx8nMatrix];
    [self initImageView];
    [self initPickerView];
    [self initCollectionView];
    [self initSizeLabel];
    [self initDCTMatrix];
    [self initQuantizationMatrix];
    [self runDCT];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Matrix Formation

- (cv::Mat)clipWithSource:(cv::Mat)image {
    cv::Size size = image.size();
    int newWidth = size.width / 8 * 8;
    int newHeight = size.height / 8 * 8;
    cv::Mat tmpMat = image.clone();
    image = cv::Mat(newHeight, newWidth, CV_8U);
    for (int i = 0; i < newHeight; i++) {
        for (int j = 0; j < newWidth; j++) {
            image.at<uchar>(i, j) = tmpMat.at<uchar>(i, j);
        }
    }
    return image;
}

- (void)clipTo8nx8nMatrix {
    self.YImage = [self clipWithSource:self.YImage];
    self.CbImage = [self clipWithSource:self.CbImage];
    self.CrImage = [self clipWithSource:self.CrImage];
}

#pragma mark - DCT

- (cv::Mat)DCT8x8WithSource:(const cv::Mat &)src {
    int width = src.size().width / 8;
    int height = src.size().height / 8;

    cv::Mat dest = cv::Mat(height * 8, width * 8, CV_32S);

    for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
            cv::Mat tmpMat = cv::Mat(8, 8, CV_32F);
            cv::Mat tmpDCTMat = cv::Mat(8, 8, CV_32F);
            for (int mi = 0; mi < 8; mi++)
                for (int mj = 0; mj < 8; mj++)
                    tmpMat.at<float>(mi, mj) = (float)src.at<uchar>(i * 8 + mi, j * 8 + mj);

            tmpDCTMat = self.DCT8x8Matrix * tmpMat * self.DCT8x8Matrix.t();

            for (int mi = 0; mi < 8; mi++)
                for (int mj = 0; mj < 8; mj++)
                    dest.at<int>(i * 8 + mi, j * 8 + mj) = (int)tmpDCTMat.at<float>(mi, mj);
        }
    }
    return dest;
}

- (void)runDCT {
    self.YDCTMatrix = [self DCT8x8WithSource:self.YImage];
    self.CbDCTMatrix = [self DCT8x8WithSource:self.CbImage];
    self.CrDCTMatrix = [self DCT8x8WithSource:self.CrImage];
}

#pragma mark - Inverse DCT

- (void)runInverseDCT {

}

#pragma mark - Quantization

- (cv::Mat)QuantizationWithSource:(const cv::Mat&)src QuantizationMatrix:(NSInteger)number {
    int width = src.size().width;
    int height = src.size().height;

    cv::Mat dest = cv::Mat(height, width, CV_32S);
    cv::Mat tmpMat = cv::Mat(height, width, CV_32S);
    for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
            switch (number) {
                case 0:
                    tmpMat.at<int>(i, j) = QUANTIZATION_MATRIX_0.at<int>(i / 8, j / 8);
                    break;
                case 1:
                    tmpMat.at<int>(i, j) = QUANTIZATION_MATRIX_1.at<int>(i / 8, j / 8);
                    break;
                case 2:
                    tmpMat.at<int>(i, j) = QUANTIZATION_MATRIX_2.at<int>(i / 8, j / 8);
                    break;
                case 3:
                    tmpMat.at<int>(i, j) = QUANTIZATION_MATRIX_3.at<int>(i / 8, j / 8);
                    break;
                case 4:
                    tmpMat.at<int>(i, j) = QUANTIZATION_MATRIX_4.at<int>(i / 8, j / 8);
                    break;
                case 5:
                    tmpMat.at<int>(i, j) = QUANTIZATION_MATRIX_5.at<int>(i / 8, j / 8);
                    break;
                default:
                    break;
            }
        }
    }
    cv::divide(src, tmpMat, dest);
    return dest;
}

- (void)runQuantization {
    self.YQuantizedMatrix = [self QuantizationWithSource:self.YDCTMatrix
                                      QuantizationMatrix:self.quantizationMatrixNumber];
    self.CbQuantizedMatrix = [self QuantizationWithSource:self.CbDCTMatrix
                                       QuantizationMatrix:self.quantizationMatrixNumber];
    self.CrQuantizedMatrix = [self QuantizationWithSource:self.CrDCTMatrix
                                       QuantizationMatrix:self.quantizationMatrixNumber];
}

#pragma mark - Inverse Quantization

- (void)runInverseQuantization {

}

#pragma mark - Imageview Image Rect
/*
- (CGRect)calculateTheRectOfImageInUIImageView:(UIImageView *)imgView {
    CGSize imgViewSize = imgView.frame.size;                    // Size of UIImageView
    CGSize imgSize = imgView.image.size;                        // Size of the image, currently displayed

    CGFloat scaleW = imgViewSize.width / imgSize.width;         // Calculate the aspect
    CGFloat scaleH = imgViewSize.height / imgSize.height;
    CGFloat aspect = fmin(scaleW, scaleH);

    CGRect imageRect = CGRectMake(0, 0, imgSize.width *= aspect, imgSize.height *= aspect);

    imageRect.origin.x += (imgViewSize.width - imageRect.size.width) / 2;    // Center image
    imageRect.origin.y += (imgViewSize.height - imageRect.size.height) / 2;

    return imageRect;
}*/

#pragma mark - Button Click Event

- (IBAction)chooseSubsampling:(UIBarButtonItem *)sender {
    if (!self.isChoosingQuantizationMatrix) {
        self.isChoosingQuantizationMatrix = true;
        self.quantizationMatrixPickerTopConstraint.constant -= [self.quantizationMatrixPickerView frame].size.height;
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options:UIViewAnimationTransitionNone
                         animations:^{
                             [self.view layoutIfNeeded];
                         } completion:^(BOOL finished) {
                         }];
    }
}

- (IBAction)seeQuantizedResult:(UIButton *)sender {
    if (self.quantizationMatrixNumber != -1) {
        [self performSegueWithIdentifier:@"segueToQuantizedResult" sender:self];
    }
}

- (IBAction)seeIDCTResult:(UIButton *)sender {
    if (self.quantizationMatrixNumber != -1) {
        [self performSegueWithIdentifier:@"segueToIDCTResult" sender:self];
    }
}

#pragma mark - Tap Gesture Event

- (IBAction)TapGestureEvent:(UITapGestureRecognizer *)sender {
    if (self.isChoosingQuantizationMatrix) {
        self.isChoosingQuantizationMatrix = false;
        self.quantizationMatrixPickerTopConstraint.constant += [self.quantizationMatrixPickerView frame].size.height;
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options:UIViewAnimationTransitionNone
                         animations:^{
                             [self.view layoutIfNeeded];
                         } completion:^(BOOL finished) {
                         }];
    }
}

#pragma mark - Prepare Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"segueToDCTResult"]) {
        DisplayViewController *destViewController = [segue destinationViewController];
        [destViewController setYImage:self.YDCTMatrix];
        [destViewController setCbImage:self.CbDCTMatrix];
        [destViewController setCrImage:self.CrDCTMatrix];
    } else if ([[segue identifier] isEqualToString:@"segueToQuantizedResult"]) {
        DisplayViewController *destViewController = [segue destinationViewController];
        [destViewController setYImage:self.YQuantizedMatrix];
        [destViewController setCbImage:self.CbQuantizedMatrix];
        [destViewController setCrImage:self.CrQuantizedMatrix];
    } else if ([[segue identifier] isEqualToString:@"segueToIDCTResult"]) {
        DisplayViewController *destViewController = [segue destinationViewController];
        [destViewController setYImage:self.YIDCTMatrix];
        [destViewController setCbImage:self.CbIDCTMatrix];
        [destViewController setCrImage:self.CrIDCTMatrix];
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
    self.quantizationMatrixNumber = row - 1;
    if (self.quantizationMatrixNumber != -1) {
        [self runQuantization];
        [self runInverseQuantization];
        [self runInverseDCT];
    }
}

#pragma mark - UICollectionView Delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 8 * 8;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell;
    if (collectionView.tag == 1) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:DCT_CELL forIndexPath:indexPath];
    } else if (collectionView.tag == 2) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:QUANTIZED_CELL forIndexPath:indexPath];
    } else if (collectionView.tag == 3) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:QUANTMAT_CELL forIndexPath:indexPath];
    }
    if (!cell) {
        cell = [[UICollectionViewCell alloc] init];
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    UILabel *numberLabel = [[UILabel alloc] initWithFrame:cell.bounds];
    [numberLabel setTextAlignment:NSTextAlignmentCenter];
    [numberLabel setText:@"?"];
    [numberLabel setFont:[UIFont systemFontOfSize:5]];
    [cell addSubview:numberLabel];
    return cell;
}

#pragma mark - UICollectionViewLayout Delegate

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    float width = [self.DCTUIView bounds].size.width / 8.0;
    float height = [self.DCTUIView bounds].size.height / 8.0;
    return CGSizeMake(width, height); //14,10
}

#pragma mark - Hightlight Rect

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