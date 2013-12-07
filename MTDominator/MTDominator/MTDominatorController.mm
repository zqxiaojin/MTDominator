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
        
        CGRect screen = [[UIScreen mainScreen] bounds];
        
        if (screen.size.height > 480)
        {
            m_checkPoint = CGPointMake(517.f,1051.f);//iPhone 5
        }
        else
        {
            m_checkPoint = CGPointMake(504.f, 900.f);//iPhone 4
        }
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
    
    UIColor* checkPointColor = [self.screemImageHelper getColorAtPoint:m_checkPoint];
    
    UIColor* expectColor = [UIColor colorWithRed:0.0f green:1.0f blue:1.0f alpha:1.0f];
    
    bool isMatch = false;
    if ([checkPointColor isEqual:expectColor])
    {
        isMatch = true;
    }
    
    [self.screemImageHelper freeImage];
    
    
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
