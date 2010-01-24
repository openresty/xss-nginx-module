# vi:filetype=perl

use lib 'lib';
use Test::Nginx::Socket;

repeat_each(1);

plan tests => repeat_each() * 3 * blocks();

no_long_string();

run_tests();

#no_diff();

__DATA__

=== TEST 1: skipped: no callback arg given
--- config
    location /foo {
        default_type 'application/json';
        xss_get on;
        xss_callback_arg foo;
        echo '[]';
    }
--- request
GET /foo
--- response_headers_like
Content-Type: application/json
--- response_body
[]



=== TEST 2: sanity
--- config
    location /foo {
        default_type 'application/json';
        xss_get on;
        xss_callback_arg a;
        echo '[]';
    }
--- request
GET /foo?foo=blar&a=bar
--- response_headers_like
Content-Type: application/x-javascript
--- response_body chop
bar([]
);



=== TEST 3: bug
--- config
    location /foo {
        default_type 'application/json';
        xss_get on;
        xss_callback_arg foo;
        echo '[]';
    }
--- request
GET /foo?foo=bar
--- response_headers_like
Content-Type: application/x-javascript
--- response_body chop
bar([]
);



=== TEST 4: uri escaped
--- config
    location /foo {
        default_type 'application/json';
        xss_get on;
        xss_callback_arg _callback;
        echo '[]';
    }
--- request
GET /foo?_callback=OpenResty.callbackMap%5b32%5D
--- response_headers_like
Content-Type: application/x-javascript
--- response_body chop
OpenResty.callbackMap[32]([]
);



=== TEST 5: test invalid callback
--- config
    location /foo {
        default_type 'application/json';
        xss_get on;
        xss_callback_arg _callback;
        echo '[]';
    }
--- request
GET /foo?_callback=a();b
--- response_headers_like
Content-Type: application/json
--- response_body
[]
--- error_code: 200



=== TEST 6: input type mismatch
--- config
    location /foo {
        default_type 'text/plain';
        xss_get on;
        xss_callback_arg foo;
        echo '[]';
    }
--- request
GET /foo?foo=bar
--- response_headers_like
Content-Type: text/plain
--- response_body
[]



=== TEST 7: input type match by setting xss_input_types
--- config
    location /foo {
        default_type 'text/plain';
        xss_get on;
        xss_callback_arg foo;
        xss_input_types text/plain text/css;
        echo '[]';
    }
--- request
GET /foo?foo=bar
--- response_headers_like
Content-Type: application/x-javascript
--- response_body chop
bar([]
);



=== TEST 8: set a different output type
--- config
    location /foo {
        default_type 'text/plain';
        xss_get on;
        xss_callback_arg foo;
        xss_input_types text/plain text/css;
        xss_output_type text/html;
        echo '[]';
    }
--- request
GET /foo?foo=bar
--- response_headers_like
Content-Type: text/html
--- response_body chop
bar([]
);


=== TEST 8: xss_get is on while no xss_callback_arg
--- config
    location /foo {
        default_type 'application/json';
        xss_get on;
        #xss_callback_arg foo;
        echo '[]';
    }
--- request
GET /foo?foo=bar
--- response_headers_like
Content-Type: application/json
--- response_body
[]

