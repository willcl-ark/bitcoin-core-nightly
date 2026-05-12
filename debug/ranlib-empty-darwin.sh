#!/usr/bin/env bash
set -euo pipefail

if [[ -n "${TARGETS:-}" ]]; then
  read -r -a targets <<< "${TARGETS}"
else
  targets=(
    x86_64-apple-darwin
    arm64-apple-darwin
  )
fi

workdir="${TMPDIR:-/tmp}/ranlib-empty-darwin"
rm -rf "${workdir}"
mkdir -p "${workdir}"

cat > "${workdir}/empty.cpp" <<'EOF'
// Intentionally empty translation unit.
EOF

cat > "${workdir}/static.cpp" <<'EOF'
static void local_only() {}
EOF

for target in "${targets[@]}"; do
  prefix="${target}-"
  cc="${prefix}clang++"
  ar="${prefix}ar"
  ranlib="${prefix}ranlib"
  nm="${prefix}nm"

  if ! command -v "${cc}" >/dev/null 2>&1; then
    cc="clang++"
  fi
  if ! command -v "${ar}" >/dev/null 2>&1; then
    ar="ar"
  fi
  if ! command -v "${ranlib}" >/dev/null 2>&1; then
    ranlib="ranlib"
  fi
  if ! command -v "${nm}" >/dev/null 2>&1; then
    nm="nm"
  fi

  echo "== ${target} =="
  command -v "${cc}"
  command -v "${ar}"
  command -v "${ranlib}"
  command -v "${nm}"

  target_dir="${workdir}/${target}"
  mkdir -p "${target_dir}"

  "${cc}" -c "${workdir}/empty.cpp" -o "${target_dir}/empty.o"
  "${cc}" -c "${workdir}/static.cpp" -o "${target_dir}/static.o"

  for object in empty static; do
    archive="${target_dir}/lib${object}.a"
    "${ar}" qc "${archive}" "${target_dir}/${object}.o"

    echo "-- ${object}.o symbols --"
    "${nm}" -a "${target_dir}/${object}.o" || true

    echo "-- ranlib lib${object}.a --"
    if output="$("${ranlib}" "${archive}" 2>&1)"; then
      status=0
    else
      status=$?
    fi
    printf 'exit=%s\n' "${status}"
    if [[ -n "${output}" ]]; then
      printf '%s\n' "${output}"
    else
      echo "<no output>"
    fi
  done
done
