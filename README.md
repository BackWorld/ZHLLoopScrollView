# ZHLLoopScrollView
Implement a infinite changing item view.

# 效果
![Kapture 2020-08-26 at 16.08.08.gif](https://upload-images.jianshu.io/upload_images/1334681-222b2aaf5b4abcf2.gif?imageMogr2/auto-orient/strip)

# 思路
![示意图1](https://upload-images.jianshu.io/upload_images/1334681-d3d6d56d2fcd7c05.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
- 1、如图中所示，先让BlueView（下称bv）和GreenView的frame一起往上移动：bv移出view、gv移入view；
- 2、然后让bv的frame发生变动，瞬间移动到gv的下部，然后重复步骤1；
- 3、定义一个计数变量countIndex，不断+1，然后根据这个值调整bv和gv的frame；
- 4、定义一个索引变量itemIndex，不断+1，取用户数据源数据进行自定义ItemView的展示；

# 实现
- DataSource协议
```
@class ZHLLoopScrollView;
@protocol ZHLLoopScrollViewDataSource <NSObject>

@required
/// 数量
- (NSUInteger)numerOfItemsForLoopScrollView:(ZHLLoopScrollView *)loopScrollView;

/// 自定义item view
- (UIView *)viewAtIndex:(NSUInteger)index forLoopScrollView:(ZHLLoopScrollView *)loopScrollView;

@end
```
- 属性定义
```
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
```
- 核心方法
```
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
    
   /// 这里进行滚动动画
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
```
- reloadData
```
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
```
- item view展示
```
/// 构建item视图
- (void)addItemViewAtIndex:(NSUInteger)index forView:(UIView *)view{
    [view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIView *v = [self.dataSource viewAtIndex:index forLoopScrollView:self];
    v.frame = view.bounds;
    v.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
   
```
- Getters
```
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
```
# 使用
- 初始化
```
    CGRect rect = self.view.bounds;
    rect.size.height = 60;
    rect.origin.y = 200;
/// 这里也支持xib方式
    ZHLLoopScrollView *v = [[ZHLLoopScrollView alloc] initWithFrame:rect];
    v.dataSource = self;
    v.scrollDuration = 1.5;
    [self.view addSubview:v];
/// 这里也可以放在数据request的异步里
    [v reloadData];
```
- 数据源
```
- (NSUInteger)numerOfItemsForLoopScrollView:(ZHLLoopScrollView *)loopScrollView{
    return 5;
}

- (UIView *)viewAtIndex:(NSUInteger)index forLoopScrollView:(ZHLLoopScrollView *)loopScrollView{
/// 这是用户自定义的UIView，这里自行进行数据展示
    LoopItemView *v = [LoopItemView view];
    v.textLb.text = [@"这是直播: " stringByAppendingString:@(index).stringValue];
    return v;
}
```
# 简书
https://www.jianshu.com/p/2e2e54638d93
