/*
  This code implements one part of functonality of
  free available library PL/Vision. Please look www.quest.com

  Original author: Steven Feuerstein, 1996 - 2002
  PostgreSQL implementation author: Pavel Stehule, 2006-2023

  This module is under BSD Licence

  History:
    1.0. first public version 13. March 2006
*/


#include "postgres.h"
#include "utils/builtins.h"
#include "utils/numeric.h"
#include "utils/pg_locale.h"
#include "mb/pg_wchar.h"
#include "nodes/execnodes.h"

#include "catalog/pg_type.h"
#include "libpq/pqformat.h"
#include "orafce.h"
#include "builtins.h"

#include <string.h>
#include <stdlib.h>

PG_FUNCTION_INFO_V1(plvstr_instr2);
PG_FUNCTION_INFO_V1(plvstr_instr3);
PG_FUNCTION_INFO_V1(plvstr_instr4);

PG_FUNCTION_INFO_V1(oracle_substr2);
PG_FUNCTION_INFO_V1(oracle_substr3);

PG_FUNCTION_INFO_V1(oracle_substrb2);
PG_FUNCTION_INFO_V1(oracle_substrb3);

int orafce_substring_length_is_zero = ORAFCE_COMPATIBILITY_WARNING_ORACLE;

static text *ora_substr(Datum str, int start, int len);

#define ora_substr_text(str, start, len) \
	ora_substr(PointerGetDatum((str)), (start), (len))

static const char* char_names[] = {
	"NULL","SOH","STX","ETX","EOT","ENQ","ACK","DEL",
	"BS",  "HT", "NL", "VT", "NP", "CR", "SO", "SI",
	"DLE", "DC1","DC2","DC3","DC4","NAK","SYN","ETB",
	"CAN", "EM","SUB","ESC","FS","GS","RS","US","SP"
};

#define NON_EMPTY_CHECK(str) \
if (VARSIZE_ANY_EXHDR(str) == 0) \
	ereport(ERROR, \
			(errcode(ERRCODE_INVALID_PARAMETER_VALUE), \
			 errmsg("invalid parameter"), \
		 errdetail("Not allowed empty string.")));

#define PARAMETER_ERROR(detail) \
	ereport(ERROR, \
		(errcode(ERRCODE_INVALID_PARAMETER_VALUE), \
		 errmsg("invalid parameter"), \
		 errdetail(detail)));


#ifndef _pg_mblen
#define _pg_mblen	pg_mblen
#endif

typedef enum
{
	POSITION,
	FIRST,
	LAST
}  position_mode;

/*
 * Make substring, can handle negative start
 *
 */
int
ora_mb_strlen(text *str, char **sizes, int **positions)
{
	int r_len;
	int cur_size = 0;
	char *p;
	int cur = 0;

	p = VARDATA_ANY(str);
	r_len = VARSIZE_ANY_EXHDR(str);

	if (NULL != sizes)
		*sizes = palloc(r_len * sizeof(char));
	if (NULL != positions)
		*positions = palloc(r_len * sizeof(int));

	while (cur < r_len)
	{
		int sz;

		sz = _pg_mblen(p);
		if (sizes)
			(*sizes)[cur_size] = sz;
		if (positions)
			(*positions)[cur_size] = cur;
		cur += sz;
		p += sz;
		cur_size += 1;
	}

	return cur_size;
}


int
ora_mb_strlen1(text *str)
{
	int r_len;
	int c;
	char *p;

	r_len = VARSIZE_ANY_EXHDR(str);

	if (pg_database_encoding_max_length() == 1)
		return r_len;

	p = VARDATA_ANY(str);
	c = 0;
	while (r_len > 0)
	{
		int sz;

		sz = _pg_mblen(p);
		p += sz;
		r_len -= sz;
		c += 1;
	}

	return c;
}

/*
 * len < 0 means "length is not specified".
 */
static text *
ora_substr(Datum str, int start, int len)
{
	if (start == 0)
		start = 1;	/* 0 is interpreted as 1 */
	else if (start < 0)
	{
		text   *t;
		int32	n;

		t = DatumGetTextPP(str);
		n = pg_mbstrlen_with_len(VARDATA_ANY(t), VARSIZE_ANY_EXHDR(t));
		start = n + start + 1;
		if (start <= 0)
			return cstring_to_text("");
		str = PointerGetDatum(t);	/* save detoasted text */
	}

	if (len < 0)
		return DatumGetTextP(DirectFunctionCall2(text_substr_no_len,
			str, Int32GetDatum(start)));
	else
		return DatumGetTextP(DirectFunctionCall3(text_substr,
			str, Int32GetDatum(start), Int32GetDatum(len)));
}

/* simply search algorhitm - can be better */

static int
ora_instr_mb(text *txt, text *pattern, int start, int nth)
{
	int			c_len_txt, c_len_pat;
	int			b_len_pat;
	int		   *pos_txt;
	const char *str_txt, *str_pat;
	int			beg, end, i, dx;

	str_txt = VARDATA_ANY(txt);
	c_len_txt = ora_mb_strlen(txt, NULL, &pos_txt);
	str_pat = VARDATA_ANY(pattern);
	b_len_pat = VARSIZE_ANY_EXHDR(pattern);
	c_len_pat = pg_mbstrlen_with_len(str_pat, b_len_pat);

	if (start > 0)
	{
		dx = 1;
		beg = start - 1;
		end = c_len_txt - c_len_pat + 1;
		if (beg >= end)
			return 0;	/* out of range */
	}
	else if (start < 0)
	{
		dx = -1;
		beg = Min(c_len_txt + start, c_len_txt - c_len_pat);
		end = -1;
		if (beg <= end)
			return 0;	/* out of range */
	}
	else
		return 0;

	for (i = beg; i != end; i += dx)
	{
		if (memcmp(str_txt + pos_txt[i], str_pat, b_len_pat) == 0)
		{
			if (--nth == 0)
				return i + 1;
		}
	}

	return 0;
}


int
ora_instr(text *txt, text *pattern, int start, int nth)
{
	int			len_txt, len_pat;
	const char *str_txt, *str_pat;
	int			beg, end, i, dx;

	if (nth <= 0)
		PARAMETER_ERROR("Four parameter isn't positive.");

	/* Forward for multibyte strings */
	if (pg_database_encoding_max_length() > 1)
		return ora_instr_mb(txt, pattern, start, nth);

	str_txt = VARDATA_ANY(txt);
	len_txt = VARSIZE_ANY_EXHDR(txt);
	str_pat = VARDATA_ANY(pattern);
	len_pat = VARSIZE_ANY_EXHDR(pattern);

	if (start > 0)
	{
		dx = 1;
		beg = start - 1;
		end = len_txt - len_pat + 1;
		if (beg >= end)
			return 0;	/* out of range */
	}
	else if (start < 0)
	{
		dx = -1;
		beg = Min(len_txt + start, len_txt - len_pat);
		end = -1;
		if (beg <= end)
			return 0;	/* out of range */
	}
	else
		return 0;

	for (i = beg; i != end; i += dx)
	{
		if (memcmp(str_txt + i, str_pat, len_pat) == 0)
		{
			if (--nth == 0)
				return i + 1;
		}
	}

	return 0;
}


/****************************************************************
 * PLVstr.instr
 *
 * Syntax:
 *   FUNCTION plvstr.instr (string_in VARCHAR, pattern VARCHAR)
 *   FUNCTION plvstr.instr (string_in VARCHAR, pattern VARCHAR,
 *            start_in INTEGER)
 *   FUNCTION plvstr.instr (string_in VARCHAR, pattern VARCHAR,
 *            start_in INTEGER, nth INTEGER)
 *            RETURN INT;
 *
 * Purpouse:
 *   Search pattern in string.
 *
 ****************************************************************/

Datum
plvstr_instr2 (PG_FUNCTION_ARGS)
{
	text *arg1 = PG_GETARG_TEXT_PP(0);
	text *arg2 = PG_GETARG_TEXT_PP(1);

	PG_RETURN_INT32(ora_instr(arg1, arg2, 1, 1));
}

Datum
plvstr_instr3 (PG_FUNCTION_ARGS)
{
	text *arg1 = PG_GETARG_TEXT_PP(0);
	text *arg2 = PG_GETARG_TEXT_PP(1);
	int arg3 = PG_GETARG_INT32(2);

	PG_RETURN_INT32(ora_instr(arg1, arg2, arg3, 1));
}

Datum
plvstr_instr4 (PG_FUNCTION_ARGS)
{
	text *arg1 = PG_GETARG_TEXT_PP(0);
	text *arg2 = PG_GETARG_TEXT_PP(1);
	int arg3 = PG_GETARG_INT32(2);
	int arg4 = PG_GETARG_INT32(3);

	PG_RETURN_INT32(ora_instr(arg1, arg2, arg3, arg4));
}


/****************************************************************
 * substr
 *
 * Syntax:
 *   FUNCTION substr (string, start_position, [length])
 *   	RETURN VARCHAR;
 *
 * Purpouse:
 *   Returns len chars from start_in position, compatible with Oracle
 *
 ****************************************************************/

Datum
oracle_substr3(PG_FUNCTION_ARGS)
{
	int32	len = PG_GETARG_INT32(2);

	if (len < 0)
		PG_RETURN_NULL();

	if (len == 0)
	{
		if (orafce_substring_length_is_zero == ORAFCE_COMPATIBILITY_WARNING_ORACLE ||
			 orafce_substring_length_is_zero == ORAFCE_COMPATIBILITY_WARNING_ORAFCE)
			elog(WARNING, "zero substring_length is used in substr function");

		if (orafce_substring_length_is_zero == ORAFCE_COMPATIBILITY_WARNING_ORACLE ||
			 orafce_substring_length_is_zero == ORAFCE_COMPATIBILITY_ORACLE)
			PG_RETURN_NULL();
	}

	PG_RETURN_TEXT_P(ora_substr(PG_GETARG_DATUM(0), PG_GETARG_INT32(1), len));
}

Datum
oracle_substr2(PG_FUNCTION_ARGS)
{
	PG_RETURN_TEXT_P(ora_substr(PG_GETARG_DATUM(0), PG_GETARG_INT32(1), -1));
}


static text*
ora_concat2(text *str1, text *str2)
{
	int l1;
	int l2;
	text *result;

	l1 = VARSIZE_ANY_EXHDR(str1);
	l2 = VARSIZE_ANY_EXHDR(str2);

	result = palloc(l1+l2+VARHDRSZ);
	memcpy(VARDATA(result), VARDATA_ANY(str1), l1);
	memcpy(VARDATA(result) + l1, VARDATA_ANY(str2), l2);
	SET_VARSIZE(result, l1 + l2 + VARHDRSZ);

	return result;
}


static text*
ora_concat3(text *str1, text *str2, text *str3)
{
	int l1;
	int l2;
	int l3;
	text *result;

	l1 = VARSIZE_ANY_EXHDR(str1);
	l2 = VARSIZE_ANY_EXHDR(str2);
	l3 = VARSIZE_ANY_EXHDR(str3);

	result = palloc(l1+l2+l3+VARHDRSZ);
	memcpy(VARDATA(result), VARDATA_ANY(str1), l1);
	memcpy(VARDATA(result) + l1, VARDATA_ANY(str2), l2);
	memcpy(VARDATA(result) + l1+l2, VARDATA_ANY(str3), l3);
	SET_VARSIZE(result, l1 + l2 + l3 + VARHDRSZ);

	return result;
}


/*
 * len < 0 means "length is not specified".
 */
static bytea *
ora_substrb(Datum str, int start, int len)
{
	if (start == 0)
		start = 1;	/* 0 is interpreted as 1 */
	else if (start < 0)
	{
		bytea	   *t = DatumGetByteaPP(str);
		int			n = VARSIZE_ANY_EXHDR(t);

		start = n + start + 1;
		if (start <= 0)
			return DatumGetByteaPP(DirectFunctionCall1(byteain, CStringGetDatum("")));

		str = PointerGetDatum(t);	/* save detoasted text */
	}

	if (len < 0)
		return DatumGetByteaP(DirectFunctionCall2(bytea_substr_no_len,
			str, Int32GetDatum(start)));
	else
		return DatumGetByteaP(DirectFunctionCall3(bytea_substr,
			str, Int32GetDatum(start), Int32GetDatum(len)));
}

Datum
oracle_substrb2(PG_FUNCTION_ARGS)
{
	PG_RETURN_BYTEA_P(ora_substrb(PG_GETARG_DATUM(0),
							   PG_GETARG_INT32(1),
							   -1));
}

Datum
oracle_substrb3(PG_FUNCTION_ARGS)
{
	PG_RETURN_BYTEA_P(ora_substrb(PG_GETARG_DATUM(0),
							   PG_GETARG_INT32(1),
							   PG_GETARG_INT32(2)));
}
