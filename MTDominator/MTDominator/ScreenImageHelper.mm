//
//  ScreenImageHelper.m
//  MTDominator
//
//  Created by Jin on 12/7/13.
//
//

#import "ScreenImageHelper.h"


extern "C" UIImage * _UICreateScreenUIImage();



@interface ScreenImageHelper ()

@property (nonatomic,retain)UIImage* currentImage;

@end

@implementation ScreenImageHelper
@synthesize currentImage = m_currentImage;

- (void)saveImage
{
    if (self.currentImage == nil)
    {
        [self updateImage];
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"sssImage.png"];
    
    // Save image.
    [UIImagePNGRepresentation(self.currentImage) writeToFile:filePath atomically:YES];
}

- (void)updateImage
{
    self.currentImage = [_UICreateScreenUIImage() autorelease];
    
//    NSLog(@"image size :%f,%f" , self.currentImage.size.width , self.currentImage.size.height);
}
- (void)freeImage;
{
    self.currentImage = nil;
}

- (UIColor *)getColorAtPoint:(CGPoint)point
{
    CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(self.currentImage.CGImage));
    const UInt8* data = CFDataGetBytePtr(pixelData);
    CGSize imageSize = self.currentImage.size;
    imageSize.width *= self.currentImage.scale;
    imageSize.height *= self.currentImage.scale;
    int pixelInfo = ((imageSize.width  * point.y) + point.x ) * 4; // The image is png
    
    UInt8 red = data[pixelInfo];         // If you need this info, enable it
    UInt8 green = data[(pixelInfo + 1)]; // If you need this info, enable it
    UInt8 blue = data[pixelInfo + 2];    // If you need this info, enable it
    UInt8 alpha = data[pixelInfo + 3];     // I need only this info for my maze game
    CFRelease(pixelData);
    
    UIColor* color = [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha/255.0f]; // The pixel color info
    
    return color;

}

@end
