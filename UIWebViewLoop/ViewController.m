//
//  ViewController.m
//  UIWebViewLoop
//
//  Created by Lurf on 2015/04/22.
//  Copyright (c) 2015年 Lurf. All rights reserved.
//

#import "ViewController.h"
#import "MyURLProtocol.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURL *url = [NSURL URLWithString:@"http://www.city.shibuya.tokyo.jp/katei/children/teate/kodomo_ij.html"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
}

@end
