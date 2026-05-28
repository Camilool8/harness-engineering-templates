#!/usr/bin/env bash
# leakage-sentinel.sh — PreToolUse hook on Write|Edit|MultiEdit.
# Pragmatic regex scan of edited Python for the four leakage / p-hacking
# patterns an agent will happily commit:
#   1. .fit() called before train_test_split  (test data seen during fit)
#   2. scaler/imputer .fit() on the full X outside a Pipeline / ColumnTransformer
#   3. ttest_ind in a loop with no multipletests / fdrcorrection correction
#   4. .shift(-N)  — look-ahead on a time series
#
# Regex, not a full AST: deliberately blunt. A false positive is cheap to
# override (rename the file or split the edit); silent leakage is not.
#
# Exit 2 = block (reason on stderr). Exit 0 = allow.
set -uo pipefail

event="$(cat)"
path="$(printf '%s' "$event" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null)"
[ -z "$path" ] && exit 0
case "$path" in *.py) ;; *) exit 0 ;; esac

content="$(printf '%s' "$event" | jq -r '
  .tool_input.content // .tool_input.new_string // empty' 2>/dev/null)"
[ -z "$content" ] && exit 0

block() {
  echo "BLOCKED (leakage-sentinel): $1" >&2
  echo "  $2" >&2
  echo "If this is a verified false positive, split the edit or document why." >&2
  exit 2
}

# 1. fit() appears textually before train_test_split() in the same edit.
fit_line="$(printf '%s' "$content" | grep -nE '\.fit\(' | head -1 | cut -d: -f1)"
split_line="$(printf '%s' "$content" | grep -nE 'train_test_split\(' | head -1 | cut -d: -f1)"
if [ -n "$fit_line" ] && [ -n "$split_line" ] && [ "$fit_line" -lt "$split_line" ]; then
  block "a .fit() call appears before train_test_split()." \
        "Split first, then fit on the training partition only."
fi

# 2. Scaler/imputer used, with a .fit( call, outside a Pipeline. Catches both
#    the inline form Scaler().fit(X) and the assigned form s = Scaler(); s.fit(X).
if printf '%s' "$content" | grep -Eq '(StandardScaler|MinMaxScaler|RobustScaler|SimpleImputer|KNNImputer)\(' \
   && printf '%s' "$content" | grep -Eq '\.fit(_transform)?\(' \
   && ! printf '%s' "$content" | grep -Eq '(Pipeline|make_pipeline|ColumnTransformer)'; then
  block "a scaler/imputer is fit on X outside a Pipeline/ColumnTransformer." \
        "Wrap preprocessing in a Pipeline so fit only ever sees training folds."
fi

# 3. t-test inside a loop with no multiple-comparison correction.
if printf '%s' "$content" | grep -Eq '(for |while ).*' \
   && printf '%s' "$content" | grep -Eq '(ttest_ind|ttest_rel|pingouin\.ttest)' \
   && ! printf '%s' "$content" | grep -Eq '(multipletests|fdrcorrection|bonferroni)'; then
  block "a t-test runs in a loop with no multiple-comparison correction." \
        "Apply statsmodels multipletests / fdrcorrection across the p-values."
fi

# 4. Negative shift — look-ahead on a time series.
if printf '%s' "$content" | grep -Eq '\.shift\([[:space:]]*-[0-9]'; then
  block "a .shift(-N) call leaks future data into a feature." \
        "Only shift forward (positive N); a negative shift is look-ahead bias."
fi

exit 0
