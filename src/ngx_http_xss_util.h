#ifndef NGX_HTTP_XSS_UTIL_H
#define NGX_HTTP_XSS_UTIL_H

#include <ngx_core.h>
#include <ngx_http.h>


ngx_int_t ngx_http_xss_test_callback(char *data, size_t len);


#endif /* NGX_HTTP_XSS_UTIL_H */

