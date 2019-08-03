/*
 * crc16.c
 *
 * Copyright (C) 1994 Klaus Kudielka
 *
 */

#include <stdlib.h>
#include "crc16.h"

void crc16_init(crc16_t       poly,
                crc16_table_t table)
{
  unsigned bit, flag, index;

  for (index = 0; index < 256; index++)
  {
    *table = 0;
    for (bit = 0; bit < 8; bit++)
    {
      flag = ((index << (bit+8)) ^ *table) & 0x8000;
      *table <<= 1;
      if (flag) *table ^= poly;
    }
    table++;
  }
}

unsigned short crc16(unsigned char *data,
                     size_t        bytes,
                     crc16_t       crc,
                     crc16_table_t table)
{
  while (bytes--) crc = (crc<<8) ^ table[(crc>>8)^(*data++)];
  return crc;
}

