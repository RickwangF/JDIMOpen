//
//  ZSAVAssetWriteManager.m
//  RecordVideo
//
//  Created by 张森 on 17/6/22.
//  Copyright © 2017年 张森. All rights reserved.
//

#import "ZSAVAssetWriteManager.h"
#import "ZSBaseUtil-Swift.h"
#import "FrameLayoutTool.h"

@interface ZSAVAssetWriteManager ()
@property (nonatomic, strong) dispatch_queue_t writeQueue;  // 文件写入队列
@property (nonatomic, strong) NSURL *videoFilePath;  // 视频文件路径

@property (nonatomic, strong) AVAssetWriter *assetWriter;  // 文件写入对象

@property (nonatomic, strong) AVAssetWriterInput *assetWriterVideoInput;  // 视频输入
@property (nonatomic, strong) AVAssetWriterInput *assetWriterAudioInput;  // 音频输入

@property (nonatomic, strong) NSDictionary *videoCompressionSettings;  // 视频配置
@property (nonatomic, strong) NSDictionary *audioCompressionSettings;  // 音频配置

@property (nonatomic, assign) BOOL isCanWrite;  // 是否能写入
@property (nonatomic, assign) ZSVideoModelType videoModelType;  // 视频模型
@property (nonatomic, assign) CGSize outputSize;  // 输出的尺寸

@property (nonatomic, strong) NSTimer *timer;  // 定时器
@property (nonatomic, assign) CGFloat recordTime;  // 录制时长
@end

@implementation ZSAVAssetWriteManager

// Mark - private method
- (CGSize)getOutputSize:(CGFloat)width height:(CGFloat)height{
    int w = (int) width % 16;
    w = (w == 0) ? 0 : (16 - w);
    int h = (int) height % 16;
    h = (h == 0) ? 0 : (16 - h);
    return CGSizeMake(width + w, height + h);
}

- (void)setUpInitWithType:(ZSVideoModelType )type{

    switch (type) {
        case ZSVideoModelType_1X1:
            _outputSize = [self getOutputSize:FrameLayoutTool.Width height:FrameLayoutTool.Width];
            break;
        case ZSVideoModelType_4X3:
            _outputSize = [self getOutputSize:FrameLayoutTool.Width height:FrameLayoutTool.Width * 4/3];
            break;
        case ZSVideoModelTypeFullScreen:{
            _outputSize = [self getOutputSize:FrameLayoutTool.Width height:FrameLayoutTool.Height];
            break;
        }
        default:
            _outputSize = CGSizeMake(FrameLayoutTool.Width, FrameLayoutTool.Width);
            break;
    }
    _writeQueue = dispatch_queue_create("com.zhangsen", DISPATCH_QUEUE_SERIAL);
    _recordTime = 0;
}

- (instancetype)initWithURL:(NSURL *)URL videoModelType:(ZSVideoModelType )type{
    self = [super init];
    if (self) {
        _videoFilePath = URL;
        _videoModelType = type;
        _recordMaxTime = MAXINTERP;
        [self setUpInitWithType:type];
    }
    return self;
}

- (void)appendSampleBuffer:(CMSampleBufferRef)sampleBuffer oediaType:(NSString *)mediaType{  // 开始写入数据
    if (sampleBuffer == NULL){
        NSLog(@"empty sampleBuffer");
        return;
    }
    
    @synchronized(self){
        if (self.writeState < ZSRecordStateRecording){
            NSLog(@"not ready yet");
            return;
        }
    }
    
    __weak typeof (self) weak_self = self;
    CFRetain(sampleBuffer);
    dispatch_async(self.writeQueue, ^{
        @autoreleasepool {
            @synchronized(self) {
                if (self.writeState > ZSRecordStateRecording){
                    CFRelease(sampleBuffer);
                    return;
                }
            }
            
            if (!self.isCanWrite && mediaType == AVMediaTypeVideo) {
                [self.assetWriter startWriting];
                [self.assetWriter startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
                self.isCanWrite = YES;
            }
            
            if (!weak_self.timer) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    weak_self.timer = [NSTimer zs_supportiOS_10EarlierTimer:TIMER_INTERVAL repeats:YES block:^(NSTimer *timer) {
                        [weak_self updateProgress];
                    }];
                    [NSRunLoop.currentRunLoop addTimer:weak_self.timer forMode:NSRunLoopCommonModes];
                });
            }
            
            if (mediaType == AVMediaTypeVideo) {  // 写入视频数据
                if (self.assetWriterVideoInput.readyForMoreMediaData) {
                    BOOL success = [self.assetWriterVideoInput appendSampleBuffer:sampleBuffer];
                    if (!success) {
                        @synchronized (self) {
                            [self stopWrite];
                            [self destroyWrite];
                        }
                    }
                }
            }
            
            if (mediaType == AVMediaTypeAudio) {  // 写入音频数据
                if (self.assetWriterAudioInput.readyForMoreMediaData) {
                    BOOL success = [self.assetWriterAudioInput appendSampleBuffer:sampleBuffer];
                    if (!success) {
                        @synchronized (self) {
                            [self stopWrite];
                            [self destroyWrite];
                        }
                    }
                }
            }
            CFRelease(sampleBuffer);
        }
    } );
}

// Mark - public methed
- (void)startWrite{
    self.writeState = ZSRecordStatePrepareRecording;
    if (!self.assetWriter) {
        [self setUpWriter];
    }
}

- (void)stopWrite{
    self.writeState = ZSRecordStateFinish;
    [self.timer invalidate];
    self.timer = nil;
    if(_assetWriter && _assetWriter.status == AVAssetWriterStatusWriting){
        __weak typeof (self) weak_self = self;
        dispatch_async(self.writeQueue, ^{
            [weak_self.assetWriter finishWritingWithCompletionHandler:^{
                
            }];
        });
    }
}

- (void)updateProgress{
    if (_recordTime >= _recordMaxTime) {
        [self stopWrite];
        if (self.delegate && [self.delegate respondsToSelector:@selector(finishWriting)]) {
            [self.delegate finishWriting];
        }
        return;
    }
    _recordTime += TIMER_INTERVAL;
    if (self.delegate && [self.delegate respondsToSelector:@selector(updateWritingProgress:)]) {
        [self.delegate updateWritingProgress:_recordTime/_recordMaxTime * 1.0];
    }
}

// Mark - private method
- (void)setUpWriter{  // 设置写入视频属性
    
    self.assetWriter = [AVAssetWriter assetWriterWithURL:self.videoFilePath fileType:AVFileTypeMPEG4 error:nil];
    NSInteger numPixels = self.outputSize.width * self.outputSize.height;  // 写入视频大小
    CGFloat bitsPerPixel = 6.0;  // 每像素比特
    NSInteger bitsPerSecond = numPixels * bitsPerPixel;
    
    // 码率和帧率设置
    NSDictionary *compressionProperties = @{ AVVideoAverageBitRateKey : @(bitsPerSecond),
                                             AVVideoExpectedSourceFrameRateKey : @(30),
                                             AVVideoMaxKeyFrameIntervalKey : @(30),
                                             AVVideoProfileLevelKey : AVVideoProfileLevelH264BaselineAutoLevel };
    
    // 视频属性
    self.videoCompressionSettings =
    @{ AVVideoCodecKey       : AVVideoCodecH264,
       AVVideoScalingModeKey : AVVideoScalingModeResizeAspectFill,
       AVVideoWidthKey       : @(self.outputSize.height),
       AVVideoHeightKey      : @(self.outputSize.width),
       AVVideoCompressionPropertiesKey : compressionProperties
       };
    
    _assetWriterVideoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:self.videoCompressionSettings];
    _assetWriterVideoInput.expectsMediaDataInRealTime = YES;  // expectsMediaDataInRealTime 必须设为yes，需要从capture session 实时获取数据
    _assetWriterVideoInput.transform = CGAffineTransformMakeRotation(M_PI / 2.0);
    
    // 音频设置
    self.audioCompressionSettings =
    @{
      AVEncoderBitRatePerChannelKey : @(28000),
      AVFormatIDKey                 : @(kAudioFormatMPEG4AAC),
      AVNumberOfChannelsKey         : @(1),
      AVSampleRateKey               : @(22050)
      };
    
    _assetWriterAudioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:self.audioCompressionSettings];
    _assetWriterAudioInput.expectsMediaDataInRealTime = YES;
    
    if ([_assetWriter canAddInput:_assetWriterVideoInput]) {
        [_assetWriter addInput:_assetWriterVideoInput];
    }else {
        NSLog(@"AssetWriter videoInput append Failed");
    }
    if ([_assetWriter canAddInput:_assetWriterAudioInput]) {
        [_assetWriter addInput:_assetWriterAudioInput];
    }else {
        NSLog(@"AssetWriter audioInput Append Failed");
    }
    
    self.writeState = ZSRecordStateRecording;
}

- (BOOL)checkPathUrl:(NSURL *)url{  // 检查写入地址
    if (!url) {
        return NO;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        return [[NSFileManager defaultManager] removeItemAtPath:[url path] error:nil];
    }
    
    return YES;
}

- (void)destroyWrite{
    self.assetWriter = nil;
    self.assetWriterAudioInput = nil;
    self.assetWriterVideoInput = nil;
    self.videoFilePath = nil;
    self.recordTime = 0;
    [self.timer invalidate];
    self.timer = nil;
}

- (void)dealloc{
    [self destroyWrite];
}

@end
