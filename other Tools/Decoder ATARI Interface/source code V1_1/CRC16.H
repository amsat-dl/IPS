/*
 * crc16.h
 *
 * Copyright (C) 1994 Klaus Kudielka
 *
 */

typedef unsigned short crc16_t;
typedef crc16_t        crc16_table_t[256];

#define CCITT_CRC16 0x1021

void    crc16_init(crc16_t, crc16_table_t);
crc16_t crc16(unsigned char *, size_t, crc16_t, crc16_table_t);