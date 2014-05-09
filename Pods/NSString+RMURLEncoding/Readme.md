# NSString+RMURLEncoding

Adds URL encoding helpers to NSString.

    #import "NSString+RMURLEncoding.h"

    …
    
    NSString *str = @"Foo: The Quest for \"Bar\"";
    NSString *encoded = [str rm_URLEncodedString];
    // => @"Foo%3A%20The%20Quest%20for%20%5C%22Bar%5C%22"
