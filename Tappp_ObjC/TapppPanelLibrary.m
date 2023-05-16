//
//  TapppPanelLibrary.m
//  Tappp_ObjC
//
//  Created by MA-15 on 20/04/23.
//

#import "TapppPanelLibrary.h"

@interface TapppPanelLibrary() <WKNavigationDelegate, WKScriptMessageHandler>
@end

@implementation TapppPanelLibrary
@synthesize webView;
@synthesize view;
@synthesize timer;
@synthesize objectPanelData;

- (void)initPanel:(NSDictionary *)tapppContext currView:(UIView *)currView {
    objectPanelData = tapppContext;
    
    NSDictionary *dict = tapppContext[@"gameInfo"];
    NSString *broadcasterName = dict[@"broadcasterName"];
    if (broadcasterName == nil) {
        return;
    }

    NSString *environment = dict[@"evr"];
    if (environment == nil) {
        return;
    }
    
    self.webView.translatesAutoresizingMaskIntoConstraints = false;
    self.view = currView;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *strURL = [NSString stringWithFormat:@"https://registry.tappp.com/appInfo?broadcasterName=%@&device=web&environment=%@&appVersion=1.1", broadcasterName, environment];
        [self geRegistryServiceDetail:strURL andCompletionHandler:^(NSString *result) {
            self.appURL = result;
            NSLog(@"self.appURL : %@", self.appURL);
        }];
    });

    dispatch_async(dispatch_get_main_queue(), ^(void){
        self.timer = [NSTimer scheduledTimerWithTimeInterval: 1.0
                              target: self
                              selector:@selector(startPanel)
                              userInfo: nil repeats:YES];
    });
}


- (void)startPanel{
    if (_appURL.length > 0){
        [self.timer invalidate];
        NSLog(@" Timer Performed ");
        NSBundle *pdBundle = [NSBundle bundleForClass:[TapppPanelLibrary class]];
        NSBundle *resourcesBundle = [pdBundle pathForResource:@"Resources" ofType:@"bundle"];
        NSBundle *resourcesBundle1 = [NSBundle bundleWithPath:resourcesBundle];
        NSString *htmlFile = [resourcesBundle1 pathForResource:@"index" ofType:@"html"];
        
        NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
        
        webView = [[WKWebView alloc] initWithFrame:view.frame];
        webView.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
        //[webView loadHTMLString:htmlString baseURL: [[NSBundle mainBundle] bundleURL]];
        [webView loadHTMLString:htmlString baseURL: resourcesBundle1.bundleURL];
        //webView.backgroundColor = UIColor.whiteColor;
        webView.configuration.preferences.javaScriptEnabled = true;
        webView.navigationDelegate = self;
        [view addSubview:webView];
    }
}

-(void)geRegistryServiceDetail:(NSString*)inputURL andCompletionHandler:(void (^)(NSString* result))completionHandler{
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:inputURL]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    
    NSData *postData = [[NSData alloc] initWithData:[@"" dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:postData];
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
            dispatch_semaphore_signal(sema);
        } else {
            //NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            NSError *parseError = nil;
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            
            NSLog(@"%@",responseDictionary);
            if([[responseDictionary objectForKey:@"code"] intValue] == 200)
            {
                NSArray *obj = [responseDictionary objectForKey:@"data"];
                NSDictionary *appDict = obj[0][@"appInfo"];
                NSArray *microAppList = appDict[@"microAppList"];
                
                NSArray *channeList = [microAppList.firstObject objectForKey:@"chanelList"];
                //NSLog(@"%d", [channeList count]);
                for (int i = 0; i < [channeList count]; i++) {
                    return completionHandler([channeList objectAtIndex:i][@"appURL"]);
                    /*if ([UIDevice currentDevice].model != @"iPhone")
                    {
                        if ([channeList objectAtIndex:i][@"chanelName"] == @"webApp"){
                            NSLog(@"%@", [channeList objectAtIndex:i][@"appURL"]);
                            completionHandler([channeList objectAtIndex:i][@"appURL"]);
                        }
                    } else {
                        if ([channeList objectAtIndex:i][@"chanelName"] == @"smartApp"){
                            NSLog(@"%@", [channeList objectAtIndex:i][@"appURL"]);
                            completionHandler([channeList objectAtIndex:i][@"appURL"]);
                        }
                    }*/
                    
                    //NSLog(@"%@", [channeList objectAtIndex:i][@"chanelName"]);
                }
                completionHandler(@"");
            }
            dispatch_semaphore_signal(sema);
        }
    }];
    [dataTask resume];
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
}

-(void)loadDataJS:(NSDictionary*)objectPanelData{
    NSDictionary *dict = objectPanelData[@"gameInfo"];
    NSString *gameId = dict[@"gameId"];
    NSString *broadcasterName = dict[@"broadcasterName"];
    NSString *user_id = dict[@"user_id"];

    NSString* script = [NSString stringWithFormat:@"handleMessage(\'%@\',\'1000009\', \'100\', \'%@\', \'%@\', \'%\', \'%@\', \'iPhone\', \'prod\')", gameId, broadcasterName, user_id,self.appURL];

    [self.webView evaluateJavaScript:script completionHandler:^(id result, NSError * _Nullable error) {
        __block NSString *resultString = nil;
        if (error == nil) {
            if (result != nil) {
                resultString = [NSString stringWithFormat:@"%@", result];
            }
        } else {
            NSLog(@"evaluateJavaScript error : %@", error.localizedDescription);
        }
    }];

}


-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    
}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    [self loadDataJS: objectPanelData];
}

-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
}

- (void)userContentController:(nonnull WKUserContentController *)userContentController didReceiveScriptMessage:(nonnull WKScriptMessage *)message {
    printf(@"%@",message);
}

@end
