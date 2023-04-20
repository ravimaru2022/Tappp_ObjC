//
//  TapppPanelLibrary.m
//  Tappp_ObjC
//
//  Created by MA-15 on 20/04/23.
//

#import "TapppPanelLibrary.h"

@implementation TapppPanelLibrary

- (void)initPanel:(NSDictionary *)tapppContext currView:(UIView *)currView {
    self.webView.translatesAutoresizingMaskIntoConstraints = false;
    NSString *strURL = @"https://registry.tappp.com/appInfo?broadcasterName=TRN&device=web&environment=dev&appVersion=1.1";
    [self geRegistryServiceDetail:strURL andCompletionHandler:^(NSString *result) {
        self.appURL = result;
        NSLog(@"self.appURL : %@", self.appURL);
        [self configureWebview:_view];
    }];
}

- (void)configureWebview:(UIView*)view{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
            NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
            self.webView = [[WKWebView alloc] initWithFrame:self.view.frame];
            self.webView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            [self.webView loadHTMLString:htmlString baseURL: [[NSBundle mainBundle] bundleURL]];
            self.webView.backgroundColor = UIColor.yellowColor;
            self.webView.navigationDelegate = self;
            [self.view addSubview:self.webView];
        });
    });
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

-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    
}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    NSLog(@"Finished navigating to url \(webView.url)");

    [self.webView evaluateJavaScript:@"myFunction('cb0403c8-0f3c-4778-8d26-c4a63329678b','1000009', '300', 'TRN', 'cf9bb061-a040-4f43-56546-525252678b', 'px', 'https://apps.tappp.com/mlr/mobile/bundle.js', 'iPhone')" completionHandler:^(id result, NSError * _Nullable error) {
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

-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
}

@end
