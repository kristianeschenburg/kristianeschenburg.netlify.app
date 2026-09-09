#!/usr/bin/env bash
# Local preview at http://localhost:1313 with live reload.
#   -D  include drafts       (draft: true)
#   -F  include future-dated (date in the future)
hugo --i18n-warnings server -D -F --navigateToChanged
