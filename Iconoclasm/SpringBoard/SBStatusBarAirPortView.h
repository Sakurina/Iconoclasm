/**
 * This header is generated by class-dump-z 0.1-11o.
 * class-dump-z is Copyright (C) 2009 by KennyTM~, licensed under GPLv3.
 */

#import "SBStatusBarContentView.h"
#import "SpringBoard-Structs.h"


@interface SBStatusBarAirPortView : SBStatusBarContentView {
	int _dataConnectionType;
	int _signalStrength;
	unsigned _showsAirPortBars : 1;
	unsigned _showsCellDataIndicator : 1;
	unsigned _isPolling : 1;
	unsigned _didSetIndicatorFlags : 1;
	BOOL _showsAirPortView;
	float _overlap;
}
@property(assign, getter=isVisible) BOOL visible;
@property(assign) float overlap;
-(id)init;
-(void)dealloc;
-(void)start;
-(void)stop;
-(void)setAirPortStrength:(int)strength;
-(void)setShowsAirPortBars:(BOOL)bars;
-(void)setShowsCellDataIndicator:(BOOL)indicator;
-(void)setDataConnectionType:(int)type;
-(BOOL)showsIndicator;
-(void)dataConnectionTypeChanged;
-(int)priority;
-(void)drawRect:(CGRect)rect;
-(void)touchesEnded:(id)ended withEvent:(id)event;
-(float)padding;
@end

