#include "hl_string_helpers.h"
#include <yojimbo/netcode.io/netcode.h>
//SUPER SKETCHY

static  hl_type *strType = nullptr;



void hl_cache_string_type( vstring *str) {
   strType = str->t;

    

   printf("SYSTEM PREAMBLE -- NEEX TO REMOVE THIS HACK: string type is %s, kind %d\n", hl_to_utf8(hl_type_str(str->t)), str->t->kind);
}

vstring * hl_utf8_to_hlstr( const char *str) {
    int strLen = (int)strlen( str );
    uchar * ubuf = (uchar*)hl_gc_alloc_noptr((strLen + 1) << 1);
    hl_from_utf8( ubuf, strLen, str );

    vstring* vstr = (vstring *)hl_gc_alloc_raw(sizeof(vstring));

    vstr->bytes = ubuf;
    vstr->length = strLen;
    vstr->t = strType;
    return vstr;
}