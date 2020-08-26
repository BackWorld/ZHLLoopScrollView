//
//  ZHLLoopScrollView.h
//  GroupedCollectionView
//
//  Created by Ios on 2020/8/25.
//  Copyright © 2020 zhl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZHLLoopScrollView;
@protocol ZHLLoopScrollViewDataSource <NSObject>

@required
- (NSUInteger)numerOfItemsForLoopScrollView:(ZHLLoopScrollView *)loopScrollView;

- (UIView *)viewAtIndex:(NSUInteger)index forLoopScrollView:(ZHLLoopScrollView *)loopScrollView;

@end


NS_ASSUME_NONNULL_BEGIN

@interface ZHLLoopScrollView : UIView

#pragma mark - Views

#pragma mark - Datas

/// 数据源
@property(nonatomic, weak)id<ZHLLoopScrollViewDataSource> dataSource;
/// 滚动间隔: default=3s
@property(nonatomic)NSTimeInterval scrollDuration;

#pragma mark - Methods
/// 刷新数据
- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
