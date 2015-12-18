#import <UIKit/UIDevice.h>

// iPad identification
#define SBIMINSTANCE ((kCFCoreFoundationVersionNumber < 790.00) ? CHSharedInstance(SBIconModel) : [CHSharedInstance(SBIconController) model])
#define kCFCoreFoundationVersionNumber_iPhoneOS_3_2 478.61
//#define isiPad (kCFCoreFoundationVersionNumber == kCFCoreFoundationVersionNumber_iPhoneOS_3_2)
#define isiPad ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

// dict is easy grid?
#define isEasyGrid(x) [[x objectForKey:@"EasyGrid"] boolValue]

// which page is this?
#define whichPage_32(iL) (int)[CHSharedInstance(SBIconModel) indexOfIconList:iL]
#define whichPage_model(model) (unsigned)[[CHSharedInstance(SBIconModel) rootFolder] indexOfIconList:model]
#define whichPage_view(iL) whichPage_model([iL model])

// assuring you're not hooking the wrong icon view/model
#define isDock_32(iL) [iL isKindOfClass:NSClassFromString(@"SBButtonBar")]
#define notVirginModel(iM) ([iM class] != CHClass(SBIconListModel))
//#define notVirginView(iL) ([iL class] != CHClass(SBIconListView))
#define notVirginView(iL) ( \
    ([iL class] == CHClass(SBFolderIconListView)) || \
    ([iL class] == CHClass(SBDockIconListView)) || \
    ([iL class] == CHClass(SBNewsstandIconListView)) \
    )

#define maxIconsForPage(pageNum) [[layoutForPage(pageNum) origins] count]

// per-page wrapover stuff
#define getNextPage_view(index) [CHSharedInstance(SBIconController) iconListViewAtIndex:index+1 \
                                                                               inFolder:[SBIMINSTANCE rootFolder] \
                                                                      createIfNecessary:YES]
#define getNextPage_model(index) [getNextPage_view(index) model]

#define easyGridOn [defaultLayout isKindOfClass:[ICGridLayout class]]

#define ICPref(key) CFPreferencesCopyAppValue((CFStringRef) key,(CFStringRef) @"net.r-ch.iconoclasm")

#define Nint(i) [NSNumber numberWithInt:i]
#define Nbool(i) [NSNumber numberWithBool:i]
