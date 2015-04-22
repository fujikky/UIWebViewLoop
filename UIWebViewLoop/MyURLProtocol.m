//
//  MyURLProtocol.m
//  UIWebViewLoop
//
//  Created by Stud Fujiki on 2015/04/22.
//  Copyright (c) 2015年 Lurf. All rights reserved.
//

#import "MyURLProtocol.h"

// ループを防ぐためにHTTPリクエストヘッダーに追加する
static NSString *const MyWebViewResponseCheckHeader = @"X-iOS-WebView-Response-Check";

static NSString *const MyErrorDomain = @"com.example.error";
static const NSInteger MyHTTPResponseError = -1000;

@interface MyURLProtocol ()

@property (nonatomic) NSMutableURLRequest *mutableURLRequest;

@end


@implementation MyURLProtocol

/*!
 クラスロード時に、URL Loading Systemに登録してしまう
 UIWebView/NSURLConnectionなどの通信は、このクラスを利用するようになる
 */
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [NSURLProtocol registerClass:[self class]];
    });
}

#pragma mark - URLProtocol.

/*!
 WebViewでページ遷移するものだけフィルターしてNSURLProtocolで処理する
 UIWebViewのリクエストのみ処理する
 css/js/画像(data:base64;も含む)/APIリクエストは処理しない
 */
+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    // MARK: NSURLProtocolで処理済みならスルー
    if ([request valueForHTTPHeaderField:MyWebViewResponseCheckHeader]) {
        return NO;
    }
    
    return YES;
}

// override
- (NSURLRequest *)request
{
    return [self.mutableURLRequest copy];
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

- (id)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id<NSURLProtocolClient>)client
{
    self = [super initWithRequest:request cachedResponse:cachedResponse client:client];
    if (self) {
        NSMutableURLRequest *mutableRequest = [request mutableCopy];
        // Loop guard.
        [mutableRequest setValue:@"1" forHTTPHeaderField:MyWebViewResponseCheckHeader];
        
        self.mutableURLRequest = mutableRequest;
    }
    return self;
}

- (void)startLoading
{
    NSLog(@"request: %@", self.request);
    NSLog(@"request.headers: %@", self.request.allHTTPHeaderFields);
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection
     sendAsynchronousRequest:self.request
     queue:queue
     completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
         if (error) {
             NSLog(@"reponse error: %@", error);
             // NSURLProtocolClientのdidFailWithErrorを呼び出すと
             // UIWebViewDelegateのwebView:didFailLoadWithError:が呼ばれる(こっちはいつもどおり)
             [self.client URLProtocol:self didFailWithError:error];
             return;
         }
         
         NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
         
         // MARK: UIWebViewの代わりにステータスコードをチェックする
         if (httpResponse.statusCode >= 400) {
             NSLog(@"status error: %ld", (long)httpResponse.statusCode);
             // 独自エラーオブジェクトを作成して、NSURLProtocolClientのdidFailWithErrorを呼び出す
             // 同じくUIWebViewDelegateのwebView:didFailLoadWithError:が呼ばれる
             NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"エラーっぽい"};
             NSError *httpStatusError = [NSError errorWithDomain:MyErrorDomain code:MyHTTPResponseError userInfo:userInfo];
             [self.client URLProtocol:self didFailWithError:httpStatusError];
             return;
         }
         
         // 正常終了
         [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
         [self.client URLProtocol:self didLoadData:data];
         [self.client URLProtocolDidFinishLoading:self];
     }];
}

- (void)stopLoading
{
    NSLog(@"request: %@", self.request);
    NSLog(@"request.headers: %@", self.request.allHTTPHeaderFields);
}

@end