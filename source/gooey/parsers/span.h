#pragma once

#include <stdint.h>

typedef struct Position {
  uint32_t line;
  uint32_t column;
} Position;

#define zeroPosition (Position) {0, 0}
