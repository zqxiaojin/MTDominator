//
//  HookObjC.h
//  MTDominator
//
//  Created by Jin on 12/7/13.
//
//

#ifndef __MTDominator__HookObjC__
#define __MTDominator__HookObjC__

bool OBJC_EXCHANGE_NEWCLASS_METHOD_TEMPLATE(const char* orgClassStr,
                                   const char* newClassStr,
                                   const char* orgSelector,
                                   const char* newSelector);

#endif /* defined(__MTDominator__HookObjC__) */
