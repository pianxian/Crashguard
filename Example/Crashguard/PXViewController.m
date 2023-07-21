//
//  PXViewController.m
//  Crashguard
//
//  Created by huweiwei on 07/21/2023.
//  Copyright (c) 2023 huweiwei. All rights reserved.
//

#import "PXViewController.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
@import PXxlogger;
@interface PXViewController ()

@end

@implementation PXViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)dic:(UIButton *)sender {
    NSMutableDictionary *dict = @{}.mutableCopy;
    [dict setObject:nil forKey:@"test"];
}
- (IBAction)array:(id)sender {
    NSMutableArray *array = @[].mutableCopy;
    [array addObject:nil];
}
- (IBAction)data:(id)sender {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:nil options:NSDataBase64DecodingIgnoreUnknownCharacters];
}
- (IBAction)dispatch:(id)sender {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    dispatch_async(dispatch_queue_create("crashguard.crashguard.com", DISPATCH_QUEUE_CONCURRENT), ^{
        [button setTitle:@"test" forState:UIControlStateNormal];
    });
}

- (IBAction)anr:(id)sender {
    sleep(9999999);
}


@end
