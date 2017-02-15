//
//  ViewController.m
//  SGLivingPublisher
//
//  Created by iossinger on 17/2/4.
//  Copyright © 2017年 iossinger. All rights reserved.
//

#import "ViewController.h"
#import "SGSimpleSession.h"
#import "SGAudioConfig.h"
#import "SGVideoConfig.h"

#define RTMP_URL  @"rtmp://192.168.1.25/live/2005"

@interface ViewController ()<SGSimpleSessionDelegate>

@property (nonatomic,strong) SGSimpleSession *session;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightItem;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [UIColor redColor];
    self.navigationItem.title = @"未连接";
    
    self.session = [SGSimpleSession defultSession];
    self.session.videoConfig = [SGVideoConfig defaultConfig];
    self.session.audioConfig = [SGAudioConfig defaultConfig];
    
    self.session.url = RTMP_URL;
    self.session.delegate = self;
    
    self.session.preview.frame = self.view.bounds;
    
    [self.view insertSubview:self.session.preview atIndex:0];
}

- (IBAction)didClicked:(UIBarButtonItem *)sender {
    switch (self.session.state) {
        case SGSimpleSessionStateConnecting:
        case SGSimpleSessionStateConnected:
        {
            [self.session endSession];
        }
            break;
            
        default:
        {
            [self.session startSession];
        }
            break;
    }
}

- (void)simpleSession:(SGSimpleSession *)simpleSession statusDidChanged:(SGSimpleSessionState)status{

    switch (status) {
        case SGSimpleSessionStateConnecting:
        {
            self.navigationController.navigationBar.barTintColor = [UIColor orangeColor];
            self.navigationItem.title = @"连接中...";
        }
            break;
        case SGSimpleSessionStateConnected:
        {
            self.navigationController.navigationBar.barTintColor = [UIColor greenColor];
            self.navigationItem.title = @"已连接";
            self.rightItem.title = @"结束";
        }
            break;
        default:
        {
            self.navigationController.navigationBar.barTintColor = [UIColor redColor];
            self.navigationItem.title = @"未连接";
            self.rightItem.title = @"开始";
        }
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
