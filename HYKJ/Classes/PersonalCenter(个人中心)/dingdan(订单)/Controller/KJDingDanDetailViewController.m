//
//  KJDingDanDetailViewController.m
//  HYKJ
//
//  Created by information on 2020/8/28.
//  Copyright © 2020 hongyan. All rights reserved.
//

#import "KJDingDanDetailViewController.h"

// tool
#import "KJDingDanTool.h"

// table
#import "MJRefresh.h"
#import "KJDingDanDetailTableViewCell.h"
#import "KJDingDanDetailTableHeaderView.h"

@interface KJDingDanDetailViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, copy) NSString *sohnum;

// tableView
@property (nonatomic, weak) UIScrollView  *baseView;
@property (nonatomic, weak) UITableView  *tableView;
@property (nonatomic, weak) UILabel  *totalLabel;

// data
@property (nonatomic, strong)  NSMutableArray *dataArray;

@end

@implementation KJDingDanDetailViewController

- (instancetype)initWithSohnum:(NSString *)sohnum {
    if (self = [super init]) {
        _sohnum = sohnum;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 1.设置导航
    [self setupNav];
    
    // 2.tableView
    [self setTableView];
}

// 1.设置导航
- (void)setupNav {
    // 1. back
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"30"] style:UIBarButtonItemStyleDone target:self action:@selector(back)];
}

// 2.tableView
- (void)setTableView {
    // 1. baseView
    UIScrollView *baseView = [[UIScrollView alloc] init];
    baseView.contentSize = CGSizeMake(1290.0f, 0.0f);
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
        [make bottom].equalTo(bottom);
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
        make.width.mas_equalTo(@(1290));

        MASViewAttribute *top = [self mas_topLayoutGuideBottom];
        MASViewAttribute *bottom = [self mas_bottomLayoutGuideTop];

        #ifdef __IPHONE_11_0    // 如果有这个宏，说明Xcode版本是9开始
            if (@available(iOS 11.0, *)) {
                top = [[self view] mas_safeAreaLayoutGuideTop];
                bottom = [[self view] mas_safeAreaLayoutGuideBottom];
            }
        #endif

        [make top].equalTo(top);
        [make bottom].equalTo(bottom);
    }];
    
    [tableView registerNib:[UINib nibWithNibName:@"KJDingDanDetailTableViewCell" bundle:nil] forCellReuseIdentifier:@"KJDingDanDetailTableViewCellID"];
    [tableView.mj_header beginRefreshing];
}

- (void)headerRefreshing {
    [KJDingDanTool getDingDanDetail:@{@"sohnum": _sohnum} success:^(NSArray * _Nonnull details) {
        if ([details count] < 1) {
            [SVProgressHUD showInfoWithStatus:@"该查询条件下没有数据!"];
        }
        [self.dataArray removeAllObjects];
        [self.dataArray addObjectsFromArray:details];
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
    KJDingDanDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KJDingDanDetailTableViewCellID" forIndexPath:indexPath];
    
    KJDingDanDetail *dingdanDetail = self.dataArray[indexPath.row];
    cell.dingdanDetail = dingdanDetail;
    
    return cell;
}

#pragma mark - tableView delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    KJDingDanDetailTableHeaderView *headerView = [KJDingDanDetailTableHeaderView headerView];
    headerView.frame = CGRectMake(0.0f, 0.0f, 1290.0f, 44.0f);
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
