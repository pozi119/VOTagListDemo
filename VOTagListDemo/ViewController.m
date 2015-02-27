//
//  ViewController.m
//  VOTagListDemo
//
//  Created by ValoLee on 14/12/31.
//  Copyright (c) 2014年 ValoLee. All rights reserved.
//

#import "ViewController.h"
#import "VOTagList.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSArray *tags = @[@"AAA", @"BB", @"C", @"DDDD",@"EEEEEEE", @"FFFFF", @"G", @"HHHH"];
    VOTagList *tagList = [[VOTagList alloc] initWithTags:tags];
    tagList.frame = CGRectMake(20, 80, 300, 200);
    tagList.multiLine = YES;
    tagList.multiSelect = YES;
    tagList.allowNoSelection = YES;
    tagList.vertSpacing = 20;
    tagList.horiSpacing = 20;
    tagList.selectedTextColor = [UIColor purpleColor];
    tagList.tagBackgroundColor = [UIColor colorWithRed:1.000 green:0.400 blue:0.400 alpha:1.000];
    tagList.selectedTagBackgroundColor = [UIColor redColor];
    tagList.tagCornerRadius = 3;
    tagList.tagEdge = UIEdgeInsetsMake(8, 8, 8, 8);
    [tagList addTarget:self action:@selector(selectedTagsChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:tagList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)selectedTagsChanged: (VOTagList *)tagList{
    NSLog(@"selected: %@", tagList.selectedIndexSet);
}

@end
