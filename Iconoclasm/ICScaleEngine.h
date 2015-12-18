#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

// ICScaleEngines are classes that take a raw point from a layout plist
// and scales it accordingly to the icon list dimensions that are passed.

@protocol ICScaleEngine
+(id) sharedInstance;
-(CGPoint) scaledPointForPoint:(CGPoint)pt withIconListDimensions:(CGSize)dim orientation:(int)orientation;
@end
