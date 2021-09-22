#include <hl.h>

#include "YojimboHelpers.h"
#include "hl_string_helpers.h"



vstring * addressToString( const yojimbo::Address *address) {
    char buffer[256];
    const char *str = address->ToString(buffer, 256);
    return hl_utf8_to_hlstr(str);
}


HL_PRIM uchar *hl_to_utf16( const char *str ) {
	int len = hl_utf8_length((vbyte*)str,0);
	uchar *out = (uchar*)hl_gc_alloc_noptr((len + 1) * sizeof(uchar));
	hl_from_utf8(out,len,str);
	return out;
}

HL_PRIM vbyte* hl_utf8_to_utf16( vbyte *str, int pos, int *size ) {
	int ulen = hl_utf8_length(str, pos);
	uchar *s = (uchar*)hl_gc_alloc_noptr((ulen + 1)*sizeof(uchar));
	hl_from_utf8(s,ulen,(char*)(str+pos));
	*size = ulen << 1;
	return (vbyte*)s;
}



static vdynamic * utf8_to_dynamic( const char *str) {
int strLen = (int)strlen( str );
    printf("Address is %s,%d\n", str, strLen);

    uchar * ubuf = (uchar*)hl_gc_alloc_noptr((strLen + 1) << 1);
    hl_from_utf8( ubuf, strLen, str );

    vdynamic *d = hl_alloc_dynamic(&hlt_bytes);
	d->v.ptr = hl_copy_bytes((vbyte*)ubuf,(strLen + 1) << 1);
    return d;
}

vdynamic * addressToDynamic( const yojimbo::Address *address) {
    char buffer[256];
    const char *str = address->ToString(buffer, 256);
    return utf8_to_dynamic(str);
}