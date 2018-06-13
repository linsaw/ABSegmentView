# ABSegmentView
如果每个产品设计都能根据苹果的UI风格来的话，那就省事很多了，但是现实是残酷的，而且如果都用一套苹果原生UI的，恩，看起来也很蛋疼。每个app打开都一个鸟UI，恩，也会视觉疲劳。因此就必须自定义各种各样的UI控件来满足产品UI需求。
今天分享一个自己产品UI需求效果的分段控制器。因为系统的```UISegmentedControl```局限性，很多效果没法实现，只能自定义，纵观各种app，基本上难看到原生的```UISegmentedControl```。
先看下效果图
![](https://upload-images.jianshu.io/upload_images/439166-d10d71c56c10f4fa.gif?imageMogr2/auto-orient/strip)
![](https://upload-images.jianshu.io/upload_images/439166-2a930370318c9d5c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
这个自定义```SegmentView```除了基本的标题选择、底部滚动条等，还支持小红点提醒。实现也很简单，当然也可以根据业务需求，自己慢慢增加功能。具体看代码：
```
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
```

使用初始化也很简单：
```
    ABSegmentStyle *style = [[ABSegmentStyle alloc]init];
    style.titleFont = [UIFont boldSystemFontOfSize:17];

    YTWeakSelf(self);
    ABSegmentView *segmentView = [[ABSegmentView alloc]initWithFrame:CGRectMake(0, 0, kWidthValue(225), 44) segmentStyle:style titles:@[YTLocalizedString(@"跑步"),YTLocalizedString(@"自行车"),YTLocalizedString(@"铁三")] titleDidClick:^(NSString *title, NSInteger index) {
        if (weakself.scrollview) {
            [weakself.scrollview setContentOffset:CGPointMake(weakself.scrollview.frame.size.width * index, 0) animated:NO];
            [weakself scrollViewDidEndScrollingAnimation:weakself.scrollview];
            weakself.scrollview.scrollEnabled = YES;
        }
    }];
    self.navigationItem.titleView = segmentView;
    self.segmentView = segmentView;
    [segmentView setSelectedIndex:1 animated:NO];
```
```
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    NSInteger page = scrollView.contentOffset.x / pageWidth;
    [self scrollViewDidEndScrollingAnimation:scrollView];
    
    [self.segmentView setSelectedIndex:page animated:YES];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.segmentView adjustScollViewDidScroll:scrollView];
}
```
