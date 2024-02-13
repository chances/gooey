#pragma once

#include <stddef.h>
#include <stdlib.h>

#include "span.h"

typedef struct Result {
  const Position position;
  const void* value;
  const char* error;
} Result;

#define Error(pos, err) (Result) { pos, 0, err }

void gooey_result_free(Result result) {
  if (result.value != NULL) free((void*) result.value);
  if (result.error != NULL) free((void*) result.error);
  result.value = result.error = NULL;
}
