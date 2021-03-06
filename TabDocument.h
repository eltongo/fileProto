// Header was originally generated with class-dump
// All unnecessary definitions were stripped off. 
// iOS 8.4 and iOS 10 method definitions were manually added (i.e. not generated)
@interface TabDocument 

// iOS 13
- (void)_internalWebView: (id) webview decidePolicyForNavigationAction: (id) action preferences: (id) prefs decisionHandler: (id) handler;

// iOS 10
- (void)webView: (id) webview decidePolicyForNavigationAction: (id) action decisionHandler: (id) handler;

// iOS 9
- (void)_decidePolicyForAction:(id)arg1 request:(id)arg2 inMainFrame:(_Bool)arg3 forNewWindow:(_Bool)arg4 currentURLIsFileURL:(_Bool)arg5 decisionHandler:(id)arg6;

// iOS 8.4
- (void)_decidePolicyForAction:(id)arg1 request:(id)arg2 inMainFrame:(_Bool)arg3 forNewWindow:(_Bool)arg4 currentURLIsFileURL:(_Bool)arg5 decisionListener:(id)arg6;

@end