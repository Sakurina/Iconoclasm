#import "ICiPhoneSixPlusPortraitScaleEngine.h"

static ICiPhoneSixPlusPortraitScaleEngine* engine = nil;

@implementation ICiPhoneSixPlusPortraitScaleEngine
+(void) initialize {
  static BOOL initialized = NO;
  if (!initialized) {
    engine = [[ICiPhoneSixPlusPortraitScaleEngine alloc] init];
  }
}

+(id) sharedInstance {
  return engine;
}

-(CGPoint) scaledPointForPoint:(CGPoint)pt withIconListDimensions:(CGSize)dim orientation:(int)orientation {
  pt.x *= (dim.width / 414);
  pt.y *= (dim.height / 604);
  return pt;
}
@end


