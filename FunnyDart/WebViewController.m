/*
 ============================================================================
 Name        : WebViewController.m
 Version     : 1.0.0
 Copyright   :
 Description :
 ============================================================================
 */

#import <WebKit/WebKit.h>

#import "WebViewController.h"
#import "JSONKit/JSONKit.h"


@interface WebViewController () <WKNavigationDelegate>
{
    IBOutlet WKWebView* _webView;
    
    NSString* _url;
    BOOL _isLoaded;
}

@end

@implementation WebViewController

@synthesize url = _url;

- (void)dealloc
{
}

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.preferences.minimumFontSize = 0.0f;
    configuration.userContentController = [WKUserContentController new];
    
    [configuration.userContentController addScriptMessageHandler:self name:@"openUrl"];
    
    
    _webView = [[WKWebView alloc] initWithFrame:[UIScreen mainScreen].bounds configuration:configuration];
    _webView.navigationDelegate = self;
    _webView.scrollView.scrollEnabled = YES;
    [_webView setBackgroundColor:[UIColor blackColor]];
    [self reloadData];
    
    [self.view addSubview:_webView];
    
    _webView.translatesAutoresizingMaskIntoConstraints = NO;
    
    
    NSLayoutConstraint* topLayout = [NSLayoutConstraint constraintWithItem:_webView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    
    NSLayoutConstraint* leadingLayout = [NSLayoutConstraint constraintWithItem:_webView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
    
    NSLayoutConstraint* bottomLayout = [NSLayoutConstraint constraintWithItem:_webView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    
    NSLayoutConstraint* trailingLayout = [NSLayoutConstraint constraintWithItem:_webView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
    
    [self.view addConstraints:@[topLayout, leadingLayout, bottomLayout, trailingLayout]];
}
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"===message.name=%@",message.name);
    NSLog(@"===message.body=%@",message.body);
    if ([message.name isEqualToString:@"openUrl"]) {
        [self openUrl:message.body];
    }else if ([message.name isEqualToString:@"openAppUrl"]) {
        [self openAppUrl:message.body];
    }
}

-(void) openAppUrl:(NSString*)url
{
    NSString *encodedValue = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *itunesURL = [NSURL URLWithString:encodedValue];//[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id443904275"];
    [[UIApplication sharedApplication] openURL:itunesURL];
}
-(void)openUrl:(NSString*)url{
    NSLog(@"======openur=%@",url);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)reloadData
{
    if (!_isLoaded)
    {
        //[self getURL];
        
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_url]];
        [_webView loadRequest:request];
    }
}

- (void)getURL
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
    ^{
       NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
       request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
       
       NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
       [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://zgzysqbj.com/jetbooklet.json?ver=%@", [infoDictionary objectForKey:@"CFBundleShortVersionString"]]]];
       [request setHTTPMethod:@"GET"];
       
       NSError* error = nil;
       NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
       if (nil != data)
       {
           NSString* strData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
           NSData* decodedData = [[NSData alloc] initWithBase64EncodedString:strData options:NSDataBase64DecodingIgnoreUnknownCharacters];
           strData = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
           if (nil != strData)
           {
               NSDictionary* dic = [strData objectFromJSONString];
               if (1 == [[dic objectForKey:@"showtype"] intValue])
               {
                   dispatch_async(dispatch_get_main_queue(),
                   ^{
                       _url = [dic objectForKey:@"image"];
                       
                       NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_url]];
                       [_webView loadRequest:request];
                   });
               }
               else if (0 == [[dic objectForKey:@"showtype"] intValue])
               {
                   dispatch_async(dispatch_get_main_queue(),
                   ^{
                       [[NSNotificationCenter defaultCenter] postNotificationName:@"SwitchToAppViewNotification" object:nil];
                   });
               }
           }
       }
    });
}

- (void)webView:(WKWebView*)webView didCommitNavigation:(WKNavigation*)navigation
{
    _isLoaded = YES;
}

- (void)webView:(WKWebView*)webView didFinishNavigation:(WKNavigation*)navigation
{
    _isLoaded = YES;
}

- (void)webView:(WKWebView*)webView didFailNavigation:(WKNavigation*)navigation withError:(NSError*)error
{
}

- (void)webView:(WKWebView*)webView didFailProvisionalNavigation:(WKNavigation*)navigation withError:(NSError*)error
{
}

- (void)webView:(WKWebView*)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge*)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential* credential))completionHandler
{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        NSURLCredential* card = [[NSURLCredential alloc]initWithTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, card);
    }
}

@end
