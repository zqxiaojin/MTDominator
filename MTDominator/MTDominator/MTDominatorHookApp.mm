#line 1 "/Users/jin/Desktop/opensource/MTDominator/MTDominator/MTDominatorHookApp.xm"









#import "MTDominatorController.h"

#include <logos/logos.h>
#include <substrate.h>
@class UIApplication; 
static void (*_logos_orig$_ungrouped$UIApplication$setDelegate$)(UIApplication*, SEL, id); static void _logos_method$_ungrouped$UIApplication$setDelegate$(UIApplication*, SEL, id); 

#line 12 "/Users/jin/Desktop/opensource/MTDominator/MTDominator/MTDominatorHookApp.xm"




static void _logos_method$_ungrouped$UIApplication$setDelegate$(UIApplication* self, SEL _cmd, id delegate) {


	_logos_orig$_ungrouped$UIApplication$setDelegate$(self, _cmd, delegate);
    
    [[MTDominatorController instance] onAppSetDelegate:delegate];
	
	
}



static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$UIApplication = objc_getClass("UIApplication"); MSHookMessageEx(_logos_class$_ungrouped$UIApplication, @selector(setDelegate:), (IMP)&_logos_method$_ungrouped$UIApplication$setDelegate$, (IMP*)&_logos_orig$_ungrouped$UIApplication$setDelegate$);} }
#line 28 "/Users/jin/Desktop/opensource/MTDominator/MTDominator/MTDominatorHookApp.xm"
