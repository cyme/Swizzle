//
//  NSObject+MySwizzle.m
//
//  Copyright (c) 2014 Cyril Meurillon. All rights reserved.
//

#import "NSObject+MySwizzle.h"
#import "objc/runtime.h"

@implementation NSObject (mySwizzle)

// returns a list of all subclasses of the invoking class

+ (NSArray *)subClasses
{
    int             numClasses;
    Class           *classes;
    NSMutableArray  *results;
    
    classes = NULL;
    numClasses = objc_getClassList(NULL, 0);
    classes = (Class *)malloc(sizeof(Class) * numClasses);
    numClasses = objc_getClassList(classes, numClasses);
    results = [NSMutableArray array];
    assert(results);
    
    for (NSInteger i = 0; i < numClasses; i++) {
        Class superClass = classes[i];
        do
            superClass = class_getSuperclass(superClass);
        while(superClass && (superClass != self));
        
        if (superClass == nil)
            continue;
        
        [results addObject:classes[i]];
    }
    
    free(classes);
    
    return results;
}

// return a list of all classes conforming to a protocol

+ (NSArray *)classesConformingToProtocol:(Protocol *)protocol
{
    int             numClasses;
    Class           *classes;
    NSMutableArray  *results;
    
    classes = NULL;
    numClasses = objc_getClassList(NULL, 0);
    classes = (Class *)malloc(sizeof(Class) * numClasses);
    numClasses = objc_getClassList(classes, numClasses);
    results = [NSMutableArray array];
    assert(results);
    
    for (NSInteger i = 0; i < numClasses; i++) {
        if (![classes[i] conformsToProtocol:protocol])
             continue;
    }
    
    free(classes);
    
    return results;
}

// verifies whether the invoking class implements an instance method

+ (BOOL)implements:(SEL)selector
{
    Method          *list;
    unsigned int    count;
    const char      *name;
    BOOL            result;
    
    result = FALSE;
    name = sel_getName(selector);
    list = class_copyMethodList(self, &count);
    for(int i=0; i<count; i++)
        if (!strcmp(sel_getName(method_getName(list[i])), name)) {
            result = TRUE;
            break;
        }
    free(list);
    return result;
}

// adds an instance method to the invoking class

+ (void)addMethod:(SEL)selector
{
    Method m;
    
    m = class_getInstanceMethod(self, selector);
    class_addMethod(self, selector, method_getImplementation(m), method_getTypeEncoding(m));
}

// swizzle the implementations of 2 instance methods

+ (void)swizzle:(SEL)original with:(SEL)override
{    
    Method      originalMethod;
    Method      overrideMethod;
    
    originalMethod = class_getInstanceMethod(self, original);
    overrideMethod = class_getInstanceMethod(self, override);
    if (class_addMethod(self, original, method_getImplementation(overrideMethod), method_getTypeEncoding(overrideMethod))) {
        class_replaceMethod(self, override, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, overrideMethod);
    }
}

@end
