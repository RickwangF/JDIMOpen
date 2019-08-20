//
//  ZSGIFImageView.m
//  JadeKing
//
//  Created by 张森 on 2018/11/9.
//  Copyright © 2018年 张森. All rights reserved.
//

#import "GIFImageView.h"
#import <ZSBaseUtil/ZSBaseUtil-Swift.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface GIFImageView ()
@property (nonatomic, strong) NSURL *imageURL;
@end

@implementation GIFImageView

- (void)didMoveToWindow{
    [super didMoveToWindow];
    if ([NSObject zs_isEmpty:_imageURL]) {
        return;
    }
    [self sd_setImageWithURL:_imageURL];
}

- (void)setImage:(UIImage *)image{
    UIImage *img_image = image;
    if (image.images.count > 0) {
        img_image = _isSupportGif ? image : image.images.firstObject;
    }

    [super setImage:img_image];
}

//- (void)loadGif:(NSURL *)url{
//    __weak typeof (self) weak_self = self;
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//        NSData *data = [NSData dataWithContentsOfURL:url];
//        BOOL isGif = [ZSStringTool isGifWithImageData:data];
//        if (isGif) {
//            Main_Dispatch_Async(^{
//                if (weak_self.gifDisplayType == ZSGIFImageDisplay_FL) {
//                    
//                }else{
//                    
//                    weak_self.image = [UIImage sd_imageWithGIFData:data];
//                }
//            })
//        }
//    });
//}
//
//- (void)setGifPath:(NSString *)gifPath{
//    _gifPath = gifPath;
//    [self loadGif:[NSURL fileURLWithPath:gifPath isDirectory:NO]];
//}

//- (void)setGifName:(NSString *)gifName{
//    _gifName = gifName;
//
//    NSString *doc_path = [KDOCUMENTS_ANI_FILE([ZSHotUpdateTool getHotUpdateDirectory], gifName) stringByAppendingPathComponent:gifName];
//    if ([ZSFileManager isExistsAtPath:doc_path]) {  // 加载doc文件
//        self.gifPath = doc_path;
//    }else{
//        self.gifPath = [KBUNDLE_ANI_FILE stringByAppendingPathComponent:gifName];
//    }
//}

- (void)setGifData:(NSData *)gifData{
    _gifData = gifData;
//    self.animatedImage = [FLAnimatedImage animatedImageWithGIFData:gifData];
}

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDImageLoaderProgressBlock)progressBlock completed:(SDExternalCompletionBlock)completedBlock{
    
    _imageURL = url;
    
    [super sd_setImageWithURL:url placeholderImage:placeholder options:options progress:progressBlock completed:completedBlock];
    
}

// Mark - 按住高亮
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    [super touchesBegan:touches withEvent:event];
//    self.highlighted = YES;
//}
//
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
//    [super touchesMoved:touches withEvent:event];
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
//    [super touchesEnded:touches withEvent:event];
//}
//
//- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
//    [super touchesCancelled:touches withEvent:event];
//    self.highlighted = NO;
//}

@end
