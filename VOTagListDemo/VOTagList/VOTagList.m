//
//  VOTagList.m
//  VOTagListDemo
//
//  Created by ValoLee on 14/12/31.
//  Copyright (c) 2014年 ValoLee. All rights reserved.
//

#import "VOTagList.h"

#define kMinSpacing 8.0

@interface VOTagList ()

@property (nonatomic, strong) NSMutableArray *mutableTags;
@property (nonatomic, strong) NSMutableIndexSet   *mutableSelectedIndexSet;

@property (nonatomic, strong) CAScrollLayer  *scrollLayer;
@property (nonatomic, strong) NSMutableArray *tagLayerArray;

@property (nonatomic, assign) CGPoint        lastPoint;
@property (nonatomic, assign) CGPoint        startPoint;
@property (nonatomic, assign) BOOL		     isClick;

@end

@implementation VOTagList

- (instancetype)initWithTags:(NSArray *)tags{
    if (self = [super init]) {
        self.mutableTags = [tags mutableCopy];
        [self commonInit];
    }
    return self;
}

- (instancetype)init{
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit{
    self.font                       = [UIFont systemFontOfSize:17];
    self.textColor                  = [UIColor blackColor];
    self.selectedTextColor          = [UIColor blackColor];
    self.tagBackgroundColor         = [UIColor clearColor];
    self.selectedTagBackgroundColor = [UIColor clearColor];
    self.multiLine                  = NO;
    self.multiSelect                = NO;
    self.allowNoSelection           = NO;
    self.scrollBounce               = NO;
    self.horiSpacing                = 8;
    self.backgroundColor            = [UIColor clearColor];
}

- (CGFloat)horiSpacing{
    if (_horiSpacing < kMinSpacing) {
        _horiSpacing = kMinSpacing;
    }
    return _horiSpacing;
}

- (CGFloat)vertSpacing{
    if (_vertSpacing < kMinSpacing) {
        _vertSpacing = kMinSpacing;
    }
    return _vertSpacing;
}

- (CAScrollLayer *)scrollLayer{
    if (!_scrollLayer) {
        _scrollLayer = [CAScrollLayer layer];
    }
    return _scrollLayer;
}

- (NSMutableArray *)mutableTags{
    if (!_mutableTags) {
        _mutableTags = [NSMutableArray array];
    }
    return _mutableTags;
}

- (NSMutableIndexSet *)mutableSelectedIndexSet{
    if (!_mutableSelectedIndexSet) {
        _mutableSelectedIndexSet = [NSMutableIndexSet indexSet];
    }
    return _mutableSelectedIndexSet;
}

- (NSMutableArray *)tagLayerArray{
    if (!_tagLayerArray) {
        _tagLayerArray = [NSMutableArray array];
    }
    return _tagLayerArray;
}

- (NSIndexSet *)selectedIndexSet{
    return self.mutableSelectedIndexSet;
}

-(NSArray *)tags{
    return self.mutableTags;
}

- (void)setTags:(NSArray *)tags{
    [self.mutableTags removeAllObjects];
    [self.mutableTags addObjectsFromArray:tags];
    [self removeDuplicateTags];
    [self setNeedsDisplay];
}

- (void)addTags: (NSArray *)tags{
    [self.mutableTags addObjectsFromArray:tags];
    [self removeDuplicateTags];
    [self setNeedsDisplay];
}

- (void)insertTags: (NSArray *)tags atIndexes: (NSIndexSet *)indexSet{
    [self.mutableTags insertObjects:tags atIndexes:indexSet];
    [self removeDuplicateTags];
    [self setNeedsDisplay];
}
- (void)removeTags: (NSArray *)tags{
    [self.mutableTags removeObjectsInArray:tags];
    [self setNeedsDisplay];
}

- (void)removeTagsAtIndexes: (NSIndexSet *)indexSet{
    [self.mutableTags removeObjectsAtIndexes:indexSet];
    [self setNeedsDisplay];
}

- (void)selectIndex:(NSUInteger)index{
    [self selectIndex:index notify:YES];
}

- (void)selectIndexes: (NSIndexSet *)indexSet{
    [self selectIndexes:indexSet notify:YES];
}

- (void)deSelectIndex:(NSUInteger)index{
    [self deSelectIndex:index notify:YES];
}

- (void)deSelectIndexes: (NSIndexSet *)indexSet{
    [self deSelectIndexes:indexSet notify:YES];
}

- (void)selectIndex:(NSUInteger)index notify:(BOOL)notify{
    if (!self.multiSelect) {
        [self.mutableSelectedIndexSet removeAllIndexes];
    }
    [self.mutableSelectedIndexSet addIndex:index];
    [self setNeedsDisplay];
    if (notify) {
        [self notifyFormutableSelectedIndexSetChanged];
    }
}

- (void)selectIndexes: (NSIndexSet *)indexSet notify:(BOOL)notify{
    if (!self.multiSelect) {
        [self.mutableSelectedIndexSet removeAllIndexes];
        [self.mutableSelectedIndexSet addIndex:indexSet.lastIndex];
    }
    else{
        [self.mutableSelectedIndexSet addIndexes:indexSet];
    }
    [self setNeedsDisplay];
    if (notify) {
        [self notifyFormutableSelectedIndexSetChanged];
    }
}

// TODO, 逻辑可能有问题
- (void)deSelectIndex:(NSUInteger)index notify:(BOOL)notify{
    if (!self.allowNoSelection && self.mutableSelectedIndexSet.count <= 1) {
        return;
    }
    if ([self.mutableSelectedIndexSet containsIndex:index]){
        [self.mutableSelectedIndexSet removeIndex:index];
        [self setNeedsDisplay];
        if (notify) {
            [self notifyFormutableSelectedIndexSetChanged];
        }
    }
}

// TODO, 逻辑可能有问题
- (void)deSelectIndexes: (NSIndexSet *)indexSet notify:(BOOL)notify{
    if (!self.allowNoSelection && self.mutableSelectedIndexSet.count <= 1) {
        return;
    }
    [self.mutableSelectedIndexSet removeIndexes:indexSet];
    [self setNeedsDisplay];
    if (notify) {
        [self notifyFormutableSelectedIndexSetChanged];
    }
}

- (void)removeDuplicateTags{
    if (self.allowsDuplicates) {
        return;
    }
    NSMutableArray *resultArray  = [NSMutableArray array];
        for (NSString *tag in self.mutableTags) {
            if (![resultArray containsObject:tag]) {
                [resultArray addObject:tag];
            }
    }
    self.mutableTags = resultArray;
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self setNeedsDisplay];
}

- (void)setBounds:(CGRect)bounds{
    [super setBounds:bounds];
    [self setNeedsDisplay];
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect{
    self.scrollLayer.frame = rect;
    self.scrollLayer.backgroundColor = [UIColor clearColor].CGColor;
    
    // 1. 填充背景
    [self.backgroundColor setFill];
    UIRectFill(self.bounds);
    
    // 2. 移除所有sublayers
    self.scrollLayer.sublayers = nil;
    self.layer.sublayers = nil;
    
    // 3. 添加scrollLayer
    [self.layer addSublayer:self.scrollLayer];
    
    // 4. 添加textLayers
    [self.tagLayerArray removeAllObjects];
    CGPoint curPos = CGPointZero;
    for (NSUInteger i = 0 ; i < self.mutableTags.count; i ++) {
        NSString *tag = self.mutableTags[i];
        CGSize textSize           = [self getTextSize:tag andFont:self.font];
        CGSize tagSize            = textSize;
        tagSize.width  += self.tagEdge.left + self.tagEdge.right;
        tagSize.height += self.tagEdge.top + self.tagEdge.bottom;
        if (self.multiLine) {
            if (curPos.x > 0 && curPos.x + tagSize.width > rect.size.width) {
                curPos.x = 0;
                curPos.y += tagSize.height + self.vertSpacing;
            }
        }
        CALayer *tagLayer         = [CALayer layer];
        tagLayer.frame            =  CGRectMake(curPos.x, curPos.y, tagSize.width, tagSize.height);
        CATextLayer *textLayer    = [CATextLayer layer];
        textLayer.frame           = CGRectMake(self.tagEdge.left, self.tagEdge.top, textSize.width, textSize.height);
        curPos.x += tagSize.width + self.horiSpacing;
        textLayer.font            = (__bridge CFTypeRef)self.font.fontName;
        textLayer.fontSize        = self.font.pointSize;
        if ([self.mutableSelectedIndexSet containsIndex:i]) {
            tagLayer.backgroundColor = self.selectedTagBackgroundColor.CGColor;
            textLayer.foregroundColor = self.selectedTextColor.CGColor;
        }
        else{
            tagLayer.backgroundColor = self.tagBackgroundColor.CGColor;
            textLayer.foregroundColor = self.textColor.CGColor;
        }
        textLayer.string          = tag;
        textLayer.contentsScale   = [UIScreen mainScreen].scale;
        if (self.tagCornerRadius > 0) {
            tagLayer.masksToBounds = YES;
            tagLayer.cornerRadius  = self.tagCornerRadius;
        }
        [self.tagLayerArray addObject:tagLayer];
        [tagLayer addSublayer:textLayer];
        [self.scrollLayer addSublayer:tagLayer];
    }
}

- (CGSize)getTextSize: (id)text andFont: (UIFont *)font{
    if (!text) {
        return CGSizeZero;
    }
    NSString *str = nil;
    NSDictionary *attributes = nil;
    if ([text isKindOfClass: [NSString class]]) {
        str = text;
        attributes = @{NSFontAttributeName: font};
    }
    else if([text isKindOfClass:[NSAttributedString class]])
    {
        NSAttributedString *attrStr = (NSAttributedString *)text;
        str = attrStr.string;
        NSRange range;
        attributes = [attrStr attributesAtIndex:0 effectiveRange:&range];
    }
    if ([text respondsToSelector:@selector(sizeWithAttributes:)]) {
        return [str sizeWithAttributes: attributes];
    }
    else {
#pragma clang diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated"
        return [str sizeWithFont:font];
#pragma clang diagnostic pop
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch  = [[event touchesForView:self] anyObject];
    self.startPoint = [touch locationInView:self];
    self.isClick    = YES;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [[event touchesForView:self] anyObject];
    CGPoint point = [touch locationInView:self];
    if (ABS(point.x - self.startPoint.x) < 10 && ABS(point.y - self.startPoint.y) < 10 ){
        self.isClick = NO;
    }
    CGFloat leftX = 0, topY = 0;
    CGFloat rightX = 0, bottomY = 0;
    CALayer *lastlayer = self.tagLayerArray.lastObject;
    if (lastlayer) {
        if (self.multiLine) {
            bottomY = CGRectGetMaxY(lastlayer.frame) - self.bounds.size.height;
            bottomY = (bottomY > topY) ? bottomY : topY;
        }
        else{
            rightX = CGRectGetMaxX(lastlayer.frame) - self.bounds.size.width;
            rightX = (rightX > leftX)? rightX : leftX;
        }
    }
    CGFloat curX = self.lastPoint.x - point.x + self.startPoint.x;
    CGFloat lastX = MIN(MAX(leftX, curX), rightX);
    CGFloat curY = self.lastPoint.y - point.y + self.startPoint.y;
    CGFloat lastY = MIN(MAX(topY, curY), bottomY);
    if (self.scrollBounce) {
        [self.scrollLayer scrollToPoint:CGPointMake(curX, curY)];
    }
    else{
        [self.scrollLayer scrollToPoint:CGPointMake(lastX, lastY)];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [[event touchesForView:self] anyObject];
    CGPoint point = [touch locationInView:self];
    CGFloat leftX = 0, topY = 0;
    CGFloat rightX = 0, bottomY = 0;
    CALayer *lastlayer = self.tagLayerArray.lastObject;
    if (lastlayer) {
        if (self.multiLine) {
            bottomY = CGRectGetMaxY(lastlayer.frame) - self.bounds.size.height;
            bottomY = (bottomY > topY) ? bottomY : topY;
        }
        else{
            rightX = CGRectGetMaxX(lastlayer.frame) - self.bounds.size.width;
            rightX = (rightX > leftX)? rightX : leftX;
        }
    }
    CGFloat curX = self.lastPoint.x - point.x + self.startPoint.x;
    CGFloat lastX = MIN(MAX(leftX, curX), rightX);
    CGFloat curY = self.lastPoint.y - point.y + self.startPoint.y;
    CGFloat lastY = MIN(MAX(topY, curY), bottomY);
    [CATransaction begin];
    [CATransaction setAnimationDuration:kDefaultDuration];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [self.scrollLayer scrollToPoint:CGPointMake(lastX, lastY)];
    [CATransaction commit];
    self.lastPoint  = CGPointMake(lastX, lastY);
    if (self.isClick) {
        if (CGRectContainsPoint(self.bounds, point)) {
            for (NSInteger i = 0; i < self.tagLayerArray.count; i ++) {
                CALayer *layer = self.tagLayerArray[i];
                if (CGRectContainsPoint(CGRectOffset(layer.frame, -lastX, -lastY), point)) {
                    if ([self.mutableSelectedIndexSet containsIndex:i]) {
                        [self deSelectIndex:i];
                    }
                    else{
                        [self selectIndex:i];
                    }
                }
            }
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [self touchesEnded:touches withEvent:event];
}

- (void)notifyFormutableSelectedIndexSetChanged {
    if (self.superview)	{
        [self sendActionsForControlEvents:UIControlEventValueChanged];
        if (self.selectionChangeBlock) {
            self.selectionChangeBlock(self.selectedIndexSet);
        }
    }
}


@end
