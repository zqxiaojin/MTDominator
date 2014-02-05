//
//  ScreenImageHelper.h
//  MTDominator
//
//  Created by Jin on 12/7/13.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

struct ColorStruct
{
    unsigned r,g,b;
    
};

@interface ScreenImageHelper : NSObject

- (void)saveImage;

- (void)updateImage;

- (void)getColorAtPoint:(CGPoint)point withOutColor:(ColorStruct&)colorStruct;

- (void)freeImage;

@end
