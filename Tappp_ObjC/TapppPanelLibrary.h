//
//  TapppPanelLibrary.h
//  Tappp_ObjC
//
//  Created by MA-15 on 20/04/23.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TapppPanelLibrary : NSObject
@property(strong,nonatomic) WKWebView *webView;
@property(strong, nonatomic) UIView *view;
@property (strong, nonatomic) NSString *appURL;
@end

NS_ASSUME_NONNULL_END
