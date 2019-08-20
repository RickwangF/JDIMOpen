//
//  ZSCamareView.m
//  JadeKing
//
//  Created by 张森 on 2018/10/11.
//  Copyright © 2018年 张森. All rights reserved.
//

#import "ZSCamareView.h"
#import <AVKit/AVKit.h>
#import "FrameLayoutTool.h"
#import <ZSBaseUtil/ZSBaseUtil-Swift.h>

@interface ZSCamareView ()<AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate, ZSAVAssetWriteManagerDelegate>
@property (nonatomic, strong) AVCaptureSession *session;  // 会话
@property (nonatomic, strong) dispatch_queue_t videoQueue;  // 视频队列
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewlayer;  // 采集图层
@property (nonatomic, strong) AVCaptureDeviceInput *videoInput;  // 视频输入
@property (nonatomic, strong) AVCaptureDeviceInput *audioInput;  // 音频输入
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoOutput;  // 视频输出
@property (nonatomic, strong) AVCaptureAudioDataOutput *audioOutput;  // 音频输出
@property (nonatomic, strong) AVCaptureStillImageOutput *imageOutput;  // 照片输出
@property (nonatomic, strong) ZSAVAssetWriteManager *writeManager;  // 文件写入类
@property (nonatomic, assign) ZSCamareFlashState flashState;  // 闪光灯状态
@property (nonatomic, assign) ZSVideoModelType videoModelType;  // 视频模型
@property (nonatomic, assign) NSInteger recordMaxTime;  // 最长录制时间
@property (nonatomic, strong, readwrite) NSURL *videoFilePath;  // 视频路径
@end

@implementation ZSCamareView

- (instancetype)initWithVideoModelType:(ZSVideoModelType)type recordMaxTime:(NSInteger)sec{
    self = [super init];
    if (self) {
        _videoModelType = type;
        _recordMaxTime  = sec;
        [self setUpWithType];
    }
    return self;
}

// Mark - lazy load
- (AVCaptureSession *)session{
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
        if ([_session canSetSessionPreset:AVCaptureSessionPresetHigh]) {//设置分辨率
            // 录制5秒钟视频 高画质10M,压缩成中画质 0.5M
            // 录制5秒钟视频 中画质0.5M,压缩成中画质 0.5M
            // 录制5秒钟视频 低画质0.1M,压缩成中画质 0.1M
            _session.sessionPreset = AVCaptureSessionPresetHigh;
        }
    }
    return _session;
}

- (dispatch_queue_t)videoQueue{
    if (!_videoQueue) {
        _videoQueue = dispatch_queue_create("com.zhangsen", DISPATCH_QUEUE_SERIAL);
    }
    return _videoQueue;
}

- (AVCaptureVideoPreviewLayer *)previewlayer{
    if (!_previewlayer) {
        _previewlayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        _previewlayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [self.layer insertSublayer:_previewlayer atIndex:0];
    }
    return _previewlayer;
}

- (void)setRecordState:(ZSRecordState)recordState{
    if (_recordState != recordState) {
        _recordState = recordState;
        if (self.delegate && [self.delegate respondsToSelector:@selector(updateRecordState:)]) {
            [self.delegate updateRecordState:_recordState];
        }
    }
}

// Mark - setup
- (void)setUpWithType{
    [self setUpInit];  // 初始化捕捉会话，数据的采集都在会话中处理
    [self setUpVideo];  // 设置视频的输入输出
    [self setUpAudio];  // 设置音频的输入输出
    [self setUpImage];  // 图片输出
    [self setUpPreviewLayerWithType];  // 视频的预览层
    [self.session startRunning];  // 开始采集画面
    [self setUpWriter];  // 初始化writer， 用writer 把数据写入文件
}

- (void)setUpVideo{
    AVCaptureDevice *videoCaptureDevice=[self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];  // 获取视频输入设备(摄像头)
    NSError *error=nil;
    self.videoInput= [[AVCaptureDeviceInput alloc] initWithDevice:videoCaptureDevice error:&error];  // 创建视频输入源
    if ([self.session canAddInput:self.videoInput]) {  // 将视频输入源添加到会话
        [self.session addInput:self.videoInput];
    }
    
    self.videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    self.videoOutput.alwaysDiscardsLateVideoFrames = YES;  // 立即丢弃旧帧，节省内存，默认YES
    [self.videoOutput setSampleBufferDelegate:self queue:self.videoQueue];
    if ([self.session canAddOutput:self.videoOutput]) {
        [self.session addOutput:self.videoOutput];
    }
}

- (void)setUpAudio{
    AVCaptureDevice *audioCaptureDevice=[[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];  // 获取音频输入设备
    NSError *error=nil;
    self.audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:audioCaptureDevice error:&error];  // 创建音频输入源
    
    if ([self.session canAddInput:self.audioInput]) {  // 将音频输入源添加到会话
        [self.session addInput:self.audioInput];
    }
    
    self.audioOutput = [[AVCaptureAudioDataOutput alloc] init];
    [self.audioOutput setSampleBufferDelegate:self queue:self.videoQueue];
    if([self.session canAddOutput:self.audioOutput]) {
        [self.session addOutput:self.audioOutput];
    }
}

- (void)setUpImage{
    _imageOutput = [[AVCaptureStillImageOutput alloc]init];
    NSDictionary *outputDic = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    [_imageOutput setOutputSettings:outputDic];
    
    if ([self.session canAddOutput:_imageOutput]) {
        [self.session addOutput:_imageOutput];
    }
}

- (void)setUpPreviewLayerWithType{
    CGRect rect = CGRectZero;
    switch (_videoModelType) {
        case ZSVideoModelType_1X1:
            rect = CGRectMake(0, 0, FrameLayoutTool.Width, FrameLayoutTool.Width);
            break;
        case ZSVideoModelType_4X3:
            rect = CGRectMake(0, 0, FrameLayoutTool.Width, FrameLayoutTool.Width*4/3);
            break;
        case ZSVideoModelTypeFullScreen:
            rect = CGRectMake(0, 0, FrameLayoutTool.Width, FrameLayoutTool.Height);
            break;
        default:
            rect = CGRectMake(0, 0, FrameLayoutTool.Width, FrameLayoutTool.Height);
            break;
    }
    self.previewlayer.frame = rect;
}

- (void)setUpWriter{
    _videoFilePath = [[NSURL alloc] initFileURLWithPath:[self createVideoFilePath]];
    _writeManager = [[ZSAVAssetWriteManager alloc] initWithURL:self.videoFilePath videoModelType:_videoModelType];
    _writeManager.delegate = self;
    _writeManager.recordMaxTime = _recordMaxTime;
}

// Mark - public method
- (void)turnCameraAction{  // 切换摄像头
    [self.session stopRunning];
    AVCaptureDevicePosition position = self.videoInput.device.position;  // 获取当前摄像头
    if (position == AVCaptureDevicePositionBack) {  // 获取当前需要展示的摄像头
        position = AVCaptureDevicePositionFront;
    } else {
        position = AVCaptureDevicePositionBack;
    }
    AVCaptureDevice *device = [self getCameraDeviceWithPosition:position];  // 根据当前摄像头创建新的device
    AVCaptureDeviceInput *newInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];  // 根据新的device创建input
    
    // 在session中切换input
    [self.session beginConfiguration];
    [self.session removeInput:self.videoInput];
    [self.session addInput:newInput];
    [self.session commitConfiguration];
    self.videoInput = newInput;
    
    [self.session startRunning];
}

- (void)switchflash{  // 切换闪光灯
    if(_flashState == ZSCamareFlashClose){
        if ([self.videoInput.device hasTorch]) {
            [self.videoInput.device lockForConfiguration:nil];
            [self.videoInput.device setTorchMode:AVCaptureTorchModeOn];
            [self.videoInput.device unlockForConfiguration];
            _flashState = ZSCamareFlashOpen;
        }
    }else if(_flashState == ZSCamareFlashOpen){
        if ([self.videoInput.device hasTorch]) {
            [self.videoInput.device lockForConfiguration:nil];
            [self.videoInput.device setTorchMode:AVCaptureTorchModeAuto];
            [self.videoInput.device unlockForConfiguration];
            _flashState = ZSCamareFlashAuto;
        }
    }else if(_flashState == ZSCamareFlashAuto){
        if ([self.videoInput.device hasTorch]) {
            [self.videoInput.device lockForConfiguration:nil];
            [self.videoInput.device setTorchMode:AVCaptureTorchModeOff];
            [self.videoInput.device unlockForConfiguration];
            _flashState = ZSCamareFlashClose;
        }
    };
    if (self.delegate && [self.delegate respondsToSelector:@selector(updateFlashState:)]) {
        [self.delegate updateFlashState:_flashState];
    }
}

- (void)startRecord{  // 开始录制
    if (self.recordState == ZSRecordStateInit) {
        [self.writeManager startWrite];
        self.recordState = ZSRecordStateRecording;
    }
}

- (void)stopRecord{  // 停止录制
    [self.writeManager stopWrite];
    [self closeCamare];
    if (_videoFilePath) {
        _videoImage = [self videoSnap:_videoFilePath];
    }
    self.recordState = ZSRecordStateFinish;
}

- (void)resetRecord{  // 重新录制
    self.recordState = ZSRecordStateInit;
    if (!self.session.isRunning) {
        [self.session startRunning];
    }
    [self setUpWriter];
}

- (void)closeCamare{
    [self.session stopRunning];
}

- (void)takePicturesCompletionHandler:(void(^)(UIImage* img))completionHandler{  // 拍照
    AVCaptureConnection  *connection = [_imageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!connection) {
        NSLog(@"失败");
        return;
    }
    //设置焦距
    [connection setVideoScaleAndCropFactor:1];
    
    [_imageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        
        UIImage *img = nil;
        if (imageDataSampleBuffer != NULL) {
            NSData *data = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            img = [UIImage imageWithData:data];
            UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil);
        }
        
        if (completionHandler) {
            completionHandler(img);
        }
    }];
}

// Mark - private method
- (void)setUpInit{  // 初始化设置
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBack) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive) name:UIApplicationWillEnterForegroundNotification object:nil];
    [self clearFile];
    _recordState = ZSRecordStateInit;
}

- (NSString *)videoFolder{  // 存放视频的文件夹
    
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDir = [pathArray objectAtIndex:0];
    NSString *direc = [cacheDir stringByAppendingPathComponent:VIDEO_FOLDER];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:direc]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:direc withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return direc;
}

- (void)clearFile{  // 清空文件夹
    
    [[NSFileManager defaultManager] removeItemAtPath:[self videoFolder] error:nil];
}

- (NSString *)createVideoFilePath{  // 写入的视频路径
    NSString *videoName = [NSString stringWithFormat:@"%@.mp4", [NSUUID UUID].UUIDString];
    NSString *path = [[self videoFolder] stringByAppendingPathComponent:videoName];
    return path;
}

// Mark - 获取摄像头
-(AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition )position{
    NSArray *cameras= [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position] == position) {
            return camera;
        }
    }
    return nil;
}

// Mark - AVCaptureVideoDataOutputSampleBufferDelegate AVCaptureAudioDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    @autoreleasepool {
        // 视频
        if (connection == [self.videoOutput connectionWithMediaType:AVMediaTypeVideo]) {
            
            if (!self.writeManager.outputVideoFormatDescription) {
                @synchronized(self) {
                    CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
                    self.writeManager.outputVideoFormatDescription = formatDescription;
                    
                }
            } else {
                @synchronized(self) {
                    if (self.writeManager.writeState == ZSRecordStateRecording) {
                        [self.writeManager appendSampleBuffer:sampleBuffer oediaType:AVMediaTypeVideo];
                    }
                }
            }
        }
        
        // 音频
        if (connection == [self.audioOutput connectionWithMediaType:AVMediaTypeAudio]) {
            if (!self.writeManager.outputAudioFormatDescription) {
                @synchronized(self) {
                    CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
                    self.writeManager.outputAudioFormatDescription = formatDescription;
                }
            }
            @synchronized(self) {
                if (self.writeManager.writeState == ZSRecordStateRecording) {
                    [self.writeManager appendSampleBuffer:sampleBuffer oediaType:AVMediaTypeAudio];
                }
            }
        }
    }
}

- (UIImage *)videoSnap:(NSURL *)url {
    
    AVURLAsset *urlSet = [AVURLAsset assetWithURL:url];
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlSet];
    imageGenerator.appliesPreferredTrackTransform = YES;  // 截图的时候调整到正确的方向
    
    NSError *error = nil;
    CMTime time = CMTimeMake(1,10);  // 缩略图创建时间 CMTime是表示电影时间信息的结构体，第一个参数表示是视频第几秒，第二个参数表示每秒帧数.(如果要活的某一秒的第几帧可以使用CMTimeMake方法)
    CMTime actucalTime;  // 缩略图实际生成的时间
    CGImageRef cgImage = [imageGenerator copyCGImageAtTime:time actualTime:&actucalTime error:&error];
    if (error) {
        NSLog(@"截取视频图片失败:%@",error.localizedDescription);
    }else{
        CMTimeShow(actucalTime);
        UIImage *image = [UIImage imageWithCGImage:cgImage];
        return image;
    }
    //    UIImageWriteToSavedPhotosAlbum(image,nil, nil,nil);
    CGImageRelease(cgImage);
    
    return nil;
}

- (NSString *)convertTimeToString:(NSInteger)second{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"m:ss"];
    NSDate *date = [formatter dateFromString:@"0:00"];
    date = [date dateByAddingTimeInterval:second];
    NSString *timeString = [formatter stringFromDate:date];
    return timeString;
}

// Mark - AVAssetWriteManagerDelegate
- (void)updateWritingProgress:(CGFloat)progress{
    if (self.delegate && [self.delegate respondsToSelector:@selector(updateRecordingProgress:)]) {
        [self.delegate updateRecordingProgress:progress];
    }
    if ([self.delegate respondsToSelector:@selector(updateRecordingTime:)]) {
        [self.delegate updateRecordingTime:[self convertTimeToString:progress * _recordMaxTime]];
    }
}

- (void)finishWriting{
    [self.session stopRunning];
    self.recordState = ZSRecordStateFinish;
    [self.delegate recordFinish];
}

// Mark - notification
- (void)enterBack{
    self.videoFilePath = nil;
    [self.session stopRunning];
    [self.writeManager destroyWrite];
}

- (void)becomeActive{
    [self resetRecord];
}

- (void)destroy{
    [self.session stopRunning];
    self.session = nil;
    self.videoQueue = nil;
    self.videoOutput = nil;
    self.videoInput = nil;
    self.audioOutput = nil;
    self.audioInput = nil;
    [self.writeManager destroyWrite];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc{
    [self destroy];
}
@end
