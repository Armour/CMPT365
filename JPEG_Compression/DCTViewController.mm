//
//  DCTViewController.m
//  JPEG_Compression
//
//  Created by Armour on 2/21/16.
//  Copyright © 2016 SFU. All rights reserved.
//

#import "DCTViewController.h"
#import "MatConvert.h"

#define DEFAULT_PICKERVIEW_OPTION "Choose quantization matrix"
#define PI 3.1415926535
#define QUANTIZATION_MATRIX_0 self.nonUniformQuantizationMatrix
#define QUANTIZATION_MATRIX_1 self.lowNonUniformQuantizationMatrix
#define QUANTIZATION_MATRIX_2 self.highNonUniformQuantizationMatrix
#define QUANTIZATION_MATRIX_3 self.constantQuantizationMatrix
#define QUANTIZATION_MATRIX_4 self.lowConstantQuantizationMatrix
#define QUANTIZATION_MATRIX_5 self.highConstantQuantizationMatrix

@interface DCTViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *channelYImageView;
@property (strong, nonatomic) IBOutlet UIImageView *channelCbImageView;
@property (strong, nonatomic) IBOutlet UIImageView *channelCrImageView;
@property (strong, nonatomic) IBOutlet UIView *channelYUIView;
@property (strong, nonatomic) IBOutlet UIView *channelCbUIView;
@property (strong, nonatomic) IBOutlet UIView *channelCrUIView;
@property (strong, nonatomic) IBOutlet UIView *channelYDCTUIView;
@property (strong, nonatomic) IBOutlet UIView *channelYQuantizedUIView;
@property (strong, nonatomic) IBOutlet UIView *channelCbDCTUIView;
@property (strong, nonatomic) IBOutlet UIView *channelCbQuantizedUIView;
@property (strong, nonatomic) IBOutlet UIView *channelCrDCTUIView;
@property (strong, nonatomic) IBOutlet UIView *channelCrQuantizedUIView;
@property (strong, nonatomic) IBOutlet UIPickerView *quantizationMatrixPickerView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *quantizationMatrixPickerTopConstraint;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *chooseQuantizationMatrixButton;

@property (strong, nonatomic) NSArray *quantizationMatrixPickerData;
@property (nonatomic) BOOL isChoosingQuantizationMatrix;
@property (nonatomic) CGPoint originalQuantizationMatrixPickerViewCenterPoint;
@property (nonatomic) NSUInteger quantizationMatrixNumber;

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

- (void)initImageView;
- (void)initPickerView;
- (void)initCollectionView;
- (void)initDCTMatrix;
- (void)initQuantizationMatrix;
- (void)changeTo8x8Matrix;
- (void)runDCT;
- (void)runQuantization;
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

    self.originalQuantizationMatrixPickerViewCenterPoint = self.quantizationMatrixPickerView.center;
}

- (void)initCollectionView {
    [self.view layoutIfNeeded];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];

    CGRect rectYDCT = [self.channelYDCTUIView bounds];
    UICollectionView *YDCTCollectionView = [[UICollectionView alloc] initWithFrame:rectYDCT collectionViewLayout:layout];
    YDCTCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [YDCTCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"YDCTCell"];
    YDCTCollectionView.tag = 1;
    YDCTCollectionView.delegate = self;
    YDCTCollectionView.dataSource = self;

    CGRect rectCbDCT = [self.channelCbDCTUIView bounds];
    UICollectionView *CbDCTCollectionView = [[UICollectionView alloc] initWithFrame:rectCbDCT collectionViewLayout:layout];
    CbDCTCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [CbDCTCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"CbDCTCell"];
    CbDCTCollectionView.tag = 2;
    CbDCTCollectionView.delegate = self;
    CbDCTCollectionView.dataSource = self;

    CGRect rectCrDCT = [self.channelCrDCTUIView bounds];
    UICollectionView *CrDCTCollectionView = [[UICollectionView alloc] initWithFrame:rectCrDCT collectionViewLayout:layout];
    CrDCTCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [CrDCTCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"CrDCTCell"];
    CrDCTCollectionView.tag = 3;
    CrDCTCollectionView.delegate = self;
    CrDCTCollectionView.dataSource = self;

    [self.channelYDCTUIView addSubview:YDCTCollectionView];
    [self.channelCbDCTUIView addSubview:CbDCTCollectionView];
    [self.channelCrDCTUIView addSubview:CrDCTCollectionView];
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
    for (int i = 0; i < 8; i++) {
        for (int j = 0; j < 8; j++) {
            self.nonUniformQuantizationMatrix.at<int>(i, j) = data[i][j];
        }
    }
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self changeTo8x8Matrix];
    [self initImageView];
    [self initPickerView];
    [self initCollectionView];
    [self initDCTMatrix];
    [self initQuantizationMatrix];
    [self.channelYDCTUIView setBackgroundColor:[UIColor redColor]];
    [self.channelYQuantizedUIView setBackgroundColor:[UIColor blueColor]];
    [self.channelCbDCTUIView setBackgroundColor:[UIColor redColor]];
    [self.channelCbQuantizedUIView setBackgroundColor:[UIColor blueColor]];
    [self.channelCrDCTUIView setBackgroundColor:[UIColor redColor]];
    [self.channelCrQuantizedUIView setBackgroundColor:[UIColor blueColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Matrix Formation

- (void)changeTo8x8Matrix {
    cv::Size size = self.YImage.size();
    int newWidth = size.width / 8 * 8;
    int newHeight = size.height / 8 * 8;
    self.YImage = self.YImage.colRange(0, newWidth).rowRange(0, newHeight);

    size = self.CbImage.size();
    newWidth = size.width / 8 * 8;
    newHeight = size.height / 8 * 8;
    self.CbImage = self.CbImage.colRange(0, newWidth).rowRange(0, newHeight);

    size = self.CrImage.size();
    newWidth = size.width / 8 * 8;
    newHeight = size.height / 8 * 8;
    self.CrImage = self.CrImage.colRange(0, newWidth).rowRange(0, newHeight);
}

#pragma mark - DCT

- (void)DCT8x8WithSource:(cv::Mat)src Destination:(cv::Mat)dest {
    int width = src.size().width / 8;
    int height = src.size().height / 8;

    dest = cv::Mat(width * 8, height * 8, CV_32S);

    for (int i = 0; i < width; i++) {
        for (int j = 0; j < height; j++) {
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
}

- (void)runDCT {
    [self DCT8x8WithSource:self.YImage Destination:self.YDCTMatrix];
    [self DCT8x8WithSource:self.CbImage Destination:self.CbDCTMatrix];
    [self DCT8x8WithSource:self.CrImage Destination:self.CrDCTMatrix];
}

#pragma mark - Quantization

- (void)QuantizationWithSource:(cv::Mat)src Destination:(cv::Mat)dest QuantizationMatrix:(NSUInteger)number {
    int width = src.size().width;
    int height = src.size().height;

    dest = cv::Mat(width, height, CV_32S);
    cv::Mat tmpMat = cv::Mat(width, height, CV_32S);
    for (int i = 0; i < width; i++) {
        for (int j = 0; j < height; j++) {
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
}

- (void)runQuantization {
    [self QuantizationWithSource:self.YDCTMatrix
                     Destination:self.YQuantizedMatrix
              QuantizationMatrix:self.quantizationMatrixNumber];
    [self QuantizationWithSource:self.CbDCTMatrix
                     Destination:self.CbQuantizedMatrix
              QuantizationMatrix:self.quantizationMatrixNumber];
    [self QuantizationWithSource:self.CrDCTMatrix
                     Destination:self.CrQuantizedMatrix
              QuantizationMatrix:self.quantizationMatrixNumber];
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
    if ([[segue identifier] isEqualToString:@"segueToDCT"]) {
        DCTViewController *destViewController = [segue destinationViewController];
        [destViewController setYImage:self.YImage];
        if ([[self.chooseQuantizationMatrixButton title] isEqualToString:@"4:4:4"]) {
        }
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
    if (row != 0) {
        [self runDCT];
        [self runQuantization];
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
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"YDCTCell" forIndexPath:indexPath];
    } else if (collectionView.tag == 2) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CbDCTCell" forIndexPath:indexPath];
    } else if (collectionView.tag == 3) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CrDCTCell" forIndexPath:indexPath];
    }
    if (!cell) {
        cell = [[UICollectionViewCell alloc] init];
    }
    [cell setBackgroundColor:[UIColor lightGrayColor]];
    UILabel *numberLabel = [[UILabel alloc] initWithFrame:cell.bounds];
    [numberLabel setTextAlignment:NSTextAlignmentCenter];
    [numberLabel setText:@"233"];
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
    float width = [self.channelYDCTUIView bounds].size.width / 8;
    float height = [self.channelYDCTUIView bounds].size.height / 8;
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