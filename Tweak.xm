%hook TabDocument
	- (void)_decidePolicyForAction:(id)arg1 request:(id)arg2 inMainFrame:(_Bool)arg3 forNewWindow:(_Bool)arg4 currentURLIsFileURL:(_Bool)arg5 decisionHandler:(id)arg6 {
		// arg2 is of type NSMutableURLRequest
		NSMutableURLRequest *req = (NSMutableURLRequest*) arg2;
		NSURL *originalUrl = [req URL];

		// we won't make any changes if the URL doesn't start with file://
		_Bool urlStartsWithFile = [[originalUrl absoluteString] hasPrefix:@"file://"];

		if (urlStartsWithFile) {
			// temporarily change URL so that Safari doesn't see we are actually trying to load a file:// URL
			[req setURL:[NSURL URLWithString:@"http://www.google.com"]];
		}

		// call the original function
		%orig(arg1, req, arg3, arg4, arg5, arg6);

		if (urlStartsWithFile) {
			[req setURL:originalUrl];
		}
	}
%end


