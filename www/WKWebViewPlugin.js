var exec = require('cordova/exec');

var WKWebViewPlugin = {
    open: function(url, successCallback, errorCallback) {
        exec(successCallback, errorCallback, 'WKWebViewPlugin', 'open', [url]);
    }
};

module.exports = WKWebViewPlugin;