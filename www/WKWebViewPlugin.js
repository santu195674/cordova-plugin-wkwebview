/**
 * WKWebViewPlugin
 *
 * This Cordova plugin allows you to open a webpage using WKWebView with a custom navigation bar that includes a close button.
 * It also provides functionality to hide the WKWebView.
 *
 * Usage:
 *
 * // Open a webpage with a close button
 * WKWebViewPlugin.open('https://example.com', true, function(result) {
 *     console.log('Webpage opened successfully');
 * }, function(error) {
 *     console.error('Error opening webpage: ' + error);
 * });
 *
 * // Hide the WKWebView
 * WKWebViewPlugin.hide(function(result) {
 *     console.log('WebView hidden successfully');
 * }, function(error) {
 *     console.error('Error hiding WebView: ' + error);
 * });
 */

var exec = require('cordova/exec');

var WKWebViewPlugin = {
    /**
     * Open a webpage using WKWebView.
     *
     * @param {string} url - The URL of the webpage to open.
     * @param {boolean} showCloseButton - Whether to show the close button.
     * @param {function} successCallback - The callback function to execute on success.
     * @param {function} errorCallback - The callback function to execute on error.
     */
    open: function(url, showCloseButton, successCallback, errorCallback) {
        exec(successCallback, errorCallback, 'WKWebViewPlugin', 'open', [url, showCloseButton]);
    },

    /**
     * Hide the WKWebView.
     *
     * @param {function} successCallback - The callback function to execute on success.
     * @param {function} errorCallback - The callback function to execute on error.
     */
    hide: function(successCallback, errorCallback) {
        exec(successCallback, errorCallback, 'WKWebViewPlugin', 'hide', []);
    }
};

module.exports = WKWebViewPlugin;
