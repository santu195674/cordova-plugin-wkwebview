#import "WKWebViewPlugin.h"

@implementation WKWebViewPlugin{
    WKWebView *webView;
    UIView *containerView;
    NSString *callbackId;
    UIActivityIndicatorView *loadingSpinner;
    
}

- (void)open:(CDVInvokedUrlCommand*)command {
    NSString* urlString = [command.arguments objectAtIndex:0];
    if (urlString == nil) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"URL cannot be null"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    if (url == nil) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Invalid URL"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    callbackId = command.callbackId;
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    WKUserContentController *userContentController = [[WKUserContentController alloc] init];
    [userContentController addScriptMessageHandler:self name:@"cordova_iab"];
    config.userContentController = userContentController;
    
    // Enable debug mode
#if DEBUG
    [config.preferences setValue:@YES forKey:@"developerExtrasEnabled"];
#endif
    
    containerView = [[UIView alloc] initWithFrame:self.viewController.view.bounds];
    containerView.backgroundColor = [UIColor whiteColor];
    
    CGFloat topBarHeight = 50.0;
    if (@available(iOS 11.0, *)) {
        CGFloat safeAreaTop = self.viewController.view.safeAreaInsets.top;
        topBarHeight += safeAreaTop;
    }
    
    webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, topBarHeight, self.viewController.view.bounds.size.width, self.viewController.view.bounds.size.height - topBarHeight) configuration:config];
    webView.UIDelegate = self;
    webView.navigationDelegate = self;
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
    
    // Create the top bar
    UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.viewController.view.safeAreaInsets.top, self.viewController.view.bounds.size.width, 50)];
    topBar.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0]; // Very light gray color
    topBar.autoresizingMask = UIViewAutoresizingFlexibleWidth; // Allows resizing on device rotation
    
    // Add a bottom border to the custom navigation bar
    UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, topBar.frame.size.height - 1, topBar.frame.size.width, 1)];
    bottomBorder.backgroundColor = [UIColor lightGrayColor];
    bottomBorder.autoresizingMask = UIViewAutoresizingFlexibleWidth; // Allows resizing on device rotation
    
    [topBar addSubview:bottomBorder];
    
    // Create the close button
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    closeButton.frame = CGRectMake(self.viewController.view.bounds.size.width - 60, 10, 50, 30);
    [closeButton setTitle:@"Close" forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeWebView) forControlEvents:UIControlEventTouchUpInside];
    [topBar addSubview:closeButton];
    
    [containerView addSubview:topBar];
    [containerView addSubview:webView];
    
    
    // Create and add the loading spinner
    if (@available(iOS 13.0, *)) {
        loadingSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    } else {
        loadingSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        
    }
    loadingSpinner.center = containerView.center;
    [loadingSpinner startAnimating];
    [containerView addSubview:loadingSpinner];
    
    // Add the container view to the main view
    [self.viewController.view addSubview:containerView];
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

// WKNavigationDelegate method to handle loading events
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [loadingSpinner stopAnimating];
    [loadingSpinner removeFromSuperview];
}

// Handle JavaScript alert
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completionHandler();
    }];
    [alertController addAction:okAction];
    [self.viewController presentViewController:alertController animated:YES completion:nil];
}

// Handle JavaScript confirm
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completionHandler(YES);
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completionHandler(NO);
    }];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    [self.viewController presentViewController:alertController animated:YES completion:nil];
}

// Handle JavaScript text input
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString *))completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:prompt preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = defaultText;
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *inputText = alertController.textFields.firstObject.text;
        completionHandler(inputText);
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completionHandler(nil);
    }];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    [self.viewController presentViewController:alertController animated:YES completion:nil];
}

// Handle messages from JavaScript
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"cordova_iab"]) {
        
        id messageBody = message.body;
        NSString *messageString = (NSString *)messageBody;
        
        NSLog(@"WKWebViewPlugin: Received message from Equinity: %@", messageString);
        
        // Perform any Cordova-related actions or call a JavaScript callback here
        // Example: Send message back to Cordova
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:messageBody];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
    }
}

- (void)closeWebView {
    [containerView removeFromSuperview];
    containerView = nil;
    webView = nil;
}

@end

