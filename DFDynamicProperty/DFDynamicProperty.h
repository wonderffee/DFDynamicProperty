//
//  DFDynamicProperty.h
//  app
//
//  Created by Pheylix on 16/4/3.
//  Copyright © 2016年 Hanhuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface DFDynamicProperty : NSObject

//add NSString property
+ (BOOL)addStringProperty:(NSString *)propertyName
                 ForClass:(NSString*)className;

//add Object property
+ (BOOL)addObjectProperty:(NSString *)propertyName
                 ForClass:(NSString*)className
        withPropertyClass:(NSString*)propertyClassName;

+ (BOOL)addCommonProperty:(NSString *)propertyName
                 ForClass:(NSString*)className
                withAttri:(NSString*)strAttrParams
        withPropertyClass:(Class)valueClass
     withCustomEncodeType:(NSString*)strEncodeType;

@end
