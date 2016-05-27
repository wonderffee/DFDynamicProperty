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

+ (id)getPropertyValueWithTarget:(id)target withPropertyName:(NSString *)propertyName {
    //先判断有没有这个属性，没有就添加，有就直接赋值
    Ivar ivar = class_getInstanceVariable([target class], [[NSString stringWithFormat:@"_%@", propertyName] UTF8String]);
    if (ivar) {
        return object_getIvar(target, ivar);
    }
    
    ivar = class_getInstanceVariable([target class], "_dictCustomerProperty");  //basicsViewController里面有个_dictCustomerProperty属性
    NSMutableDictionary *dict = object_getIvar(target, ivar);
    if (dict && [dict objectForKey:propertyName]) {
        return [dict objectForKey:propertyName];
    } else {
        return nil;
    }
}

//在目标targetClass上添加属性，属性名propertyname
//copy, nonatomic
+ (void)addStrPropertyForTargetClass:(Class)targetClass Name:(NSString *)propertyName{
    
    //先判断有没有这个属性，没有就添加，有就直接赋值
    Ivar ivar = class_getInstanceVariable(targetClass, [[NSString stringWithFormat:@"_%@", propertyName] UTF8String]);
    if (ivar) {
        return;
    }

    //objc_property_attribute_t所代表的意思可以调用getPropertyNameList打印，大概就能猜出
    objc_property_attribute_t type = { "T", [[NSString stringWithFormat:@"@\"%@\"",NSStringFromClass([NSString class])] UTF8String] };
    objc_property_attribute_t ownership0 = { "C", "" }; // C = copy
    objc_property_attribute_t ownership = { "N", "" };
    objc_property_attribute_t backingivar  = { "V", [[NSString stringWithFormat:@"_%@", propertyName] UTF8String] };
    objc_property_attribute_t attrs[] = { type, ownership0, ownership, backingivar };
    if (class_addProperty(targetClass, [propertyName UTF8String], attrs, 4)) {
        //添加get和set方法
        [targetClass addObjectProperty:propertyName];
        DDLogDebug(@"创建属性Property成功");
    }
}

//在目标target上添加属性，属性名propertyname，值value
//参考http://blog.csdn.net/shengyumojian/article/details/44919695
//retain, nonatomic
+ (void)addObjectPropertyForTargetClass:(Class)targetClass withPropertyName:(NSString *)propertyName withValueClass:(Class)valueClass {
    //先判断有没有这个属性，没有就添加，有就直接赋值
    Ivar ivar = class_getInstanceVariable(targetClass, [[NSString stringWithFormat:@"_%@", propertyName] UTF8String]);
    if (ivar) {
        return;
    }

    //objc_property_attribute_t所代表的意思可以调用getPropertyNameList打印，大概就能猜出
    objc_property_attribute_t type = { "T", [[NSString stringWithFormat:@"@\"%@\"",NSStringFromClass(valueClass)] UTF8String] };
    objc_property_attribute_t ownership0 = { "&", "" };
    objc_property_attribute_t ownership = { "N", "" };  //&代表retain,N代表nonatomic
    objc_property_attribute_t backingivar  = { "V", [[NSString stringWithFormat:@"_%@", propertyName] UTF8String] };
    objc_property_attribute_t attrs[] = { type, ownership0, ownership, backingivar };
    if (class_addProperty(targetClass, [propertyName UTF8String], attrs, 4)) {
        //添加get和set方法
        [targetClass addObjectProperty:propertyName];
        DDLogDebug(@"创建属性Property成功");
    }
}

+ (void)addPropertyForTargetClass:(Class)targetClass
                 withPropertyName:(NSString *)propertyName
                        withAttri:(NSString*)strAttrParams
                    withvalueType:(Class)valueClass
             withCustomEncodeType:(NSString*)strEncodeType{
    if(0 == propertyName.length || !targetClass){
        return;
    }
    if (!(strAttrParams.length > 0 || valueClass || strEncodeType)) {  //三者都为空时强制返回
        return;
    }
    
    //先判断有没有这个属性，没有就添加，有就直接赋值
    Ivar ivar = class_getInstanceVariable(targetClass, [[NSString stringWithFormat:@"_%@", propertyName] UTF8String]);
    if (ivar) {
        return;
    }
    
    NSArray *argStrArr = [strAttrParams componentsSeparatedByString:@","];
    if (!(argStrArr.count > 0 || valueClass || strEncodeType)) {  //三者都为空时强制返回
        return;
    }
    
    if (!_propertyTypeEncodeDict) {
        _propertyTypeEncodeDict = [[NSMutableDictionary alloc] init];
#define JP_DEFINE_TYPE_ENCODE_CASE(_type) \
[_propertyTypeEncodeDict setObject:[NSString stringWithUTF8String:@encode(_type)] forKey:@#_type];\

        JP_DEFINE_TYPE_ENCODE_CASE(id);
        JP_DEFINE_TYPE_ENCODE_CASE(BOOL);
        JP_DEFINE_TYPE_ENCODE_CASE(int);
        JP_DEFINE_TYPE_ENCODE_CASE(void);
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
    
    
    // = {};
    
    NSMutableDictionary *dicAttribute = [[NSMutableDictionary alloc] initWithCapacity:5];
    
    //dicAttributeFixed中保存type与变量名，其中type一定要是第一个，变量名一定是最后一个
    NSMutableDictionary *dicAttributeFixed = [[NSMutableDictionary alloc] initWithCapacity:2];
    
    BOOL isHasType = NO;
    
    if (valueClass) {
        [dicAttributeFixed setObject:[NSString stringWithFormat:@"@\"%@\"",NSStringFromClass(valueClass)] forKey:@"T"];
        isHasType = YES;
    }
    else if (strEncodeType) {
        NSString *returnEncode = nil;
        returnEncode = _propertyTypeEncodeDict[strEncodeType];  //先去字典里查，如果有结果就优先全长字典里面的
        if(returnEncode){
            [dicAttributeFixed setObject:returnEncode forKey:@"T"];
            isHasType = YES;
        }
        else{
            [dicAttributeFixed setObject:strEncodeType forKey:@"T"];
            isHasType = YES;
        }
    }
    
    [dicAttributeFixed setObject:[NSString stringWithFormat:@"_%@", propertyName] forKey:@"V"];
    
    if(!isHasType){
        DDLogError(@"type must be assigned!");
    }
    
    NSInteger index = 0;
//    NSArray *argStrArr = [strAttrParams componentsSeparatedByString:@","];
//    if (!(argStrArr.count > 0 || valueClass || strEncodeType)) {  //三者都为空时强制返回
//        return;
//    }
    
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
        //添加get和set方法
        [targetClass addObjectProperty:propertyName];
        DDLogDebug(@"创建属性Property成功");
    }
    

}


//在目标target上添加属性，属性名propertyname，值value
//参考http://blog.csdn.net/shengyumojian/article/details/44919695
+ (void)addPropertyWithtarget:(Class)targetClass withPropertyName:(NSString *)propertyName withValueClass:(Class)valueClass {
    
    //先判断有没有这个属性，没有就添加，有就直接赋值
    Ivar ivar = class_getInstanceVariable(targetClass, [[NSString stringWithFormat:@"_%@", propertyName] UTF8String]);
    if (ivar) {
        return;
    }
    
    /*
     objc_property_attribute_t type = { "T", "@\"NSString\"" };
     objc_property_attribute_t ownership = { "C", "" }; // C = copy
     objc_property_attribute_t backingivar  = { "V", "_privateName" };
     objc_property_attribute_t attrs[] = { type, ownership, backingivar };
     class_addProperty([SomeClass class], "name", attrs, 3);
     */
    
    //objc_property_attribute_t所代表的意思可以调用getPropertyNameList打印，大概就能猜出
    objc_property_attribute_t type = { "T", [[NSString stringWithFormat:@"@\"%@\"",NSStringFromClass(valueClass)] UTF8String] };
    //    objc_property_attribute_t ownership = { "&", "N" };
    objc_property_attribute_t ownership0 = { "&", "" };
    
    objc_property_attribute_t ownership = { "N", "" };
    objc_property_attribute_t backingivar  = { "V", [[NSString stringWithFormat:@"_%@", propertyName] UTF8String] };
    objc_property_attribute_t attrs[] = { type, ownership0, ownership, backingivar };
    if (class_addProperty(targetClass, [propertyName UTF8String], attrs, 4)) {
        
        //添加get和set方法
        [targetClass addObjectProperty:propertyName];
        
        //赋值
        //        [target setValue:value forKey:propertyName];
        //        NSLog(@"%@", [target valueForKey:propertyName]);
        
        DDLogDebug(@"创建属性Property成功");
    }
}


//+ (BOOL)commonAddProperty:(NSString *)propertyName{
//    //objc_property_attribute_t所代表的意思可以调用getPropertyNameList打印，大概就能猜出
//    objc_property_attribute_t type = { "T", [[NSString stringWithFormat:@"@\"%@\"",NSStringFromClass(valueClass)] UTF8String] };
//    objc_property_attribute_t ownership0 = { "&", "" };
//    objc_property_attribute_t ownership = { "N", "" };  //&代表retain,N代表nonatomic
//    objc_property_attribute_t backingivar  = { "V", [[NSString stringWithFormat:@"_%@", propertyName] UTF8String] };
//    objc_property_attribute_t attrs[] = { type, ownership0, ownership, backingivar };
//    return (class_addProperty(targetClass, [propertyName UTF8String], attrs, 4))
//}

+ (BOOL)classAddPropertyOC:(Class)targetClass withPropertyName:(NSString *)propertyName andAttrs:(objc_property_attribute_t[])attrs{
    unsigned int count = sizeof(*attrs) / sizeof(attrs[0]);
    return (class_addProperty(targetClass, [propertyName UTF8String], attrs, count));
}


+ (NSString*)typeInt{
//    [self addProperty:@"int, copy, nonatomic"];
    return @"i";
}

+ (objc_property_attribute_t)typeAttributeInt{
    objc_property_attribute_t type = { "T", "i"};
    return type;
}

//+ (objc_property_attribute_t*)typeAttributesInt:(Class)targetClass withPropertyName:(NSString *)propertyName {
//    objc_property_attribute_t type = { "T", "i"};
//    objc_property_attribute_t ownership0 = { "&", "" };
//    objc_property_attribute_t ownership = { "N", "" };  //&代表retain,N代表nonatomic
//    objc_property_attribute_t backingivar  = { "V", [[NSString stringWithFormat:@"_%@", propertyName] UTF8String] };
//    objc_property_attribute_t attrs[] = { type, ownership0, ownership, backingivar };
//    return attrs;
//}

@end
