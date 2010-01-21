#define DDEBUG 1
#include "ddebug.h"

#include "ngx_http_xss_util.h"

%% machine javascript;
%% write data;

ngx_int_t ngx_http_xss_test_callback(char *data, size_t len)
{
    char *p = data;
    char *pe = data + len;
    int cs;

    %%{
        identifier = [$A-Za-z] [$A-Za-z0-9_]*;

        index = [0-9]* '.' [0-9]+
              | [0-9]+
              ;

        main := identifier (identifier)*
                  ('[' index ']')? ;

        write init;
        write exec;
    }%%

    if (cs < %%{ write first_final; }%% || p != pe) {
        return NGX_DECLINED;
    }

    return NGX_OK;
}

