//
//  NSObject+MySwizzle.h
//
//  Copyright (c) 2014 Cyril Meurillon. All rights reserved.
//

#import <Foundation/Foundation.h>

// useful swizzle utility methods

@interface NSObject (MySwizzle)

// returns a list of all subclasses of the invoking class
+ (NSArray *)subClasses;

// return a list of all classes conforming to a protocol
+ (NSArray *)classesConformingToProtocol:(Protocol *)protocol;

// verifies whether the invoking class implements an instance method
+ (BOOL)implements:(SEL)selector;

// adds an instance method to the invoking class
+ (void)addMethod:(SEL)selector;

// swizzle the implementations of 2 instance methods
+ (void)swizzle:(SEL)original with:(SEL)override;

@end
