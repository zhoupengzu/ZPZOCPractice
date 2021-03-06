//
//  ZPZDefaultSessionDownloadTaskViewController.m
//  ZPZNetWorkPractice
//
//  Created by zhoupengzu on 2018/2/6.
//  Copyright © 2018年 zhoupengzu. All rights reserved.
//

#import "ZPZDefaultSessionDownloadTaskViewController.h"

@interface ZPZDefaultSessionDownloadTaskViewController ()<NSURLSessionDownloadDelegate, NSURLSessionDataDelegate>
{
    BOOL isNeedCancel;
    NSData * resumeData;
    NSURLSession * resumeSession;
    NSURLSessionDownloadTask * resumeDownloadTask;
}

@property (nonatomic, strong) UIImageView * bacImageView;
@property (nonatomic, strong) NSMutableData * responseData;
@property (nonatomic, assign) NSInteger index;

@end

@implementation ZPZDefaultSessionDownloadTaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _bacImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _bacImageView.backgroundColor = [UIColor clearColor];
    _bacImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:_bacImageView];
    [self.view sendSubviewToBack:_bacImageView];
}
//直接请求一张图片
- (IBAction)downloadWithRequestAndUrl:(id)sender {
    _index = 0;
    _bacImageView.image = [UIImage imageNamed:@""];
    NSURLSessionConfiguration * defaultConfirguration = [NSURLSessionConfiguration defaultSessionConfiguration];
//    NSURLSessionConfiguration * defaultConfirguration = [NSURLSessionConfiguration ephemeralSessionConfiguration]; //不影响，还是会往disk上写
    NSURLSession * defaultSession = [NSURLSession sessionWithConfiguration:defaultConfirguration delegate:self delegateQueue:nil];
    NSURLSessionDownloadTask * downTask = [defaultSession downloadTaskWithURL:[NSURL URLWithString:@"http://0.0.0.0:8080/for_down.JPG"]];
    [downTask resume];
}
- (IBAction)downloadWithRequestAndUrl2:(id)sender {
    _index = 1;
    NSURLSessionConfiguration * defaultConfirguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    //    NSURLSessionConfiguration * defaultConfirguration = [NSURLSessionConfiguration ephemeralSessionConfiguration]; //不影响，还是会往disk上写
    NSURLSession * defaultSession = [NSURLSession sessionWithConfiguration:defaultConfirguration delegate:self delegateQueue:nil];
    NSURLSessionDownloadTask * downTask = [defaultSession downloadTaskWithURL:[NSURL URLWithString:@"http://0.0.0.0:8080/request.php?name=zhoupengzu&age=20"]];
    [downTask resume];
}
- (IBAction)downloadWithResumeData:(id)sender {
    _index = 2;
    _bacImageView.image = [UIImage imageNamed:@""];
    if (isNeedCancel) {
        isNeedCancel = NO;
        resumeDownloadTask = [resumeSession downloadTaskWithResumeData:resumeData];
        [resumeDownloadTask resume];
    } else {
        isNeedCancel = YES;
        NSURLSessionConfiguration * defaultConfirguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        //    NSURLSessionConfiguration * defaultConfirguration = [NSURLSessionConfiguration ephemeralSessionConfiguration]; //不影响，还是会往disk上写
        resumeSession = [NSURLSession sessionWithConfiguration:defaultConfirguration delegate:self delegateQueue:nil];
        resumeDownloadTask = [resumeSession downloadTaskWithURL:[NSURL URLWithString:@"http://120.25.226.186:32812/resources/videos/minion_02.mp4"]];
        [resumeDownloadTask resume];
    }
}

//该回调在异步线程中
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    NSLog(@"%s",__func__);
    if (_index == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSData * imageData = [NSData dataWithContentsOfURL:location];
            _bacImageView.image = [UIImage imageWithData:imageData];
        });
    } else if (_index == 1) {
        
    } else if (_index == 2) {
        
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    NSLog(@"%s",__func__);
    NSLog(@"didWrite:%lld,totalWrite:%lld,totalExpected:%lld", bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    if (_index == 2 && isNeedCancel) {
        [resumeDownloadTask cancelByProducingResumeData:^(NSData * _Nullable data) {
            resumeData = data;
        }];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    NSLog(@"%s",__func__);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalByte {
    NSLog(@"%s",__func__);
}


@end
