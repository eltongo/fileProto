#define IS_IOS_8_OR_LATER ([NSProcessInfo instancesRespondToSelector:@selector(isOperatingSystemAtLeastVersion:)])
#define IS_MIN_IOS_VERSION(VER) ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:VER])
#define IOS_9_0 (NSOperatingSystemVersion){9, 0, 0}
#define IOS_10_0 (NSOperatingSystemVersion){10, 0, 0}
#define IOS_13_0 (NSOperatingSystemVersion){13, 0, 0}
#import <objc/runtime.h>
#include <mach-o/dyld.h>

NS_INLINE BOOL fakeUrlIfFileProtocol(NSMutableURLRequest *request) {
    // get the original url
    NSURL *originalUrl = [request URL];
    
    // we won't make any changes if the URL doesn't start with file://
    BOOL urlStartsWithFile = [[originalUrl absoluteString] hasPrefix:@"file://"];
    
    if (urlStartsWithFile) {
        // temporarily change URL so that Safari doesn't see we are actually trying to load a file:// URL
		[request setURL: [NSURL URLWithString:@"http://www.google.com"]];
    }
    
    return urlStartsWithFile;
}

NS_INLINE BOOL shouldAllowNavigationActionWithRequest(NSMutableURLRequest *request) {    
    // if URL starts with file://, we should automatically allow the request
    return [[[request URL] absoluteString] hasPrefix:@"file://"];
}

typedef NS_ENUM(NSInteger, WKNavigationActionPolicy) {
    WKNavigationActionPolicyCancel,
    WKNavigationActionPolicyAllow,
};

typedef void (^DecisionHandlerBlock) (WKNavigationActionPolicy);

%group iOS10
    %hook TabDocument
        - (void)webView: (id) webview decidePolicyForNavigationAction: (id) action decisionHandler: (id) handler {
            if (shouldAllowNavigationActionWithRequest([action performSelector: @selector(request)])) {
                ((DecisionHandlerBlock) handler)(WKNavigationActionPolicyAllow);
            } else {
                %orig;
            }
        }
    %end
%end

%group iOS13

    %hook TabDocument
        - (void)_internalWebView: (id) webview decidePolicyForNavigationAction: (id) action preferences: (id) prefs decisionHandler: (id) handler {
            if (shouldAllowNavigationActionWithRequest([action performSelector: @selector(request)])) {
                ((DecisionHandlerBlock) handler)(WKNavigationActionPolicyAllow);
            } else {
                %orig;
            }
        }
    %end
%end

%group iOS9
    %hook TabDocument
        - (void)_decidePolicyForAction:(id)arg1 request:(id)arg2 inMainFrame:(_Bool)arg3 forNewWindow:(_Bool)arg4 currentURLIsFileURL:(_Bool)arg5 decisionHandler:(id)arg6 {
            NSURL *originalUrl = [arg2 URL];
            
            BOOL urlWasFaked = fakeUrlIfFileProtocol(arg2);

            // call the original function
            %orig;

            if (urlWasFaked) {
                // restore original file:// URL
                [arg2 setURL:originalUrl];
            }
        }
    %end
%end

%group iOS8
    %hook TabDocument
        - (void)_decidePolicyForAction:(id)arg1 request:(id)arg2 inMainFrame:(_Bool)arg3 forNewWindow:(_Bool)arg4 currentURLIsFileURL:(_Bool)arg5 decisionListener:(id)arg6 {
            NSURL *originalUrl = [arg2 URL];
            
            BOOL urlWasFaked = fakeUrlIfFileProtocol(arg2);

            // call the original function
            %orig;

            if (urlWasFaked) {
                // restore original file:// URL
                [arg2 setURL:originalUrl];
            }
        }
    %end
%end

%group BrowserControllerBugFix
    NSString* badURL = @"file://";
    NSString* goodURL = @"file:///";

    %hook BrowserController        
        - (void) goToAddress: (NSString*) address {
            if ([address isEqualToString: badURL]) {
                %orig(goodURL);
            } else {
                %orig;
            }
        }
    %end
%end

// select appropriate method to hook onto, based on the iOS version.
%ctor {
    if IS_IOS_8_OR_LATER {
        if IS_MIN_IOS_VERSION(IOS_13_0) {
            %init(iOS13);
            return;
        } if IS_MIN_IOS_VERSION(IOS_10_0) {
            %init(iOS10);
            return;
        } else if IS_MIN_IOS_VERSION(IOS_9_0) {
            %init(iOS9);
        } else {
            %init(iOS8);
        }
        
        // just to make sure the method exists. Used to fix a nasty bug (seen in iOS 9) which crashes Safari when browsing to file://
        if ([[%c(BrowserController) performSelector:@selector(sharedBrowserController)] respondsToSelector: @selector(goToAddress:)]) {
            %init(BrowserControllerBugFix);
        }
    }
}
