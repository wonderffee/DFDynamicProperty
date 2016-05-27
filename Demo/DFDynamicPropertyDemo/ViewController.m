//
//  ViewController.m
//  DFDynamicPropertyDemo
//
//  Created by Pheylix on 16/5/27.
//  Copyright © 2016年 wonderffee. All rights reserved.
//

#import "ViewController.h"
#import "SampleModel.h"
#import <MJExtension/MJExtension.h>
#import <objc/runtime.h>

@interface ViewController (){
    
}

@property (nonatomic, strong) SampleModel *modelData;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"sample.json" ofType:@""];
    if (!path) return;
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"json is \n %@", json);
    
    
    self.modelData = [SampleModel objectWithKeyValues:json];
    
    //homeTeam, markerImage, information properties are commented in SampleModel.h, and are added in main.js
    
    [self printAllProperty];
}

- (void)printAllProperty{
    NSLog(@"SampleModel is \n");
    @autoreleasepool {
        unsigned int outCount, i;
        objc_property_t *properties = class_copyPropertyList([SampleModel class], &outCount);
        for (i = 0; i < outCount; i++) {
            objc_property_t property = properties[i];
            //            fprintf(stdout, "%s %s\n", property_getName(property), property_getAttributes(property));
            
            const char *nameC = property_getName(property);
            NSString *name = [NSString stringWithUTF8String:nameC];
            NSLog(@"%@ = %@", name, [self.modelData valueForKey:name]);
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
