//
//  ABSegmentView.m
//  LocalizationDemo
//
//  Created by Wildto on 16/8/28.
//  Copyright © 2016年 Wildto. All rights reserved.
//

#import "ABSegmentView.h"
#import "UIColor+Extension.h"

@implementation ABSegmentStyle

- (instancetype)init
{
    if(self = [super init]) {
        self.bottomLineHeight = 3.0;
        self.bottomLineColor = ColorWithHex(@"31c06c");
        self.titleFont = [UIFont systemFontOfSize:17.0];
        self.normalTitleColor = ColorWithHex(@"999999");
        self.selectedTitleColor = ColorWithHex(@"31c06c");
        self.hiddenBottomBorderLine = YES;
    }
    return self;
}

@end


@interface ABSegmentView ()
{
    NSUInteger _currentIndex;
    NSUInteger _oldIndex;
}
@property (nonatomic, strong) ABSegmentStyle *segmentStyle;
@property (nonatomic, weak) UIView *bottomLine;
@property (nonatomic, weak) UIView *moveClearView;
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSMutableArray *titleViews;
@property (nonatomic, strong) NSMutableArray *titleLabelRects;
@property (nonatomic, copy) TitleBtnOnClickBlock titleBtnOnClick;
@property (nonatomic, weak) UIView *viewBottomBorderLine;

@end

@implementation ABSegmentView

- (UIView *)bottomLine
{
    if (!_bottomLine) {
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = self.segmentStyle.bottomLineColor;
        [self.moveClearView addSubview:lineView];
        _bottomLine = lineView;
    }
    return _bottomLine;
}

-(UIView *)moveClearView
{
    if (!_moveClearView) {
        UIView *moveClearView = [[UIView alloc] init];
        moveClearView.backgroundColor = [UIColor clearColor];
        [self addSubview:moveClearView];
        _moveClearView = moveClearView;
    }
    return _moveClearView;
}

-(NSMutableArray *)titleViews
{
    if (!_titleViews) {
        _titleViews = [NSMutableArray array];
    }
    return _titleViews;
}

-(NSMutableArray *)titleLabelRects
{
    if (!_titleLabelRects) {
        _titleLabelRects = [NSMutableArray array];
    }
    return _titleLabelRects;
}

-(instancetype)initWithFrame:(CGRect)frame segmentStyle:(ABSegmentStyle *)segmentStyle titles:(NSArray<NSString *> *)titles titleDidClick:(TitleBtnOnClickBlock)titleDidClick
{
    if (self = [super initWithFrame:frame]) {
        self.titles = titles;
        self.titleBtnOnClick = titleDidClick;
        self.segmentStyle = segmentStyle;
        _currentIndex = 0;
        _oldIndex = 0;
        
        [self setuptitleViews];
        [self setupUI];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)setuptitleViews
{
    NSInteger index = 0;
    for (NSString *title in self.titles) {
        
        UIView *titleView = [[UIView alloc]initWithFrame:CGRectZero];
        titleView.tag = index;
        titleView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleViewOnClick:)];
        [titleView addGestureRecognizer:tapGes];
        titleView.backgroundColor = [UIColor clearColor];
        [self addSubview:titleView];
        
        //标题
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.tag = index;
        label.text = title;
        label.textColor = self.segmentStyle.normalTitleColor;
        label.font = self.segmentStyle.titleFont;
        [titleView addSubview:label];
        
        //红点提醒
        UIView *redPointView = [[UIView alloc]initWithFrame:CGRectZero];
        redPointView.backgroundColor = ColorWithHex(@"ff3b30");
        redPointView.layer.cornerRadius = 4;
        redPointView.layer.masksToBounds = YES;
        redPointView.tag = 250;
        redPointView.hidden = YES;
        [titleView addSubview:redPointView];
        
        [self.titleViews addObject:titleView];
        
        CGRect bounds = [title boundingRectWithSize:CGSizeMake(MAXFLOAT, 0.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.segmentStyle.titleFont} context:nil];
        [self.titleLabelRects addObject:[NSValue valueWithCGRect:bounds]];
        
        index++;
    }
}

- (void)setupUI
{
    [self setupTtitleLabelFrame];
    [self setupBottomLineFrame];
    [self setupViewBottomBorderLine];
}

- (void)setupTtitleLabelFrame
{
    CGFloat labelX = 0;
    CGFloat labelY = 0;
    CGFloat labelW = self.frame.size.width / self.titleViews.count;
    CGFloat labelH = self.frame.size.height;
    
    NSInteger index = 0;
    
    for (UIView *titleView in self.titleViews) {
        labelX = index * labelW;
        titleView.frame = CGRectMake(labelX, labelY, labelW, labelH);
        
        for (UIView *subView in titleView.subviews) {
            if ([subView isKindOfClass:[UILabel class]]) {
                UILabel *subLabel = (UILabel *)subView;
                if (subLabel.tag == titleView.tag) {
                    CGRect labBounds = [self.titleLabelRects[index] CGRectValue];
                    CGFloat subLabelW = labBounds.size.width;
                    CGFloat subLabelH = labBounds.size.height;
                    CGFloat subLabelX = (titleView.ab_width - subLabelW) / 2;
                    CGFloat subLabelY = (titleView.ab_height - subLabelH) / 2;
                    subLabel.frame = CGRectMake(subLabelX, subLabelY, subLabelW, subLabelH);
                    [self solveUIWidgetFuzzy:subLabel];
                    if (index == 0) {
                        subLabel.textColor = self.segmentStyle.selectedTitleColor;
                    }
                    
                    UIView *redPointView = [titleView viewWithTag:250];
                    if (redPointView) {
                        CGFloat redPointW = 8;
                        CGFloat redPointH = 8;
                        CGFloat redPointX = CGRectGetMaxX(subLabel.frame);
                        CGFloat redPointY = subLabel.ab_y - redPointH / 2;
                        redPointView.frame = CGRectMake(redPointX, redPointY, redPointW, redPointH);
                    }
                }
            }
            continue;
        }
        
        index++;
    }
}

- (void)solveUIWidgetFuzzy:(UIView *)view
{
    CGRect frame = view.frame;
    int x = floor(frame.origin.x);
    int y = floor(frame.origin.y);
    int w = floor(frame.size.width) + 1;
    int h = floor(frame.size.height) + 1;
    
    view.frame = CGRectMake(x, y, w, h);
}

- (void)setupBottomLineFrame
{
    UIView *firstTitleView = [self.titleViews firstObject];
    
    if (self.moveClearView) {
        self.moveClearView.ab_y = 0;
        self.moveClearView.ab_width = firstTitleView.frame.size.width;
        self.moveClearView.ab_height = firstTitleView.frame.size.height;
        self.moveClearView.ab_x = firstTitleView.frame.origin.x;
    }
    
    CGRect titleLabRect = [[self.titleLabelRects firstObject] CGRectValue];
    CGFloat lineW = titleLabRect.size.width;
    CGFloat lineH = self.segmentStyle.bottomLineHeight;
    CGFloat lineY = self.moveClearView.frame.size.height - lineH;
    
    if (self.bottomLine) {
        self.bottomLine.ab_x = (self.moveClearView.frame.size.width - lineW) / 2;
        self.bottomLine.ab_y = lineY;
        self.bottomLine.ab_width = lineW;
        self.bottomLine.ab_height = lineH;
    }
}

-(void)setupViewBottomBorderLine
{
    CGFloat lineH = 1.f / [UIScreen mainScreen].scale;
    UIView *viewBottomBorderLine = [[UIView alloc]initWithFrame:CGRectMake(0, self.ab_height - lineH, self.ab_width, lineH)];
    viewBottomBorderLine.backgroundColor = ColorWithHex(@"e5e5e5");
    [self addSubview:viewBottomBorderLine];
    self.viewBottomBorderLine = viewBottomBorderLine;
    self.viewBottomBorderLine.hidden = self.segmentStyle.hiddenBottomBorderLine;
}

#pragma mark - titleViewOnClick
- (void)titleViewOnClick:(UITapGestureRecognizer *)tapGes
{
    UIView *currentTitleView = tapGes.view;
    if (!currentTitleView) {
        return;
    }
    _currentIndex = currentTitleView.tag;
    
    [self adjustUIWhenBtnOnClickWithAnimated:YES];
}

- (void)adjustUIWhenBtnOnClickWithAnimated:(BOOL)animated
{
    if (_currentIndex == _oldIndex) {
        return;
    }

    CGFloat animatedTime = animated ? 0.2 : 0.0;
    
    CGRect titleLabelRect = [self.titleLabelRects[_currentIndex] CGRectValue];
    CGFloat currentBottomLinW = titleLabelRect.size.width;
    
    UIView *oldTitleView = self.titleViews[_oldIndex];
    UILabel *oldTitleLabel = nil;
    for (UIView *subView in oldTitleView.subviews) {
        if ([subView isKindOfClass:[UILabel class]]) {
            UILabel *subLabel = (UILabel *)subView;
            if (subLabel.tag == oldTitleView.tag) {
                oldTitleLabel = subLabel;
            }
        }
    }
    UIView *currentTitleView = self.titleViews[_currentIndex];
    UILabel *currentTitleLabel = nil;
    for (UIView *subView in currentTitleView.subviews) {
        if ([subView isKindOfClass:[UILabel class]]) {
            UILabel *subLabel = (UILabel *)subView;
            if (subLabel.tag == currentTitleView.tag) {
                currentTitleLabel = subLabel;
            }
        }
    }
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:animatedTime animations:^{
        oldTitleLabel.textColor = weakSelf.segmentStyle.normalTitleColor;
        currentTitleLabel.textColor = weakSelf.segmentStyle.selectedTitleColor;
        
        weakSelf.moveClearView.ab_x = currentTitleView.ab_x;
        
        weakSelf.bottomLine.ab_width = currentBottomLinW;
        weakSelf.bottomLine.ab_x = (weakSelf.moveClearView.ab_width - currentBottomLinW) / 2;
    }];
    
    _oldIndex = _currentIndex;
    
    _selectedIndex = _currentIndex;
    
    if (self.titleBtnOnClick) {
        self.titleBtnOnClick(currentTitleLabel.text,_currentIndex);
    }
}

- (void)setSelectedIndex:(NSInteger)index animated:(BOOL)animated
{
    if (index < 0 || index >= self.titles.count) {
        return;
    }
    _currentIndex = index;
    [self adjustUIWhenBtnOnClickWithAnimated:animated];
}

-(void)adjustScollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat changeX = offsetX / (pageWidth / self.frame.size.width) / self.titles.count;
    self.moveClearView.ab_x = changeX;
}

-(void)showBaggeOnItemIndex:(NSInteger)index
{
    if (index < 0 || index > self.titleViews.count) {
        return;
    }
    
    UIView *titleView = self.titleViews[index];
    UIView *redPointView = [titleView viewWithTag:250];
    if (redPointView) {
        if (redPointView.hidden) {
            redPointView.hidden = NO;
        }
    }
}

- (void)hideBaggeOnItemIndex:(NSInteger)index
{
    if (index < 0 || index > self.titleViews.count) {
        return;
    }
    
    UIView *titleView = self.titleViews[index];
    UIView *redPointView = [titleView viewWithTag:250];
    if (redPointView) {
        if (!redPointView.hidden) {
            redPointView.hidden = YES;
        }
    }
}

@end
