//
//  MTDominatorController.m
//  MTDominator
//
//  Created by Jin on 12/7/13.
//
//

#import "MTDominatorController.h"
#import "HookObjC.h"
#import <UIKit/UIKit.h>
#import "ScreenImageHelper.h"
#import "ClickEventWrapper.h"

#import <sys/utsname.h>

NSString* machineName();

enum State
{
    EIdle
    ,ERuning
};

@interface MTDominatorController ()
{
    State       m_state;
    UIButton*   m_clickButton;
    CGPoint     m_checkPoint;
}
@property (nonatomic,retain)ScreenImageHelper* screemImageHelper;

@property (nonatomic,retain)NSTimer* scriptDelayTimer;

@end

@implementation MTDominatorController
@synthesize screemImageHelper = m_screemImageHelper;
@synthesize scriptDelayTimer = m_scriptDelayTimer;

+ (instancetype)instance
{
    static MTDominatorController* ins = [MTDominatorController new];
    return ins;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        m_screemImageHelper = [ScreenImageHelper new];

        NSString* name = machineName();
//        NSLog(@"MTDominator enable on %@", name);
//        if ([name hasPrefix:@"iPad4"])///iPad
//        {
//            m_checkPoint = CGPointMake(1160/2, 1930/2);
//        }
//        else
            if ([name hasPrefix:@"iPhone5"])
        {
            m_checkPoint = CGPointMake(517.f,1051.f);//iPhone 5
        }
        else
        {
            m_checkPoint = CGPointMake(504.f, 900.f);//iPhone 4,iPad
        }
        
        NSLog(@"MTDominator enable on %@  pos :%f,%f", name, m_checkPoint.x, m_checkPoint.y);

        
    }
    return self;
}

- (void)onAppSetDelegate:(id)delegate
{
    const char* hostClass = [NSStringFromClass([delegate class]) UTF8String];
    
    OBJC_EXCHANGE_NEWCLASS_METHOD_TEMPLATE(hostClass, "application:didFinishLaunchingWithOptions:"
                                        , "MTDominatorController", "_application:didFinishLaunchingWithOptions:");

    
}

- (BOOL)_application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    BOOL result = [self _application:application didFinishLaunchingWithOptions:launchOptions];
    
    [[MTDominatorController instance] initializeWithApplication:application];
    
    return result;
}

- (void)initializeWithApplication:(UIApplication*)application
{
    UIWindow* topWindow = [[application windows] firstObject];

  
    UIButton* clickButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [clickButton setBackgroundColor:[UIColor clearColor]];
    [clickButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [clickButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [topWindow addSubview:clickButton];
    [clickButton setFrame:CGRectMake(0, 0, 40, 50)];
    
    
    [clickButton addTarget:self action:@selector(buttonOutsideClick:) forControlEvents:UIControlEventTouchUpOutside];
    
    m_clickButton = [clickButton retain];
    
    [self setState:EIdle];
    
    
#if 0
    clickButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [clickButton setBackgroundColor:[UIColor clearColor]];
    [clickButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [clickButton addTarget:self action:@selector(buttonClickTest:) forControlEvents:UIControlEventTouchUpInside];
    [topWindow addSubview:clickButton];
    [clickButton setFrame:CGRectMake(40, 0, 40, 50)];
    [clickButton setTitle:@"test" forState:UIControlStateNormal];
#endif
}

- (void)setState:(State)state
{
    m_state = state;
    switch (m_state)
    {
        case EIdle:
            [m_clickButton setTitle:@"On" forState:UIControlStateNormal];
            break;
        case ERuning:
            [m_clickButton setTitle:@"Off" forState:UIControlStateNormal];
        default:
            break;
    }
    
}

- (void)buttonClickTest:(UIButton*)sender
{
    sendclickevent(m_checkPoint, UITouchPhaseBegan);
    [self.scriptDelayTimer invalidate];
    self.scriptDelayTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                             target:self
                                                           selector:@selector(touchUp)
                                                           userInfo:nil
                                                            repeats:NO];
}

- (void)touchUpTest
{
    sendclickevent(m_checkPoint, UITouchPhaseEnded);
    
    [self.scriptDelayTimer invalidate];
}

- (void)buttonOutsideClick:(UIButton*)sender
{
    [self.screemImageHelper saveImage];
}

- (void)buttonClick:(UIButton*)sender
{
    switch (m_state)
    {
        case EIdle:
            [self run];
            break;
        case ERuning:
            [self cancel];
        default:
            break;
    }
}

- (void)run
{
    [self setState:ERuning];
    [self startScript];
    
//    [self.screemImageHelper saveImage];
}


- (void)cancel
{
    [self setState:EIdle];
    [m_scriptDelayTimer invalidate];
    self.scriptDelayTimer = nil;
}



- (void)startScript
{
    [self checkAndClick];
}

- (void)checkAndClick
{
    if (m_state != ERuning)
    {
        return;
    }
    
    [self.screemImageHelper updateImage];
    
    ColorStruct expectColor = {0,255,255};
    ColorStruct checkPointColor;
    [self.screemImageHelper getColorAtPoint:m_checkPoint withOutColor:checkPointColor];
//    UIColor* checkPointColor = [self.screemImageHelper getColorAtPoint:m_checkPoint];
    
//    UIColor* expectColor = [UIColor colorWithRed:0.0f green:1.0f blue:1.0f alpha:1.0f];
//    0.0745098 0.862745 0.886275 1
//    0.0745098 0.862745 0.886275
    bool isMatch = false;
    if (expectColor.r == checkPointColor.r
        && expectColor.g == checkPointColor.g
        && expectColor.b == checkPointColor.b)
    {
        isMatch = true;
    }
    
    [self.screemImageHelper freeImage];
    
//    NSLog(@"color %d,%d,%d %d", checkPointColor.r, checkPointColor.g, checkPointColor.b, isMatch);
    
    
    if (isMatch)
    {
        sendclickevent(m_checkPoint, UITouchPhaseBegan);
        [self.scriptDelayTimer invalidate];
        self.scriptDelayTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                                 target:self
                                                               selector:@selector(touchUp)
                                                               userInfo:nil
                                                                repeats:NO];
    }
    else
    {
        [self.scriptDelayTimer invalidate];
        self.scriptDelayTimer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                                 target:self
                                                               selector:@selector(checkAndClick)
                                                               userInfo:nil
                                                                repeats:NO];
    }
}

- (void)touchUp
{
    sendclickevent(m_checkPoint, UITouchPhaseEnded);
    
    [self.scriptDelayTimer invalidate];
    self.scriptDelayTimer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                             target:self
                                                           selector:@selector(checkAndClick)
                                                           userInfo:nil
                                                            repeats:NO];
}




@end


NSString* machineName()
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

