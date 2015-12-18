#import "ICiPhoneSixScaleEngine.h"
#import "ICMacros.h"

static ICiPhoneSixScaleEngine* engine = nil;

@implementation ICiPhoneSixScaleEngine
+(void) initialize {
  static BOOL initialized = NO;
  if (!initialized) {
    engine = [[ICiPhoneSixScaleEngine alloc] init];
  }
}

+(id) sharedInstance {
  return engine;
}

-(CGPoint) scaledPointForPoint:(CGPoint)pt withIconListDimensions:(CGSize)dim orientation:(int)orientation {
  pt.x *= (dim.width / 375);
  pt.y *= (dim.height / 535);
  if (!isiPad) {
    if (dim.width == 414) {
      pt.x += 3.5;
      if (dim.height == 604) {
        pt.y += 5;
      }
    } else if (dim.width == 640) {
      pt.x += 21.5;
      if (dim.height == 378) {
        pt.y -= 10.5;
      }
    }
  }
  return pt;
}
@end


