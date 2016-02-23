//
//  DCTViewController.m
//  JPEG_Compression
//
//  Created by Armour on 2/21/16.
//  Copyright © 2016 SFU. All rights reserved.
//

#import "DCTViewController.h"
#import "DisplayViewController.h"
#import "FinalResultViewController.h"
#import "MatConvert.h"

#define PI 3.1415926535
#define DEFAULT_PICKERVIEW_OPTION "Choose quantization matrix"

#define DCT_CELL        @"DCTCell"
#define QUANTIZED_CELL  @"QuantizedCell"
#define QUANTMAT_CELL   @"QuantizationMatrixCell"

@interface DCTViewController () {
    cv::Mat YDCTMatrix;
    std::vector<cv::Mat> YQuantizedMatrix;
    std::vector<cv::Mat> YInversedQuantizedMatrix;
    std::vector<cv::Mat> YInversedDCTMatrix;

    cv::Mat CbDCTMatrix;
    std::vector<cv::Mat> CbQuantizedMatrix;
    std::vector<cv::Mat> CbInversedQuantizedMatrix;
    std::vector<cv::Mat> CbInversedDCTMatrix;

    cv::Mat CrDCTMatrix;
    std::vector<cv::Mat> CrQuantizedMatrix;
    std::vector<cv::Mat> CrInversedQuantizedMatrix;
    std::vector<cv::Mat> CrInversedDCTMatrix;

    cv::Mat DCT8x8Matrix;

    std::vector<cv::Mat> quantizationMatrix;

    cv::Mat DCTBlock;
    cv::Mat quantizedBlock;
    cv::Mat quantizationMatrixBlock;
}

@property (strong, nonatomic) IBOutlet UIView *channelYUIView;
@property (strong, nonatomic) IBOutlet UIView *channelCbUIView;
@property (strong, nonatomic) IBOutlet UIView *channelCrUIView;

@property (strong, nonatomic) IBOutlet UIImageView *channelYImageView;
@property (strong, nonatomic) IBOutlet UIImageView *channelCbImageView;
@property (strong, nonatomic) IBOutlet UIImageView *channelCrImageView;

@property (strong, nonatomic) IBOutlet UIView *DCTUIView;
@property (strong, nonatomic) IBOutlet UIView *quantizedUIView;
@property (strong, nonatomic) IBOutlet UIView *quantizationMatrixUIView;

@property (strong, nonatomic) IBOutlet UILabel *YImageSizeLabel;
@property (strong, nonatomic) IBOutlet UILabel *CbImageSizeLabel;
@property (strong, nonatomic) IBOutlet UILabel *CrImageSizeLabel;

@property (strong, nonatomic) IBOutlet UIPickerView *quantizationMatrixPickerView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *chooseQuantizationMatrixButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *quantizationMatrixPickerTopConstraint;

@property (nonatomic) BOOL isChoosingQuantizationMatrix;
@property (nonatomic) NSInteger quantizationMatrixChoosedNumber;
@property (strong, nonatomic) NSArray *quantizationMatrixPickerData;
@property (nonatomic) CGPoint originalQuantizationMatrixPickerViewCenterPoint;
@property (nonatomic) BOOL isTouchedImageView;

- (void)initImageView;
- (void)initPickerView;
- (void)initCollectionView;
- (void)initSizeLabel;
- (void)initDCTMatrix;
- (void)initQuantizationMatrix;
- (void)clipTo8nx8nMatrix;
- (void)runDCT;
- (void)runInverseDCT;
- (void)runQuantization;
- (void)runInverseQuantization;
- (cv::Mat)getFinalImage;
- (CGRect)calculateTheRectOfImageInUIImageView:(UIImageView *)imageView;

@end


@implementation DCTViewController

#pragma mark - Init & Update Functions

- (void)initImageView {
    [self.view layoutIfNeeded];

    UITapGestureRecognizer *tapY = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(YImageTapped:)];
    UITapGestureRecognizer *tapCb = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(CbImageTapped:)];
    UITapGestureRecognizer *tapCr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(CrImageTapped:)];

    tapY.delegate = self;
    tapCb.delegate = self;
    tapCr.delegate = self;

    [self.channelYImageView setImage:[MatConvert UIImageFromCVMat:self.YImage]];
    [self.channelYImageView setBackgroundColor:[UIColor blackColor]];
    [self.channelYImageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.channelYImageView addGestureRecognizer:tapY];
    [self.channelYImageView setUserInteractionEnabled:true];

    [self.channelCbImageView setImage:[MatConvert UIImageFromCVMat:self.CbImage]];
    [self.channelCbImageView setBackgroundColor:[UIColor blackColor]];
    [self.channelCbImageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.channelCbImageView addGestureRecognizer:tapCb];
    [self.channelCbImageView setUserInteractionEnabled:true];

    [self.channelCrImageView setImage:[MatConvert UIImageFromCVMat:self.CrImage]];
    [self.channelCrImageView setBackgroundColor:[UIColor blackColor]];
    [self.channelCrImageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.channelCrImageView addGestureRecognizer:tapCr];
    [self.channelCrImageView setUserInteractionEnabled:true];

    self.isTouchedImageView = false;
}

- (void)initPickerView {
    self.quantizationMatrixPickerView.delegate = self;
    self.quantizationMatrixPickerView.dataSource = self;
    self.quantizationMatrixPickerView.backgroundColor = [UIColor whiteColor];

    self.quantizationMatrixPickerData = [[NSArray alloc] initWithObjects:@DEFAULT_PICKERVIEW_OPTION, @"non-uniform quantization", @"low non-uniform quantization", @"high non-uniform quantization", @"constant quantization", @"low constant quantization", @"high constant quantization", nil];

    self.isChoosingQuantizationMatrix = false;
    self.quantizationMatrixChoosedNumber = -1;

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

    CGRect rectQuantized = [self.quantizedUIView bounds];
    UICollectionView *QuantizedCollectionView = [[UICollectionView alloc] initWithFrame:rectQuantized collectionViewLayout:layout];
    QuantizedCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [QuantizedCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:QUANTIZED_CELL];
    QuantizedCollectionView.tag = 2;
    QuantizedCollectionView.delegate = self;
    QuantizedCollectionView.dataSource = self;
    QuantizedCollectionView.scrollEnabled = false;
    [QuantizedCollectionView setBackgroundColor:[UIColor clearColor]];

    CGRect rectQuantizationMatrix = [self.quantizationMatrixUIView bounds];
    UICollectionView *QuantizationMatrixCollectionView = [[UICollectionView alloc] initWithFrame:rectQuantizationMatrix collectionViewLayout:layout];
    QuantizationMatrixCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [QuantizationMatrixCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:QUANTMAT_CELL];
    QuantizationMatrixCollectionView.tag = 3;
    QuantizationMatrixCollectionView.delegate = self;
    QuantizationMatrixCollectionView.dataSource = self;
    QuantizationMatrixCollectionView.scrollEnabled = false;
    [QuantizationMatrixCollectionView setBackgroundColor:[UIColor clearColor]];

    [self.DCTUIView addSubview:DCTCollectionView];
    [self.quantizedUIView addSubview:QuantizedCollectionView];
    [self.quantizationMatrixUIView addSubview:QuantizationMatrixCollectionView];

    DCTBlock = cv::Mat(8, 8, CV_32S);
    quantizedBlock = cv::Mat(8, 8, CV_32S);
    quantizationMatrixBlock = cv::Mat(8, 8, CV_32S);
}

- (void)initSizeLabel {
    [self.YImageSizeLabel setText:[NSString stringWithFormat:@"  W:%d  H:%d",
                                   (int)[self.channelYImageView image].size.width,
                                   (int)[self.channelYImageView image].size.height]];
    [self.CbImageSizeLabel setText:[NSString stringWithFormat:@"  W:%d  H:%d",
                                    (int)[self.channelCbImageView image].size.width,
                                    (int)[self.channelCbImageView image].size.height]];
    [self.CrImageSizeLabel setText:[NSString stringWithFormat:@"  W:%d  H:%d",
                                    (int)[self.channelCrImageView image].size.width,
                                    (int)[self.channelCrImageView image].size.height]];
}

- (void)initDCTMatrix {
    DCT8x8Matrix = cv::Mat(8, 8, CV_32F);
    for (int i = 0; i < 8; i++) {
        for (int j = 0; j < 8; j++) {
            if (i == 0) {
                DCT8x8Matrix.at<float>(i, j) = 1.0 / sqrt(8);
            } else {
                DCT8x8Matrix.at<float>(i, j) = 0.5 * cos(((2 * j + 1) * i * PI) / 16);
            }
        }
    }
}

- (void)initQuantizationMatrix {
    float nonUniformData[8][8] = {{16, 11, 10, 16, 24, 40, 51, 61},
                                 {12, 12, 14, 19, 26, 58, 60, 55},
                                 {14, 13, 16, 24, 40, 57, 69, 56},
                                 {14, 17, 22, 29, 51, 87, 80, 62},
                                 {18, 22, 37, 56, 68, 109, 103, 77},
                                 {24, 35, 55, 64, 81, 104, 113, 92},
                                 {49, 64, 78, 87, 103, 121, 120, 101},
                                 {72, 92, 95, 98, 112, 100, 103, 99}};

    float lowNonUniformData[8][8] = {{8, 5, 5, 8, 12, 20, 25, 30},
                                    {6, 6, 7, 9, 13, 29, 30, 27},
                                    {7, 6, 8, 12, 20, 28, 34, 28},
                                    {7, 8, 11, 14, 25, 43, 40, 31},
                                    {9, 11, 18, 28, 34, 54, 51, 38},
                                    {12, 17, 27, 32, 40, 52, 56, 46},
                                    {24, 32, 39, 43, 51, 60, 60, 50},
                                    {36, 46, 47, 49, 56, 50, 51, 49}};

    float highNonUniformData[8][8] = {{64, 44, 40, 64, 96, 160, 204, 244},
                                     {48, 48, 56, 76, 104, 232, 240, 220},
                                     {56, 52, 64, 96, 160, 228, 276, 224},
                                     {56, 68, 88, 116, 204, 300, 300, 248},
                                     {72, 88, 148, 224, 272, 300, 300, 300},
                                     {96, 140, 220, 256, 300, 300, 300, 300},
                                     {196, 256, 300, 300, 300, 300, 300, 300},
                                     {288, 300, 300, 300, 300, 300, 300, 300}};

    cv::Mat nonUniformQuantizationMatrix = cv::Mat(8, 8, CV_32S);
    cv::Mat lowNonUniformQuantizationMatrix = cv::Mat(8, 8, CV_32S);
    cv::Mat highNonUniformQuantizationMatrix = cv::Mat(8, 8, CV_32S);
    cv::Mat constantQuantizationMatrix = cv::Mat(8, 8, CV_32S);
    cv::Mat lowConstantQuantizationMatrix = cv::Mat(8, 8, CV_32S);
    cv::Mat highConstantQuantizationMatrix = cv::Mat(8, 8, CV_32S);

    for (int i = 0; i < 8; i++) {
        for (int j = 0; j < 8; j++) {
            nonUniformQuantizationMatrix.at<int>(i, j) = nonUniformData[i][j];
            lowNonUniformQuantizationMatrix.at<int>(i, j) = lowNonUniformData[i][j];
            highNonUniformQuantizationMatrix.at<int>(i, j) = highNonUniformData[i][j];
            constantQuantizationMatrix.at<int>(i, j) = 32;
            lowConstantQuantizationMatrix.at<int>(i, j) = 2;
            highConstantQuantizationMatrix.at<int>(i, j) = 128;
        }
    }

    quantizationMatrix.push_back(nonUniformQuantizationMatrix.clone());
    quantizationMatrix.push_back(lowNonUniformQuantizationMatrix.clone());
    quantizationMatrix.push_back(highNonUniformQuantizationMatrix.clone());
    quantizationMatrix.push_back(constantQuantizationMatrix.clone());
    quantizationMatrix.push_back(lowConstantQuantizationMatrix.clone());
    quantizationMatrix.push_back(highConstantQuantizationMatrix.clone());
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
    [self runQuantization];
    [self runInverseQuantization];
    [self runInverseDCT];
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

            tmpDCTMat = DCT8x8Matrix * tmpMat * DCT8x8Matrix.t();

            for (int mi = 0; mi < 8; mi++)
                for (int mj = 0; mj < 8; mj++)
                    dest.at<int>(i * 8 + mi, j * 8 + mj) = (int)tmpDCTMat.at<float>(mi, mj);
        }
    }
    return dest;
}

- (void)runDCT {
    YDCTMatrix = [self DCT8x8WithSource:self.YImage];
    CbDCTMatrix = [self DCT8x8WithSource:self.CbImage];
    CrDCTMatrix = [self DCT8x8WithSource:self.CrImage];
}

#pragma mark - Inverse DCT

- (cv::Mat)InverseDCT8x8WithSource:(const cv::Mat &)src {
    int width = src.size().width / 8;
    int height = src.size().height / 8;

    cv::Mat dest = cv::Mat(height * 8, width * 8, CV_8U);

    for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
            cv::Mat tmpMat = cv::Mat(8, 8, CV_32F);
            cv::Mat tmpDCTMat = cv::Mat(8, 8, CV_32F);
            for (int mi = 0; mi < 8; mi++)
                for (int mj = 0; mj < 8; mj++)
                    tmpMat.at<float>(mi, mj) = (float)src.at<int>(i * 8 + mi, j * 8 + mj);

            tmpDCTMat = DCT8x8Matrix.t() * tmpMat * DCT8x8Matrix;

            for (int mi = 0; mi < 8; mi++)
                for (int mj = 0; mj < 8; mj++)
                    dest.at<uchar>(i * 8 + mi, j * 8 + mj) = (uchar)tmpDCTMat.at<float>(mi, mj);
        }
    }
    return dest;
}

- (void)runInverseDCT {
    YInversedDCTMatrix.push_back([self InverseDCT8x8WithSource:YInversedQuantizedMatrix[0]].clone());
    YInversedDCTMatrix.push_back([self InverseDCT8x8WithSource:YInversedQuantizedMatrix[1]].clone());
    YInversedDCTMatrix.push_back([self InverseDCT8x8WithSource:YInversedQuantizedMatrix[2]].clone());
    YInversedDCTMatrix.push_back([self InverseDCT8x8WithSource:YInversedQuantizedMatrix[3]].clone());
    YInversedDCTMatrix.push_back([self InverseDCT8x8WithSource:YInversedQuantizedMatrix[4]].clone());
    YInversedDCTMatrix.push_back([self InverseDCT8x8WithSource:YInversedQuantizedMatrix[5]].clone());

    CbInversedDCTMatrix.push_back([self InverseDCT8x8WithSource:CbInversedQuantizedMatrix[0]].clone());
    CbInversedDCTMatrix.push_back([self InverseDCT8x8WithSource:CbInversedQuantizedMatrix[1]].clone());
    CbInversedDCTMatrix.push_back([self InverseDCT8x8WithSource:CbInversedQuantizedMatrix[2]].clone());
    CbInversedDCTMatrix.push_back([self InverseDCT8x8WithSource:CbInversedQuantizedMatrix[3]].clone());
    CbInversedDCTMatrix.push_back([self InverseDCT8x8WithSource:CbInversedQuantizedMatrix[4]].clone());
    CbInversedDCTMatrix.push_back([self InverseDCT8x8WithSource:CbInversedQuantizedMatrix[5]].clone());

    CrInversedDCTMatrix.push_back([self InverseDCT8x8WithSource:CrInversedQuantizedMatrix[0]].clone());
    CrInversedDCTMatrix.push_back([self InverseDCT8x8WithSource:CrInversedQuantizedMatrix[1]].clone());
    CrInversedDCTMatrix.push_back([self InverseDCT8x8WithSource:CrInversedQuantizedMatrix[2]].clone());
    CrInversedDCTMatrix.push_back([self InverseDCT8x8WithSource:CrInversedQuantizedMatrix[3]].clone());
    CrInversedDCTMatrix.push_back([self InverseDCT8x8WithSource:CrInversedQuantizedMatrix[4]].clone());
    CrInversedDCTMatrix.push_back([self InverseDCT8x8WithSource:CrInversedQuantizedMatrix[5]].clone());
}

#pragma mark - Quantization

- (cv::Mat)QuantizationWithSource:(const cv::Mat&)src QuantizationMatrix:(const cv::Mat&)matrix {
    int width = src.size().width;
    int height = src.size().height;

    cv::Mat dest = cv::Mat(height, width, CV_32S);
    cv::Mat tmpMat = cv::Mat(height, width, CV_32S);
    for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
            tmpMat.at<int>(i, j) = matrix.at<int>(i % 8, j % 8);
        }
    }
    cv::divide(src, tmpMat, dest);
    return dest;
}

- (void)runQuantization {
    YQuantizedMatrix.push_back([self QuantizationWithSource:YDCTMatrix QuantizationMatrix:quantizationMatrix[0]].clone());
    YQuantizedMatrix.push_back([self QuantizationWithSource:YDCTMatrix QuantizationMatrix:quantizationMatrix[1]].clone());
    YQuantizedMatrix.push_back([self QuantizationWithSource:YDCTMatrix QuantizationMatrix:quantizationMatrix[2]].clone());
    YQuantizedMatrix.push_back([self QuantizationWithSource:YDCTMatrix QuantizationMatrix:quantizationMatrix[3]].clone());
    YQuantizedMatrix.push_back([self QuantizationWithSource:YDCTMatrix QuantizationMatrix:quantizationMatrix[4]].clone());
    YQuantizedMatrix.push_back([self QuantizationWithSource:YDCTMatrix QuantizationMatrix:quantizationMatrix[5]].clone());

    CbQuantizedMatrix.push_back([self QuantizationWithSource:CbDCTMatrix QuantizationMatrix:quantizationMatrix[0]].clone());
    CbQuantizedMatrix.push_back([self QuantizationWithSource:CbDCTMatrix QuantizationMatrix:quantizationMatrix[1]].clone());
    CbQuantizedMatrix.push_back([self QuantizationWithSource:CbDCTMatrix QuantizationMatrix:quantizationMatrix[2]].clone());
    CbQuantizedMatrix.push_back([self QuantizationWithSource:CbDCTMatrix QuantizationMatrix:quantizationMatrix[3]].clone());
    CbQuantizedMatrix.push_back([self QuantizationWithSource:CbDCTMatrix QuantizationMatrix:quantizationMatrix[4]].clone());
    CbQuantizedMatrix.push_back([self QuantizationWithSource:CbDCTMatrix QuantizationMatrix:quantizationMatrix[5]].clone());

    CrQuantizedMatrix.push_back([self QuantizationWithSource:CrDCTMatrix QuantizationMatrix:quantizationMatrix[0]].clone());
    CrQuantizedMatrix.push_back([self QuantizationWithSource:CrDCTMatrix QuantizationMatrix:quantizationMatrix[1]].clone());
    CrQuantizedMatrix.push_back([self QuantizationWithSource:CrDCTMatrix QuantizationMatrix:quantizationMatrix[2]].clone());
    CrQuantizedMatrix.push_back([self QuantizationWithSource:CrDCTMatrix QuantizationMatrix:quantizationMatrix[3]].clone());
    CrQuantizedMatrix.push_back([self QuantizationWithSource:CrDCTMatrix QuantizationMatrix:quantizationMatrix[4]].clone());
    CrQuantizedMatrix.push_back([self QuantizationWithSource:CrDCTMatrix QuantizationMatrix:quantizationMatrix[5]].clone());
}

#pragma mark - Inverse Quantization

- (cv::Mat)InverseQuantizationWithSource:(const cv::Mat&)src QuantizationMatrix:(const cv::Mat&)matrix {
    int width = src.size().width;
    int height = src.size().height;

    cv::Mat dest = cv::Mat(height, width, CV_32S);
    cv::Mat tmpMat = cv::Mat(height, width, CV_32S);
    for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
            tmpMat.at<int>(i, j) = matrix.at<int>(i % 8, j % 8);
        }
    }
    dest = src.mul(tmpMat);
    return dest;
}

- (void)runInverseQuantization {
    YInversedQuantizedMatrix.push_back([self InverseQuantizationWithSource:YQuantizedMatrix[0]
                                                        QuantizationMatrix:quantizationMatrix[0]].clone());
    YInversedQuantizedMatrix.push_back([self InverseQuantizationWithSource:YQuantizedMatrix[1]
                                                        QuantizationMatrix:quantizationMatrix[1]].clone());
    YInversedQuantizedMatrix.push_back([self InverseQuantizationWithSource:YQuantizedMatrix[2]
                                                        QuantizationMatrix:quantizationMatrix[2]].clone());
    YInversedQuantizedMatrix.push_back([self InverseQuantizationWithSource:YQuantizedMatrix[3]
                                                        QuantizationMatrix:quantizationMatrix[3]].clone());
    YInversedQuantizedMatrix.push_back([self InverseQuantizationWithSource:YQuantizedMatrix[4]
                                                        QuantizationMatrix:quantizationMatrix[4]].clone());
    YInversedQuantizedMatrix.push_back([self InverseQuantizationWithSource:YQuantizedMatrix[5]
                                                        QuantizationMatrix:quantizationMatrix[5]].clone());

    CbInversedQuantizedMatrix.push_back([self InverseQuantizationWithSource:CbQuantizedMatrix[0]
                                                         QuantizationMatrix:quantizationMatrix[0]].clone());
    CbInversedQuantizedMatrix.push_back([self InverseQuantizationWithSource:CbQuantizedMatrix[1]
                                                         QuantizationMatrix:quantizationMatrix[1]].clone());
    CbInversedQuantizedMatrix.push_back([self InverseQuantizationWithSource:CbQuantizedMatrix[2]
                                                         QuantizationMatrix:quantizationMatrix[2]].clone());
    CbInversedQuantizedMatrix.push_back([self InverseQuantizationWithSource:CbQuantizedMatrix[3]
                                                         QuantizationMatrix:quantizationMatrix[3]].clone());
    CbInversedQuantizedMatrix.push_back([self InverseQuantizationWithSource:CbQuantizedMatrix[4]
                                                         QuantizationMatrix:quantizationMatrix[4]].clone());
    CbInversedQuantizedMatrix.push_back([self InverseQuantizationWithSource:CbQuantizedMatrix[5]
                                                         QuantizationMatrix:quantizationMatrix[5]].clone());

    CrInversedQuantizedMatrix.push_back([self InverseQuantizationWithSource:CrQuantizedMatrix[0]
                                                         QuantizationMatrix:quantizationMatrix[0]].clone());
    CrInversedQuantizedMatrix.push_back([self InverseQuantizationWithSource:CrQuantizedMatrix[1]
                                                         QuantizationMatrix:quantizationMatrix[1]].clone());
    CrInversedQuantizedMatrix.push_back([self InverseQuantizationWithSource:CrQuantizedMatrix[2]
                                                         QuantizationMatrix:quantizationMatrix[2]].clone());
    CrInversedQuantizedMatrix.push_back([self InverseQuantizationWithSource:CrQuantizedMatrix[3]
                                                         QuantizationMatrix:quantizationMatrix[3]].clone());
    CrInversedQuantizedMatrix.push_back([self InverseQuantizationWithSource:CrQuantizedMatrix[4]
                                                         QuantizationMatrix:quantizationMatrix[4]].clone());
    CrInversedQuantizedMatrix.push_back([self InverseQuantizationWithSource:CrQuantizedMatrix[5]
                                                         QuantizationMatrix:quantizationMatrix[5]].clone());
}

#pragma mark - Generate Final Image

- (cv::Mat)getFinalImage {
    std::vector<cv::Mat> RGBChannels;
    RGBChannels.push_back(YInversedDCTMatrix[self.quantizationMatrixChoosedNumber].clone());
    RGBChannels.push_back(YInversedDCTMatrix[self.quantizationMatrixChoosedNumber].clone());
    RGBChannels.push_back(YInversedDCTMatrix[self.quantizationMatrixChoosedNumber].clone());

    cv::Size size = YInversedDCTMatrix[self.quantizationMatrixChoosedNumber].size();
    int imageWidth = size.width;
    int imageHeight = size.height;
    int scaleCbHeight = imageHeight / CbInversedDCTMatrix[self.quantizationMatrixChoosedNumber].size().height;
    int scaleCrHeight = imageHeight / CrInversedDCTMatrix[self.quantizationMatrixChoosedNumber].size().height;
    int scaleCbWidth = imageWidth / CbInversedDCTMatrix[self.quantizationMatrixChoosedNumber].size().width;
    int scaleCrWidth = imageWidth / CrInversedDCTMatrix[self.quantizationMatrixChoosedNumber].size().width;

    for (int i = 0; i < imageHeight; i++) {
        for (int j = 0; j < imageWidth; j++) {
            float Y = (float)YInversedDCTMatrix[self.quantizationMatrixChoosedNumber].at<uchar>(i, j);
            float Cb = (float)CbInversedDCTMatrix[self.quantizationMatrixChoosedNumber].at<uchar>(i / scaleCbHeight, j / scaleCbWidth);
            float Cr = (float)CrInversedDCTMatrix[self.quantizationMatrixChoosedNumber].at<uchar>(i / scaleCrHeight, j / scaleCrWidth);
            RGBChannels[0].at<uchar>(i, j) = (uchar)GET_R_FROM_YCbCr;
            RGBChannels[1].at<uchar>(i, j) = (uchar)GET_G_FROM_YCbCr;
            RGBChannels[2].at<uchar>(i, j) = (uchar)GET_B_FROM_YCbCr;
        }
    }

    cv::Mat RGBImage = cv::Mat(size, CV_8U);
    cv::merge(RGBChannels, RGBImage);
    return RGBImage;
}

#pragma mark - Imageview Image Rect

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
}

#pragma mark - Button Click Event

- (IBAction)chooseSubsampling:(UIBarButtonItem *)sender {
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

- (IBAction)seeQuantizedResult:(UIButton *)sender {
    [self TapGestureEvent:nil];
    if (self.quantizationMatrixChoosedNumber != -1) {
        [self performSegueWithIdentifier:@"segueToQuantizedResult" sender:self];
    } else {
        [self popAlertWithTitle:@"Emmm..." message:@"You haven't select the quantization matrix :("];
    }
}

- (IBAction)seeIDCTResult:(UIButton *)sender {
    [self TapGestureEvent:nil];
    if (self.quantizationMatrixChoosedNumber != -1) {
        [self performSegueWithIdentifier:@"segueToIDCTResult" sender:self];
    } else {
        [self popAlertWithTitle:@"Emmm..." message:@"You haven't select the quantization matrix :("];
    }
}

- (IBAction)seeFinalResult:(UIBarButtonItem *)sender {
    [self TapGestureEvent:nil];
    if (self.quantizationMatrixChoosedNumber != -1) {
        [self performSegueWithIdentifier:@"segueToFinalResult" sender:self];
    } else {
        [self popAlertWithTitle:@"Emmm..." message:@"You haven't select the quantization matrix :("];
    }
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

- (void)YImageTapped:(UITapGestureRecognizer *)sender {
    [self TapGestureEvent:sender];
    self.isTouchedImageView = true;
    CGPoint touchPoint = [sender locationInView:self.channelYImageView];
    NSLog(@"x: %f y: %f", touchPoint.x, touchPoint.y);
}

- (void)CbImageTapped:(UITapGestureRecognizer *)sender {
    [self TapGestureEvent:sender];
    self.isTouchedImageView = true;
    CGPoint touchPoint = [sender locationInView:self.channelCbImageView];
    NSLog(@"x: %f y: %f", touchPoint.x, touchPoint.y);
}

- (void)CrImageTapped:(UITapGestureRecognizer *)sender {
    [self TapGestureEvent:sender];
    self.isTouchedImageView = true;
    CGPoint touchPoint = [sender locationInView:self.channelCrImageView];
    NSLog(@"x: %f y: %f", touchPoint.x, touchPoint.y);
}

#pragma mark - Prepare Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"segueToDCTResult"]) {
        DisplayViewController *destViewController = [segue destinationViewController];
        [destViewController setQuantizationMatrixChoosedNumber:self.quantizationMatrixChoosedNumber];
        for (int i = 0; i < 6; i++) {
            destViewController->YImage.push_back(YDCTMatrix.clone());
            destViewController->CbImage.push_back(CbDCTMatrix.clone());
            destViewController->CrImage.push_back(CrDCTMatrix.clone());
        }
    } else if ([[segue identifier] isEqualToString:@"segueToQuantizedResult"]) {
        DisplayViewController *destViewController = [segue destinationViewController];
        [destViewController setQuantizationMatrixChoosedNumber:self.quantizationMatrixChoosedNumber];
        for (int i = 0; i < 6; i++) {
            destViewController->YImage.push_back(YQuantizedMatrix[i].clone());
            destViewController->CbImage.push_back(CbQuantizedMatrix[i].clone());
            destViewController->CrImage.push_back(CrQuantizedMatrix[i].clone());
        }
    } else if ([[segue identifier] isEqualToString:@"segueToIDCTResult"]) {
        DisplayViewController *destViewController = [segue destinationViewController];
        [destViewController setQuantizationMatrixChoosedNumber:self.quantizationMatrixChoosedNumber];
        for (int i = 0; i < 6; i++) {
            destViewController->YImage.push_back(YInversedDCTMatrix[i].clone());
            destViewController->CbImage.push_back(CbInversedDCTMatrix[i].clone());
            destViewController->CrImage.push_back(CrInversedDCTMatrix[i].clone());
        }
    } else if ([[segue identifier] isEqualToString:@"segueToFinalResult"]) {
        FinalResultViewController *destViewController = [segue destinationViewController];
        [destViewController setOriginalImage:self.originalImage];
        [destViewController setFinalImage:[self getFinalImage]];
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
    self.quantizationMatrixChoosedNumber = row - 1;
    if (self.quantizationMatrixChoosedNumber != -1) {
        quantizationMatrixBlock = quantizationMatrix[self.quantizationMatrixChoosedNumber];
        UICollectionView * collectionView = (UICollectionView *)[self.quantizationMatrixUIView subviews][0];
        [collectionView reloadData];
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
    [cell setBackgroundColor:[UIColor clearColor]];
    UILabel *numberLabel = [[UILabel alloc] initWithFrame:cell.bounds];
    [numberLabel setTextAlignment:NSTextAlignmentCenter];
    [numberLabel setText:@"?"];
    [numberLabel setFont:[UIFont systemFontOfSize:7]];
    if (self.isTouchedImageView) {
        if (collectionView.tag == 1) {
            [numberLabel setText:[[NSString alloc] initWithFormat:@"%d",
                                  DCTBlock.at<int>((int)indexPath.item / 8, (int)indexPath.item % 8)]];
        } else if (collectionView.tag == 2) {
            [numberLabel setText:[[NSString alloc] initWithFormat:@"%d",
                                  quantizedBlock.at<int>((int)indexPath.item / 8, (int)indexPath.item % 8)]];
        } else if (collectionView.tag == 3) {
            [numberLabel setText:[[NSString alloc] initWithFormat:@"%d",
                                  quantizationMatrixBlock.at<int>((int)indexPath.item / 8, (int)indexPath.item % 8)]];
        }
    }
    for (UIView *subview in [cell subviews]) {
        if([subview isKindOfClass:[UILabel class]])
            [subview removeFromSuperview];
    }
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
    return CGSizeMake(width, height);
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