#ifndef __YOJIMBO_HELPERS_H_
#define __YOJIMBO_HELPERS_H_

#pragma once

#include <yojimbo/yojimbo.h>
#include <hl.h>

void cacheStringType( vstring *str);

vstring * addressToString( const yojimbo::Address *address);
vdynamic * addressToDynamic( const yojimbo::Address *address);

#endif