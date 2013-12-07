//
//  HookObjC.cpp
//  MTDominator
//
//  Created by Jin on 12/7/13.
//
//

#include "HookObjC.h"
#import <objc/runtime.h>

bool OBJC_EXCHANGE_NEWCLASS_METHOD_TEMPLATE(const char* orgClassStr,const char* orgSelector,
                                            const char* newClassStr,const char* newSelector)
{
    Class orgClass = objc_getClass(orgClassStr);
    Class newClass = objc_getClass(newClassStr);
    
    if(!orgClass || !newClass)
    {
        return false;
    }
    
    SEL orgMethod = sel_registerName(orgSelector);
    SEL newMethod = sel_registerName(newSelector);
    
    
    Method newMethodIns = class_getInstanceMethod(newClass, newMethod);
    
    /*在旧的类添加类新方法后,那么只需要交换原有的方法即可*/
    Method orgMethodIns = class_getInstanceMethod(orgClass, orgMethod);
    
    /*防止方法不存在*/
    if(!orgMethodIns || !newMethodIns)
    {
        return false;
    }
    

    IMP newMethodIMP = method_getImplementation(newMethodIns);
    const char *newMethodStr = method_getTypeEncoding(newMethodIns);
    class_addMethod(orgClass, newMethod, newMethodIMP, newMethodStr);
    newMethodIns = class_getInstanceMethod(orgClass, newMethod);
    
    
    method_exchangeImplementations(orgMethodIns, newMethodIns);
    
    
    return true;
}