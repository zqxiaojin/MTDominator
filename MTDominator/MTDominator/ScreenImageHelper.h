//
//  ScreenImageHelper.h
//  MTDominator
//
//  Created by Jin on 12/7/13.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ScreenImageHelper : NSObject

- (void)saveImage;

- (void)updateImage;

- (UIColor*)getColorAtPoint:(CGPoint)point;

- (void)freeImage;

@end
