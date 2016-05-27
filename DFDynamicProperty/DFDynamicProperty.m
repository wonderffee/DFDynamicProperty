//
//  DFDynamicProperty.m
//  app
//
//  Created by Pheylix on 16/4/3.
//  Copyright © 2016年 Hanhuo. All rights reserved.
//

#import "DFDynamicProperty.h"
#import "NSObject+LcProperty.h"

static NSMutableDictionary *_propertyTypeEncodeDict;

@implementation DFDynamicProperty

//add NSString property -- copy, nonatomic
+ (BOOL)addStringProperty:(NSString *)propertyName
                 ForClass:(NSString*)className{
    if(0 == className.length || 0 == propertyName.length)return NO;
    
    Class targetClass = NSClassFromString(className);
    //check if exist
    Ivar ivar = class_getInstanceVariable(targetClass, [[NSString stringWithFormat:@"_%@", propertyName] UTF8String]);
    if (ivar) {
        return NO;
    }

    //objc_property_attribute_t
    objc_property_attribute_t type = { "T", [[NSString stringWithFormat:@"@\"%@\"",NSStringFromClass([NSString class])] UTF8String] }; //type
    objc_property_attribute_t ownership0 = { "C", "" }; // C = copy
    objc_property_attribute_t ownership = { "N", "" };  //& = retain or strong, N = nonatomic
    objc_property_attribute_t backingivar  = { "V", [[NSString stringWithFormat:@"_%@", propertyName] UTF8String] }; //instance variable
    objc_property_attribute_t attrs[] = { type, ownership0, ownership, backingivar };
    if (class_addProperty(targetClass, [propertyName UTF8String], attrs, 4)) {
        //add getter and setter method, need optimize, have not test memory problem
        [targetClass addObjectProperty:propertyName]; //from: https://github.com/lianchengjiang/LcCategoryProperty
        NSLog(@"create new property succesfully!");
        return YES;
    }
    return NO;
}

//add Object property -- strong, nonatomic
//reference http://blog.csdn.net/shengyumojian/article/details/44919695
+ (BOOL)addObjectProperty:(NSString *)propertyName
                 ForClass:(NSString*)className
        withPropertyClass:(NSString*)propertyClassName {
    if(0 == className.length || 0 == propertyName.length || 0 == propertyClassName.length) return NO;
    
    Class targetClass = NSClassFromString(className);
    Class valueClass = NSClassFromString(propertyClassName);
    
    //check if exist
    Ivar ivar = class_getInstanceVariable(targetClass, [[NSString stringWithFormat:@"_%@", propertyName] UTF8String]);
    if (ivar) {
        return NO;
    }

    //objc_property_attribute_t
    objc_property_attribute_t type = { "T", [[NSString stringWithFormat:@"@\"%@\"",NSStringFromClass(valueClass)] UTF8String] };
    objc_property_attribute_t ownership0 = { "&", "" }; //& = retain or strong
    objc_property_attribute_t ownership = { "N", "" }; // N = nonatomic
    objc_property_attribute_t backingivar  = { "V", [[NSString stringWithFormat:@"_%@", propertyName] UTF8String] };
    objc_property_attribute_t attrs[] = { type, ownership0, ownership, backingivar };
    if (class_addProperty(targetClass, [propertyName UTF8String], attrs, 4)) {
        //add getter and setter method, need optimize, have not test memory problem
        [targetClass addObjectProperty:propertyName];
        NSLog(@"create new property succesfully!");
        return YES;
    }
    return NO;
}

//add Common property, need more test
+ (BOOL)addCommonProperty:(NSString *)propertyName
                 ForClass:(NSString*)className
                withAttri:(NSString*)strAttrParams
        withPropertyClass:(Class)valueClass
     withCustomEncodeType:(NSString*)customEncodeType
{
    if(0 == className.length || 0 == propertyName.length) return NO;
    Class targetClass = NSClassFromString(className);
    
    if (!(strAttrParams.length > 0 || valueClass || customEncodeType.length > 0)) {  //for sure that at least one value is valid
        return NO;
    }
    
    //check if exist
    Ivar ivar = class_getInstanceVariable(targetClass, [[NSString stringWithFormat:@"_%@", propertyName] UTF8String]);
    if (ivar) {
        return NO;
    }
    
    NSArray *argStrArr = [strAttrParams componentsSeparatedByString:@","];
    if (!(argStrArr.count > 0 || valueClass || customEncodeType.length > 0)) {  //for sure that at least one value is valid
        return NO;
    }
    
    if (!_propertyTypeEncodeDict) {
        _propertyTypeEncodeDict = [[NSMutableDictionary alloc] init];
#define JP_DEFINE_TYPE_ENCODE_CASE(_type) \
[_propertyTypeEncodeDict setObject:[NSString stringWithUTF8String:@encode(_type)] forKey:@#_type];\

        JP_DEFINE_TYPE_ENCODE_CASE(id);
        JP_DEFINE_TYPE_ENCODE_CASE(BOOL);
        JP_DEFINE_TYPE_ENCODE_CASE(int);
        JP_DEFINE_TYPE_ENCODE_CASE(BOOL);
        JP_DEFINE_TYPE_ENCODE_CASE(char);
        JP_DEFINE_TYPE_ENCODE_CASE(short);
        JP_DEFINE_TYPE_ENCODE_CASE(unsigned short);
        JP_DEFINE_TYPE_ENCODE_CASE(unsigned int);
        JP_DEFINE_TYPE_ENCODE_CASE(long);
        JP_DEFINE_TYPE_ENCODE_CASE(unsigned long);
        JP_DEFINE_TYPE_ENCODE_CASE(long long);
        JP_DEFINE_TYPE_ENCODE_CASE(float);
        JP_DEFINE_TYPE_ENCODE_CASE(double);
        JP_DEFINE_TYPE_ENCODE_CASE(CGFloat);
        JP_DEFINE_TYPE_ENCODE_CASE(CGSize);
        JP_DEFINE_TYPE_ENCODE_CASE(CGRect);
        JP_DEFINE_TYPE_ENCODE_CASE(CGPoint);
        JP_DEFINE_TYPE_ENCODE_CASE(CGVector);
        JP_DEFINE_TYPE_ENCODE_CASE(NSRange);
        JP_DEFINE_TYPE_ENCODE_CASE(UIEdgeInsets);
        JP_DEFINE_TYPE_ENCODE_CASE(NSInteger);
        JP_DEFINE_TYPE_ENCODE_CASE(Class);
        JP_DEFINE_TYPE_ENCODE_CASE(SEL);
        JP_DEFINE_TYPE_ENCODE_CASE(void*);
        
        [_propertyTypeEncodeDict setObject:@"@?" forKey:@"block"];
        [_propertyTypeEncodeDict setObject:@"^@" forKey:@"id*"];
    }
    
    NSMutableDictionary *dicAttribute = [[NSMutableDictionary alloc] initWithCapacity:5];
    
    //save type name and variable name indicAttributeFixed, type name must be first，variable name must be last
    NSMutableDictionary *dicAttributeFixed = [[NSMutableDictionary alloc] initWithCapacity:2];
    
    BOOL isHasType = NO;
    
    if (valueClass) {
        [dicAttributeFixed setObject:[NSString stringWithFormat:@"@\"%@\"",NSStringFromClass(valueClass)] forKey:@"T"];
        isHasType = YES;
    }
    else if (customEncodeType.length > 0) {
        NSString *returnEncode = nil;
        returnEncode = _propertyTypeEncodeDict[customEncodeType];  //first search in dictionary
        if(returnEncode){
            [dicAttributeFixed setObject:returnEncode forKey:@"T"];
            isHasType = YES;
        }
        else{
            [dicAttributeFixed setObject:customEncodeType forKey:@"T"];
            isHasType = YES;
        }
    }
    
    [dicAttributeFixed setObject:[NSString stringWithFormat:@"_%@", propertyName] forKey:@"V"];
    
    if(!isHasType){
        NSLog(@"type must be assigned!");
    }
    
    NSInteger index = 0;
    
    for (NSInteger index = 0; index < argStrArr.count; index++) {
        NSString *str = [argStrArr objectAtIndex:index];

        if ([str isEqualToString:@"copy"]) {
            [dicAttribute setObject:@"" forKey:@"C"];
        }
        else if ([str isEqualToString:@"retain"] ||  [str isEqualToString:@"strong"]) {
            [dicAttribute setObject:@"" forKey:@"&"];
        }
        else if ([str isEqualToString:@"nonatomic"]) {
            [dicAttribute setObject:@"" forKey:@"N"];
        }
        else if ([str isEqualToString:@"readonly"]) {
            [dicAttribute setObject:@"" forKey:@"R"];
        }
        else if ([str isEqualToString:@"weak"]) {
            [dicAttribute setObject:@"" forKey:@"W"];
        }
        else if ([str isEqualToString:@"dynamic"]) {
            [dicAttribute setObject:@"" forKey:@"D"];
        }
        else if ([str hasPrefix:@"getter="]) {
            NSString *strGetter = [str substringFromIndex:7];
            [dicAttribute setObject:strGetter forKey:@"G"];
        }
        else if ([str hasPrefix:@"setter="]) {
            NSString *strSetter = [str substringFromIndex:7];
            [dicAttribute setObject:strSetter forKey:@"S"];
        }
    }
    
    NSUInteger countDic = dicAttribute.count;
    objc_property_attribute_t attrs[countDic];
    
    NSString* valueType = [dicAttributeFixed objectForKey:@"T"];
    objc_property_attribute_t attrType = {[@"T" UTF8String], [valueType UTF8String]};
    attrs[0] = attrType;  //must be first
    
    index = 0;
    for (NSString* key in dicAttribute) {
        NSString* value = [dicAttribute objectForKey:key];
        objc_property_attribute_t attr = {[key UTF8String], [value UTF8String]};
        attrs[index+1] = attr;
        index++;
    }
    
    NSString* valueName = [dicAttributeFixed objectForKey:@"V"];
    objc_property_attribute_t attrName = {[@"V" UTF8String], [valueName UTF8String]};
    attrs[index] = attrName;  //must be last
    
    unsigned int count = sizeof(attrs) / sizeof(attrs[0]);
    if (class_addProperty(targetClass, [propertyName UTF8String], attrs, count)) {
        //add getter and setter method, need more optimize for assign, weak, have not test memory problem
        [targetClass addObjectProperty:propertyName];
        NSLog(@"create new property succesfully!");
        return YES;
    }
    

    return NO;
}

@end
