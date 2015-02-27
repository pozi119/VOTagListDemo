//
//  VOTagList.h
//  VOTagListDemo
//
//  Created by ValoLee on 14/12/31.
//  Copyright (c) 2014年 ValoLee. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kDefaultDuration 1.0

@interface VOTagList : UIControl <NSCoding>

@property (nonatomic, strong) UIFont         *font;                        // 字体
@property (nonatomic, strong) UIColor        *textColor;                   // 未选中时颜色
@property (nonatomic, strong) UIColor        *selectedTextColor;           // 选中时颜色
@property (nonatomic, strong) UIColor        *tagBackgroundColor;          // 未选中时背景色
@property (nonatomic, strong) UIColor        *selectedTagBackgroundColor;  // 选中时背景色
@property (nonatomic, assign) CGFloat        horiSpacing;                  // 标签水平间距
@property (nonatomic, assign) CGFloat        vertSpacing;                  // 标签垂直间距
@property (nonatomic, assign) UIEdgeInsets   tagEdge;
@property (nonatomic, assign) CGFloat        tagCornerRadius;
@property (nonatomic, assign) BOOL           multiLine;                    // 是否多行显示
@property (nonatomic, assign) BOOL           multiSelect;                  // 是否可多选
@property (nonatomic, assign) BOOL		     allowNoSelection;
@property (nonatomic, assign) BOOL		     scrollBounce;
@property (nonatomic, assign) BOOL           allowsDuplicates;

@property (nonatomic, strong) NSArray   *tags;

@property (nonatomic, strong, readonly) NSIndexSet *selectedIndexSet;
@property (nonatomic, weak  ) void      (^selectionChangeBlock)(NSIndexSet *selectedIndexSet);

- (instancetype)initWithTags: (NSArray *)tags;
- (void)addTags: (NSArray *)tags;
- (void)insertTags: (NSArray *)tags atIndexes: (NSIndexSet *)indexSet;
- (void)removeTags: (NSArray *)tags;
- (void)removeTagsAtIndexes: (NSIndexSet *)indexSet;
- (void)selectIndex:(NSUInteger)index;
- (void)selectIndexes: (NSIndexSet *)indexSet;
- (void)deSelectIndex: (NSUInteger)index;
- (void)deSelectIndexes: (NSIndexSet *)indexSet;

@end
