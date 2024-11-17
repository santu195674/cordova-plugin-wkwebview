var exec = require('cordova/exec');

var WKWebViewPlugin = {
    open: function(url, showCloseButton, successCallback, errorCallback) {
        exec(successCallback, errorCallback, 'WKWebViewPlugin', 'open', [url, showCloseButton]);
    },
    hide: function(successCallback, errorCallback) {
        exec(successCallback, errorCallback, 'WKWebViewPlugin', 'hide', []);
    }
};

module.exports = WKWebViewPlugin;
