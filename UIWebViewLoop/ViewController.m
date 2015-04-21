//
//  ViewController.m
//  UIWebViewLoop
//
//  Created by Lurf on 2015/04/22.
//  Copyright (c) 2015年 Lurf. All rights reserved.
//

#import "ViewController.h"

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
    //このif文でreturnNOすれば回避できそうだけどiFrameも消えるのでNG
    if (![request.URL.absoluteString isEqualToString:request.mainDocumentURL.absoluteString]) {
        //http://www.city.shibuya.tokyo.jp/index.html?_=0.31560527184046805 系のURLリクエストはjsで生成している模様
        NSLog(@"%@", request.URL);
        NSLog(@"%f", request.timeoutInterval); //int maxっぽい数値
//        return NO;
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {

}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {

}

- (void)webViewDidFinishLoad:(UIWebView *)webView {

}

@end
