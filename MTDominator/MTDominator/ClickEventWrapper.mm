//
//  ClickEventWrapper.cpp
//  MTDominator
//
//  Created by Jin on 12/7/13.
//
//

#include "ClickEventWrapper.h"

#import "GSEvent.h"

static float getSystemVersion()
{
	static float versionValue = -1.0;
	if(versionValue < 0.f)
	{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		NSString *os_verson = [[UIDevice currentDevice] systemVersion];
		
		NSArray* versionNumbers = [os_verson componentsSeparatedByString:@"."];
		os_verson = @"";
		for (int i = 0; i < versionNumbers.count; i++)
		{
			os_verson = [os_verson stringByAppendingString:[versionNumbers objectAtIndex:i]];
			if (i == 0)
			{
				os_verson = [os_verson stringByAppendingString:@"."];
			}
		}
		
		versionValue = [os_verson floatValue];
		[pool release ];
	}
	return versionValue;
}

#import <dlfcn.h>
// Framework Paths
#define SBSERVPATH  "/System/Library/PrivateFrameworks/SpringBoardServices.framework/SpringBoardServices"

typedef int (*SBSSpringBoardServerPort)();
typedef void *(*SBFrontmostApplicationDisplayIdentifier)(mach_port_t *port, char *result);

static mach_port_t getFrontMostAppPort()
{
//    mach_port_t *port;
//    void *lib = dlopen(SBSERVPATH, RTLD_LAZY);
//    SBSSpringBoardServerPort portFun = (SBSSpringBoardServerPort)dlsym(lib, "SBSSpringBoardServerPort");
//    port = (mach_port_t *)portFun();
//    dlclose(lib);
//    
//    SBFrontmostApplicationDisplayIdentifier idenFun = (SBFrontmostApplicationDisplayIdentifier)dlsym(lib, "SBFrontmostApplicationDisplayIdentifier");
//    
//    
//    char appId[256];
//    memset(appId, 0, sizeof(appId));
//    idenFun(port, appId);
//    NSString * frontmostApp=[NSString stringWithFormat:@"%s",appId];
//    NSLog(@"frontmostApp %@ " , frontmostApp);
//    if([frontmostApp length] == 0)
//        return GSGetPurpleSystemEventPort();
//    else
//        return GSCopyPurpleNamedPort(appId);
    
    NSString* bundle = [[NSBundle mainBundle] bundleIdentifier];
//    NSLog(@"bundle ----- %@", bundle);
    mach_port_t result = GSCopyPurpleNamedPort([bundle UTF8String]);
//    NSLog(@"--------%d", (int)result);
    return result;
}

void sendclickevent(CGPoint point ,UITouchPhase phase)
{
    point.x /= 2;
    point.y /= 2;
    
//    NSLog(@"click %f , %f , %d", point.x , point.y , phase);
    
    
    uint8_t touchEvent[sizeof(GSEventRecord) + sizeof(GSHandInfo) + sizeof(GSPathInfo)];
    struct GSTouchEvent {
        GSEventRecord record;
        GSHandInfo    handInfo;
    } * event = (struct GSTouchEvent*) &touchEvent;
    bzero(event, sizeof(event));

    
    
    event->record.type = kGSEventHand;
    event->record.windowLocation = point;
    event->record.timestamp = GSCurrentEventTimestamp();
    //NSLog(@"Timestamp GSCurrentEventTimestamp: %llu",GSCurrentEventTimestamp());
    event->record.infoSize = sizeof(GSHandInfo) + sizeof(GSPathInfo);
    event->handInfo.type = (phase == UITouchPhaseBegan) ? kGSHandInfoTypeTouchDown : kGSHandInfoTypeTouchUp;
    
    //must have the following line
    event->handInfo.x52 = 1;
    
    //below line is for ios4
    if (getSystemVersion() < 5.0)
    {
        event->handInfo.pathInfosCount = 1;
    }
    
    bzero(&event->handInfo.pathInfos[0], sizeof(GSPathInfo));
    event->handInfo.pathInfos[0].pathIndex     = 2;
    //following 2 lines, they are by default
    event->handInfo.pathInfos[0].pathMajorRadius = 1.0;
    event->handInfo.pathInfos[0].pathPressure = 1.0;
    
    //event->handInfo.pathInfos[0].pathIdentity  = 2;
    event->handInfo.pathInfos[0].pathProximity = (phase == UITouchPhaseBegan) ? 0x03 : 0x00;
    //event->handInfo.pathInfos[0].pathProximity = action;
    event->handInfo.pathInfos[0].pathLocation  = point;
    
    
    static mach_port_t port = getFrontMostAppPort();
    
    GSEventRecord* record = (GSEventRecord*)event;
    GSSendEvent(record, port);
}


