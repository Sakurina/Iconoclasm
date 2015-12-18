#import "ICMacros.h"
#import "ICTallScaleEngine.h"

static ICTallScaleEngine* engine = nil;

@implementation ICTallScaleEngine
+(void) initialize {
  static BOOL initialized = NO;
  if (!initialized) {
    engine = [[ICTallScaleEngine alloc] init];
  }
}

+(id) sharedInstance {
  return engine;
}

-(CGPoint) scaledPointForPoint:(CGPoint)pt withIconListDimensions:(CGSize)dim orientation:(int)orientation {
  pt.x *= (dim.width / 320);
  pt.y *= (dim.height / 439);
  if (!isiPad) {
    // iPhone 6
    if (dim.width == 375) {
      pt.x += 5.5f;
      if (dim.height == 535) {
        pt.y += 11.5f;
      }
    } else if (dim.width == 414) {  // iPhone 6 Plus
      pt.x += 9.f;
      if (dim.height == 604) {
        pt.y += 17.5f;
      }
    } else if (dim.width == 640) {
      pt.x += 30.f;
      if (dim.height == 378) {
        pt.y -= 2.5f;
      }
    }
  }
  return pt;
}
@end

