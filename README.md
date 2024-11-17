# cordova-plugin-wkwebview
Access Webview using wkwebview for iOS

cordova plugin add https://github.com/santu195674/cordova-plugin-wkwebview.git


function onDeviceReady() {
    // Cordova is now initialized. Have fun!
    console.log('Running cordova-' + cordova.platformId + '@' + cordova.version);
    document.getElementById('deviceready').classList.add('ready');

    document.addEventListener('deviceready', function() {
        WKWebViewPlugin.open('https://green-drusie-40.tiiny.site', true, function(result) {
            console.log('WKWebViewPlugin: Webpage opened successfully');
            console.log('WKWebViewPlugin: Received data from native plugin:', result);
            // Handle the received data here
    
            // Example: Hide the WebView after 2 seconds
            setTimeout(function() {
                console.log('WKWebViewPlugin:  Time Out');
                WKWebViewPlugin.hide(function(result) {
                    console.log('WKWebViewPlugin: WebView hidden successfully');
                }, function(error) {
                    console.error('WKWebViewPlugin: Error hiding WebView: ' + error);
                });
            }, 2000);
        }, function(error) {
            console.error('WKWebViewPlugin: Error opening webpage: ' + error);
        });
    }, false);
}
