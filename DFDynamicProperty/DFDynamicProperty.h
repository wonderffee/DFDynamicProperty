//
//  DFDynamicProperty.h
//  app
//
//  Created by Pheylix on 16/4/3.
//  Copyright © 2016年 Hanhuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>



@interface DFDynamicProperty : NSObject

+ (void)addStrPropertyForTargetClass:(Class)targetClass Name:(NSString *)propertyName;
+ (void)addObjectPropertyForTargetClass:(Class)targetClass withPropertyName:(NSString *)propertyName withValueClass:(Class)valueClass;


+ (BOOL)classAddPropertyOC:(Class)targetClass withPropertyName:(NSString *)propertyName andAttrs:(objc_property_attribute_t[])attrs;

+ (void)addPropertyForTargetClass:(Class)tagetClass
                 withPropertyName:(NSString *)propertyName
                        withAttri:(NSString*)strAttrParams
                    withvalueType:(Class)valueClass
             withCustomEncodeType:(NSString*)strEncodeType;


+ (void)addPropertyWithtarget:(Class)targetClass withPropertyName:(NSString *)propertyName withValueClass:(Class)valueClass;

@end
