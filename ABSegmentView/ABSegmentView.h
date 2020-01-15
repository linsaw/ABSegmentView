//
//  ABSegmentView.h
//  LocalizationDemo
//
//  Created by Wildto on 16/8/28.
//  Copyright © 2016年 Wildto. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ABSegmentStyle;

@interface ABSegmentStyle : NSObject

/** 滚动条的颜色 */
@property (nonatomic, strong) UIColor *bottomLineColor;
/** 滚动条的高度 默认为2 */
@property (assign, nonatomic) CGFloat bottomLineHeight;
/** 标题的字体 默认为17 */
@property (strong, nonatomic) UIFont *titleFont;
/** 标题一般状态的颜色 */
@property (strong, nonatomic) UIColor *normalTitleColor;
/** 标题选中状态的颜色 */
@property (strong, nonatomic) UIColor *selectedTitleColor;
/** 隐藏底部边框线，默认YES */
@property (assign, nonatomic) BOOL hiddenBottomBorderLine;

@end


typedef void(^TitleBtnOnClickBlock)(NSString *title, NSInteger index);

@interface ABSegmentView : UIView

-(instancetype)initWithFrame:(CGRect)frame segmentStyle:(ABSegmentStyle *)segmentStyle titles:(NSArray<NSString *> *)titles titleDidClick:(TitleBtnOnClickBlock)titleDidClick;

@property (nonatomic, assign, readonly) NSInteger selectedIndex;

/**
 设置选中的下标

 @param index 下标
 @param animated 动画
 */
- (void)setSelectedIndex:(NSInteger)index animated:(BOOL)animated;

/**
 根据外部滚动视图来调整底部横线位置

 @param scrollView 外部滚动视图
 */
- (void)adjustScollViewDidScroll:(UIScrollView *)scrollView;

/**
 显示小红点

 @param index 位置
 */
- (void)showBaggeOnItemIndex:(NSInteger)index;

/**
 隐藏小红点
 
 @param index 位置
 */
- (void)hideBaggeOnItemIndex:(NSInteger)index;


@end
