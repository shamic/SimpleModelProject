//
//  ViewController.m
//  SimpleModelProject
//
//  Created by Shamic on 17/3/13.
//  Copyright © 2017年 shamic. All rights reserved.
//

#import "ViewController.h"
#import "MFHTTPSessionManager.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[MFHTTPSessionManager mobileInstance] POST:@"service/getIpInfo.php" parameters:@{@"ip":@"myip"} success:^(id responseObject) {
        self.label.text = [NSString stringWithFormat:@"IP: %@\n\nAddress: %@-%@-%@(%@)",
                           responseObject[@"data"][@"ip"],
                           responseObject[@"data"][@"country"],
                           responseObject[@"data"][@"region"],
                           responseObject[@"data"][@"city"],
                           responseObject[@"data"][@"isp"]];
    } failure:^(NSError *error) {
        self.label.text = @"null";
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
