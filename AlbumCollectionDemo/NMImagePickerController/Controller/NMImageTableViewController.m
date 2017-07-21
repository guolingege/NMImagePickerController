//
//  NMImageTableViewController.m
//  AlbumCollectionDemo
//
//  Created by 孙国林 on 2017/7/18.
//  Copyright © 2017年 孙国林. All rights reserved.
//

#import "NMImageTableViewController.h"
#import "NMImageTableViewCell.h"
#import "NMImageCollectionViewController.h"

@interface NMImageTableViewController ()

@end

@implementation NMImageTableViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = @"照片";
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.tableView.indexPathForSelectedRow) {
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.clearsSelectionOnViewWillAppear = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancel)];
    
    [self.tableView registerClass:[NMImageTableViewCell class] forCellReuseIdentifier:NMImageTableViewCellID];
    self.tableView.rowHeight = NMImageTableViewCellHeight;
    self.tableView.tableFooterView = UIView.new;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancel {
    [self.delegate imageTableViewControllerDidCancel:self];
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)setModelsArray:(NSArray<NMImageTableViewCellModel *> *)modelsArray {
    _modelsArray = modelsArray;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _modelsArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NMImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NMImageTableViewCellID forIndexPath:indexPath];
    cell.model = self.modelsArray[indexPath.row];
    return cell;
}

#pragma mark- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NMImageCollectionViewController *icvc = NMImageCollectionViewController.new;
    icvc.model = self.modelsArray[indexPath.row];
    icvc.maximumSelectionCount = self.maximumSelectionCount;
    icvc.delegate = (id)self.navigationController;
    [self.navigationController pushViewController:icvc animated:YES];
}

@end
