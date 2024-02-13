/// Authors: Chance Snow
/// Copyright: Copyright © 2024 Chance Snow. All rights reserved.
/// License: MIT License
#include <lexbor/html/parser.h>
#include <lexbor/dom/dom.h>

#include "span.h"

lxb_html_document_t* gooey_html_parse(const char* source, size_t length) {
  lxb_status_t status;
  lxb_html_document_t* document;

  document = lxb_html_document_create();
  if (document == NULL) return NULL;

  status = lxb_html_document_parse(document, source, length);
  if (status != LXB_STATUS_OK) return NULL;

  return document;
}
