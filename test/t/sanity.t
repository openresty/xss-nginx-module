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
Content-Type: application/json
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
Content-Type: application/json
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
Content-Type: application/json
--- response_body chop
OpenResty.callbackMap[32]([]
);

