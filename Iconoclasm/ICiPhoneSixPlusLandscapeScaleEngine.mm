#import "ICiPhoneSixPlusLandscapeScaleEngine.h"

static ICiPhoneSixPlusLandscapeScaleEngine* engine = nil;

@implementation ICiPhoneSixPlusLandscapeScaleEngine
+(void) initialize {
  static BOOL initialized = NO;
  if (!initialized) {
    engine = [[ICiPhoneSixPlusLandscapeScaleEngine alloc] init];
  }
}

+(id) sharedInstance {
  return engine;
}

-(CGPoint) scaledPointForPoint:(CGPoint)pt withIconListDimensions:(CGSize)dim orientation:(int)orientation {
  pt.x *= (dim.width / 640);
  pt.y *= (dim.height / 378);
  return pt;
}
@end


