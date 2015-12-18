#import "ICiPadLandscapeScaleEngine.h"

static ICiPadLandscapeScaleEngine* engine = nil;

@implementation ICiPadLandscapeScaleEngine
+(void) initialize {
  static BOOL initialized = NO;
  if (!initialized) {
    engine = [[ICiPadLandscapeScaleEngine alloc] init];
  }
}

+(id) sharedInstance {
  return engine;
}

-(CGPoint) scaledPointForPoint:(CGPoint)pt withIconListDimensions:(CGSize)dim orientation:(int)orientation {
  pt.x *= (dim.width / 1024);
  pt.y *= (dim.height / 599);
  return pt;
}
@end

