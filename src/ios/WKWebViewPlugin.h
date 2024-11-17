#import <Cordova/CDVPlugin.h>
#import <WebKit/WebKit.h>

@interface WKWebViewPlugin : CDVPlugin<WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler>
- (void)open:(CDVInvokedUrlCommand*)command;
- (void)hide:(CDVInvokedUrlCommand*)command;
@end

