//
//  KJZuDanViewController.m
//  HYKJ
//
//  Created by information on 2020/8/24.
//  Copyright © 2020 hongyan. All rights reserved.
//

#import "KJZuDanViewController.h"
#import "KJZuDanDetailViewController.h"

// tool
#import "KJZuDanTool.h"

// model
#import "KJZuDanParam.h"

// table
#import "MJRefresh.h"
#import "KJZuDanTableViewCell.h"
#import "KJZuDanTableHeaderView.h"

// view
#import "KJZuDanSearchView.h"

@interface KJZuDanViewController ()<UITableViewDataSource,UITableViewDelegate,KJZuDanSearchViewDelegate,KJZuDanTableViewCellDelegate>

@property (nonatomic, strong) KJZuDanSearchView  *searchView;

// tableView
@property (nonatomic, weak) UIScrollView  *baseView;
@property (nonatomic, weak) UITableView  *tableView;
@property (nonatomic, weak) UILabel  *totalLabel;

// 分页
@property (nonatomic, assign) NSInteger pageNum;
@property (nonatomic, assign) NSInteger pageSize;

// data
@property (nonatomic, strong)  NSMutableArray *dataArray;

// condition
@property (nonatomic, copy) NSString *startDat;
@property (nonatomic, copy) NSString *endDat;
@property (nonatomic, copy) NSString *zddh;
@property (nonatomic, copy) NSString *hd;
@property (nonatomic, copy) NSString *yd;
@property (nonatomic, copy) NSString *ps;

@end

@implementation KJZuDanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 1.设置导航
    [self setupNav];
    
    // 2.tableView
    [self setTableView];
    
    // 3. do shanxuan
    [self shanxuan];
}

// 1.设置导航
- (void)setupNav {
    // 1. back
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"30"] style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    
    // 2. shanxuan
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"shanxuan"] style:UIBarButtonItemStyleDone target:self action:@selector(shanxuan)];
}

- (void)shanxuan {
    if (_searchView == nil) {
        _searchView = [KJZuDanSearchView searchView];
        _searchView.delegate = self;
        _searchView.alpha = 0;
        [self.view addSubview:_searchView];
        [_searchView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view);
            make.top.equalTo(self.baseView);
            make.right.equalTo(self.view);
            make.height.mas_equalTo(@(264));
        }];
    }
    if (_searchView.alpha == 0) {
        WEAKSELF
        [UIView animateWithDuration:0.25 animations:^{
            weakSelf.searchView.alpha = 1;
        }];
    } else {
        WEAKSELF
        [UIView animateWithDuration:0.25 animations:^{
            weakSelf.searchView.alpha = 0;
        }];
    }
}

// KJZuDanSearchViewDelegate
- (void)zudanSearchViewDidSearch:(KJZuDanSearchView *)searchView {
    [self shanxuan];
    self.startDat = searchView.startDat;
    self.endDat = searchView.endDat;
    self.zddh = searchView.zddh;
    self.hd = searchView.hd;
    self.yd = searchView.yd;
    self.ps = searchView.ps;
    [self.tableView.mj_header beginRefreshing];
}

// 2.tableView
- (void)setTableView {
    // 1. baseView
    UIScrollView *baseView = [[UIScrollView alloc] init];
    baseView.contentSize = CGSizeMake(1540.0f, 0.0f);
    _baseView = baseView;
    [self.view addSubview:baseView];
    [baseView mas_makeConstraints:^(MASConstraintMaker *make) {
        [[make trailing] leading].equalTo([self view]);

        MASViewAttribute *top = [self mas_topLayoutGuideBottom];
        MASViewAttribute *bottom = [self mas_bottomLayoutGuideTop];

        #ifdef __IPHONE_11_0    // 如果有这个宏，说明Xcode版本是9开始
            if (@available(iOS 11.0, *)) {
                top = [[self view] mas_safeAreaLayoutGuideTop];
                bottom = [[self view] mas_safeAreaLayoutGuideBottom];
            }
        #endif

        [make top].equalTo(top);
        [make bottom].equalTo(bottom).offset(-32);
    }];
    
    // 2. tableView
    UITableView *tableView = [[UITableView alloc] init];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshing)];
    self.tableView = tableView;
    [self.baseView addSubview:tableView];
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(@(0));
        make.width.mas_equalTo(@(1540));

        MASViewAttribute *top = [self mas_topLayoutGuideBottom];
        MASViewAttribute *bottom = [self mas_bottomLayoutGuideTop];

        #ifdef __IPHONE_11_0    // 如果有这个宏，说明Xcode版本是9开始
            if (@available(iOS 11.0, *)) {
                top = [[self view] mas_safeAreaLayoutGuideTop];
                bottom = [[self view] mas_safeAreaLayoutGuideBottom];
            }
        #endif

        [make top].equalTo(top);
        [make bottom].equalTo(bottom).offset(-32);
    }];
    
    [tableView registerNib:[UINib nibWithNibName:@"KJZuDanTableViewCell" bundle:nil] forCellReuseIdentifier:@"KJZuDanTableViewCellID"];
    
    // 3. bottomView
    UIView *bottomView = [[UIView alloc] init];
    bottomView.backgroundColor = RGB(0, 157, 133);
    [self.view addSubview:bottomView];
    
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        [[make leading] trailing].equalTo([self view]);

        MASViewAttribute *bottom = [self mas_bottomLayoutGuideTop];

        #ifdef __IPHONE_11_0    // 如果有这个宏，说明Xcode版本是9开始
            if (@available(iOS 11.0, *)) {
                bottom = [[self view] mas_safeAreaLayoutGuideBottom];
            }
        #endif
        [make height].mas_equalTo(@(32));
        [make bottom].equalTo(bottom);
    }];
    
    UILabel *totalLabel = [[UILabel alloc] init];
    totalLabel.frame = CGRectMake(10.0f, 6.0f, 200.0f, 20.0f);
    totalLabel.font = [UIFont systemFontOfSize:14];
    totalLabel.textColor = [UIColor whiteColor];
    totalLabel.text = [NSString stringWithFormat:@"运费合计: 0"];
    _totalLabel = totalLabel;
    [bottomView addSubview:totalLabel];
}

- (void)headerRefreshing {
    _pageNum = 1;
    _pageSize = 20;
    KJZuDanParam *zudanParam = [[KJZuDanParam alloc] init];
    zudanParam.startDat = self.startDat;
    zudanParam.endDat = self.endDat;
    zudanParam.zddh = self.zddh;
    zudanParam.hd = self.hd;
    zudanParam.yd = self.yd;
    zudanParam.ps = self.ps;
    zudanParam.page = self.pageNum;
    zudanParam.limit = self.pageSize;
    WEAKSELF
    [KJZuDanTool getZuDanList:zudanParam success:^(KJZuDanResult * _Nonnull result) {
        if ([result.data count] < 1) {
            [SVProgressHUD showInfoWithStatus:@"该查询条件下没有数据!"];
        }
        [self.dataArray removeAllObjects];
        [self.dataArray addObjectsFromArray:result.data];
        if ([result.total length] < 1) {
            result.total = @"0";
        }
        [self.totalLabel setText:[NSString stringWithFormat:@"运费合计: %@", result.total]];
        
        NSInteger pages = ( result.count + weakSelf.pageSize - 1 ) / weakSelf.pageSize;
        if (pages > 1) {
            self.pageNum ++;
            [self setupFooterRefreshing];
        } else {
            self.tableView.mj_footer = nil;
        }
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
    } failure:^(NSError * _Nonnull error) {
        [self.tableView.mj_header endRefreshing];
    }];
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)setupFooterRefreshing {
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshing)];
}

- (void)footerRefreshing {
    KJZuDanParam *zudanParam = [[KJZuDanParam alloc] init];
    zudanParam.startDat = self.startDat;
    zudanParam.endDat = self.endDat;
    zudanParam.zddh = self.zddh;
    zudanParam.hd = self.hd;
    zudanParam.yd = self.yd;
    zudanParam.ps = self.ps;
    zudanParam.page = self.pageNum;
    zudanParam.limit = self.pageSize;
    WEAKSELF
    [KJZuDanTool getZuDanList:zudanParam success:^(KJZuDanResult * _Nonnull result) {
        [self.dataArray addObjectsFromArray:result.data];
        [self.tableView reloadData];
        self->_pageNum ++;
        NSInteger totalPage = ( result.count + weakSelf.pageSize - 1) / weakSelf.pageSize;
        if (self->_pageNum > totalPage) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        } else {
            [self.tableView.mj_footer endRefreshing];
        }
    } failure:^(NSError * _Nonnull error) {
        [self.tableView.mj_footer endRefreshing];
    }];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - talbeView dataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KJZuDanTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KJZuDanTableViewCellID" forIndexPath:indexPath];
    cell.delegate = self;
    
    KJZuDan *zudan = self.dataArray[indexPath.row];
    cell.zudan = zudan;
    
    return cell;
}

#pragma mark - KJZuDanTableViewCellDelegate
- (void)zudanTableViewCellShowDetail:(KJZuDanTableViewCell *)tableViewCell {
    KJZuDanDetailViewController *detailVc = [[KJZuDanDetailViewController alloc] initWithZspnum:tableViewCell.zudan.zspnum];
    detailVc.view.backgroundColor = [UIColor whiteColor];
    detailVc.title = @"组单详情";
    [self.navigationController pushViewController:detailVc animated:YES];
}

#pragma mark - tableView delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    KJZuDanTableHeaderView *headerView = [KJZuDanTableHeaderView headerView];
    headerView.frame = CGRectMake(0.0f, 0.0f, 1540.0f, 44.0f);
    return headerView;
}

#pragma mark - rotation
- (BOOL)shouldAutorotate{
    return YES;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAll;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

@end
