#include "moonbit.h"
#include <string.h>

MOONBIT_FFI_EXPORT
moonbit_string_t
moonbit_string(char* data)
{
  if (data == NULL) {
    return moonbit_make_string(0, 0);
  }
  size_t len = strlen(data);
  moonbit_string_t mb_string = moonbit_make_string(len, 0);
  for (int i = 0; i < len; i++) {
    mb_string[i] = (uint16_t)data[i];
  }
  return mb_string;
}