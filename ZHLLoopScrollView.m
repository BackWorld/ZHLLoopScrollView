//
//  ZHLLoopScrollView.m
//  GroupedCollectionView
//
//  Created by Ios on 2020/8/25.
//  Copyright © 2020 zhl. All rights reserved.
//

#import "ZHLLoopScrollView.h"

#pragma mark - Consts

@interface ZHLLoopScrollView()

#pragma mark - Views

@property(nonatomic, strong)UIView *view1;
@property(nonatomic, strong)UIView *view2;

@property(nonatomic, strong)UIView *topView;
@property(nonatomic, strong)UIView *bottomView;

#pragma mark - Datas
/// current index
@property(nonatomic)NSUInteger itemIndex;
@property(nonatomic)NSUInteger countIndex;

@end

@implementation ZHLLoopScrollView

#pragma mark - Initials
- (instancetype)initWithCoder:(NSCoder *)coder{
    self = [super initWithCoder:coder];
    if (self) {
        [self initialSettings];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialSettings];
    }
    return self;
}

/// 初始化设置
- (void)initialSettings {
    self.clipsToBounds = YES;
    self.scrollDuration = 3;
}

#pragma mark - Lifecycles

#pragma mark - Overrides

- (void)layoutSubviews{
    [super layoutSubviews];
    
    /// 重设宽高
    CGFloat w = CGRectGetWidth(self.bounds);
    CGFloat h = CGRectGetHeight(self.bounds);
    
    CGRect rect = _view1.frame;
    rect.size.width = w;
    rect.size.height = h;
    _view1.frame = rect;
    
    rect = _view2.frame;
    rect.size.width = w;
    rect.size.height = h;
    _view2.frame = rect;
}

#pragma mark - Publics

- (void)reloadData{
    /// 清零
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    _countIndex = 0;
    _itemIndex = 0;
    [_view1.layer removeAllAnimations];
    [_view2.layer removeAllAnimations];
    [_view1 removeFromSuperview];
    [_view2 removeFromSuperview];
    _view1 = nil;
    _view2 = nil;
    
    NSUInteger count = [_dataSource numerOfItemsForLoopScrollView:self];
    if (count > 0) {
        [self addSubview:self.view1];
        [self addItemViewAtIndex:0 forView:_view1];
    }
    if (count > 1) {
        [self addSubview:self.view2];
        [self addItemViewAtIndex:1 forView:_view2];
        
        [self performSelector:@selector(changeNextItem) withObject:nil afterDelay:_scrollDuration-0.3];
    }
}

#pragma mark - Privates

/// 构建item视图
- (void)addItemViewAtIndex:(NSUInteger)index forView:(UIView *)view{
    [view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIView *v = [self.dataSource viewAtIndex:index forLoopScrollView:self];
    v.frame = view.bounds;
    v.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [view addSubview:v];
}

/// 切换下一个
- (void)changeNextItem{
    NSUInteger count = [self.dataSource numerOfItemsForLoopScrollView:self];
    if (_itemIndex == count) {
        _itemIndex = 0;
    }
    self.topView = _countIndex%2 == 0 ? _view1 : _view2;
    self.bottomView = [_topView isEqual:_view1] ? _view2 : _view1;
    
    NSUInteger idx = _itemIndex==count ? 0 : _itemIndex;
    [self addItemViewAtIndex:idx forView:_topView];
    
    idx = (_itemIndex+1)==count ? 0 : (_itemIndex+1);
    [self addItemViewAtIndex:idx forView:_bottomView];
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^
    {
        CGRect rect = self.bounds;
        
        /// 移出屏幕
        rect.origin.y = -CGRectGetHeight(rect);
        self.topView.frame = rect;
        
        /// 移入屏幕
        rect.origin.y = CGRectGetMaxY(rect);
        self.bottomView.frame = rect;
    } completion:^(BOOL finished)
    {
        CGRect rect = self.bounds;
        
        /// 移出屏幕
        rect.origin.y = CGRectGetHeight(rect);
        self.topView.frame = rect;
        
        /// 下一个
        [self performSelector:@selector(changeNextItem) withObject:nil afterDelay:self.scrollDuration-0.3];
    }];
    
    _itemIndex += 1;
    _countIndex += 1;
}

#pragma mark - Delegates

#pragma mark - Getters

/// view1
- (UIView *)view1{
    if (!_view1) {
        _view1 = [[UIView alloc] initWithFrame:self.bounds];
        _view1.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
    return _view1;
}

/// view2
- (UIView *)view2{
    if (!_view2) {
        CGRect rect = self.view1.frame;
        rect.origin.y = CGRectGetMaxY(rect);
        
        _view2 = [[UIView alloc] initWithFrame:rect];
        _view2.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
    return _view2;
}

#pragma mark - Setters

@end
