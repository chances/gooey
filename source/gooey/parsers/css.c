/// Authors: Chance Snow
/// Copyright: Copyright © 2024 Chance Snow. All rights reserved.
/// License: MIT License
#include <lexbor/css/parser.h>
#include <string.h>

#include "result.h"
#include "span.h"

lxb_status_t gooey_css_parse_callback(const lxb_char_t* data, size_t len, void* ctx) {
  char* result = (char*) *((void**) ctx);
  result = malloc(len);
  strncpy(result, (char*) data, len);

  return LXB_STATUS_OK;
}

Result gooey_css_parse_stylesheet(const char* source, size_t length) {
  if ((void*) source == NULL || length == 0) return Error(zeroPosition, "An input is required!");

  lxb_status_t status;
  lxb_css_parser_t* parser;

  parser = lxb_css_parser_create();
  status = lxb_css_parser_init(parser, NULL);
  if (status != LXB_STATUS_OK) return Error(zeroPosition, "Could not create parser.");

  lxb_css_stylesheet_t* stylesheet = lxb_css_stylesheet_parse(parser, source, length);
  (void) lxb_css_parser_destroy(parser, true);
  if (stylesheet == NULL) return Error(zeroPosition, "Could not parse stylesheet.");

  char* result;
  status = lxb_css_rule_serialize(stylesheet->root, gooey_css_parse_callback, &result);
  if (status != LXB_STATUS_OK) {
    if (result != NULL) free(result);
    return Error(zeroPosition, "Failed to serialize stylesheet.");
  }
  (void) lxb_css_stylesheet_destroy(stylesheet, true);

  return (Result) { zeroPosition, result, NULL };
}

Result gooey_css_parse_selector(const char* input, size_t length) {
  if ((void*) input == NULL || length == 0) return Error(zeroPosition, "An input is required!");

  lxb_status_t status;
  lxb_css_parser_t* parser;

  parser = lxb_css_parser_create();
  status = lxb_css_parser_init(parser, NULL);
  if (status != LXB_STATUS_OK) return Error(zeroPosition, "Could not create parser.");

  lxb_css_selector_list_t* list = lxb_css_selectors_parse(parser, input, length);
  if (parser->status != LXB_STATUS_OK) {
    (void) lxb_css_parser_destroy(parser, true);
    return Error(zeroPosition, "Could not parse selector(s).");
  }

  char* result;
  status = lxb_css_selector_serialize_list(list, gooey_css_parse_callback, &result);
  if (status != LXB_STATUS_OK) {
    if (result != NULL) free(result);
    lxb_css_memory_destroy(list->memory, true);
    (void) lxb_css_parser_destroy(parser, true);
    return Error(zeroPosition, "Failed to serialize selector(s).");
  }

  lxb_css_memory_destroy(list->memory, true);
  (void) lxb_css_parser_destroy(parser, true);

  return (Result) { zeroPosition, result, NULL };
}
