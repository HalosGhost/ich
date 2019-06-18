#if !defined(MAIN_H)
#define MAIN_H

#pragma once

#include "common.h"

static struct lwan_key_value headers [] = {
    { .key = "content-security-policy", .value = "default-src 'self'" },
    { .key = "x-frame-options", .value = "SAMEORIGIN" },
    { .key = "x-xss-protection", .value = "1; mode=block" },
    { .key = "x-content-type-options", .value = "nosniff" },
    { .key = "referrer-policy", .value = "no-referrer" },
    { .key = "strict-transport-security", .value = "max-age=31536000; includeSubDomains" },
    { .key = NULL, .value = NULL }
};

LWAN_HANDLER(ip) {

    char buf [INET6_ADDRSTRLEN] = "";
    if ( !lwan_request_get_remote_address(request, buf) ) {
        return HTTP_INTERNAL_ERROR;
    }

    lwan_strbuf_set(response->buffer, buf, strlen(buf));
    response->headers = headers;
    response->mime_type = "text/plain; charset=UTF-8";

    return HTTP_OK;
}

#endif // MAIN_H

