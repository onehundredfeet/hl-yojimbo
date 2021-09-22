#ifndef __HL_STRING_HELPERS__
#define __HL_STRING_HELPERS__

#pragma once

#include <hl.h>

void hl_cache_string_type( vstring *str);
vstring * hl_utf8_to_hlstr( const char *str);

#endif