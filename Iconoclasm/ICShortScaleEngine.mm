#import "ICShortScaleEngine.h"
#import "ICMacros.h"
#import <CoreGraphics/CGGeometry.h>
#import <UIKit/UIKit.h>

static ICShortScaleEngine* engine = nil;

@implementation ICShortScaleEngine
+(void) initialize {
  static BOOL initialized = NO;
  if (!initialized) {
    engine = [[ICShortScaleEngine alloc] init];
  }
}

+(id) sharedInstance {
  return engine;
}

-(CGPoint) scaledPointForPoint:(CGPoint)pt withIconListDimensions:(CGSize)dim orientation:(int)orientation {
  pt.x *= (dim.width / 320);
  pt.y *= (dim.height / 350);
  if (isiPad) {
    if ((dim.width == 539) && (dim.height == 523)) {
      // Extras Layout (iOS 9/iPad)
      pt.x += 16;
      pt.y += 8;
      return pt;
    }
    if ((dim.width != 320) && (dim.width != 480)) {
      pt.x += 36;
      pt.y += 17;
      if (dim.width > 768)
        pt.x += 25;
      if (dim.height > 599)
        pt.y += 23;
    } else if (dim.width == 480)
      pt.x += 16;
  } else {
    // iPhone 6
    if (dim.width == 375) {
      pt.x += 5.5f;
      if (dim.height == 535) {
        pt.y += 23.5f;
      }
    } else if (dim.width == 414) {  // iPhone 6 Plus
      pt.x += 9;
      if (dim.height == 604) {
        pt.y += 31.5;
      }
    } else if (dim.width == 640) {
      pt.x += 30;
      if (dim.height == 378) {
        pt.y += 6;
      }
    }
  }
  return pt;
}
@end

