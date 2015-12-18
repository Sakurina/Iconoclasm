#import "ICiPadScaleEngine.h"

static ICiPadScaleEngine* engine = nil;

@implementation ICiPadScaleEngine
+(void) initialize {
  static BOOL initialized = NO;
  if (!initialized) {
    engine = [[ICiPadScaleEngine alloc] init];
  }
}

+(id) sharedInstance {
  return engine;
}

-(CGPoint) scaledPointForPoint:(CGPoint)pt withIconListDimensions:(CGSize)dim orientation:(int)orientation {
  pt.x *= (dim.width / 768);
  pt.y *= (dim.height / 845);
  return pt;
}
@end

