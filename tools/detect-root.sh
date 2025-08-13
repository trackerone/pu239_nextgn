    #!/usr/bin/env bash
    set -euo pipefail
    # Find the Laravel project root. Preference order:
    # 1) current dir if artisan + composer.json present
    # 2) any immediate subdir with artisan + composer.json
    # 3) any deeper subdir
    # Prints the path to stdout.

    if [[ -f "artisan" && -f "composer.json" ]]; then
      pwd
      exit 0
    fi

    # search up to depth 3 to be safe
    root=$(find . -maxdepth 3 -type f -name artisan -printf '%h
' | while read d; do
      if [[ -f "$d/composer.json" ]]; then
        echo "$d"
        break
      fi
    done)

    if [[ -z "${root:-}" ]]; then
      # fallback: prefer directory containing composer.json if only one exists
      c=$(find . -maxdepth 3 -type f -name composer.json -printf '%h
' | head -n1)
      if [[ -n "${c:-}" ]]; then
        echo "$c"
        exit 0
      fi
      # nothing found
      echo "."
      exit 0
    fi

    echo "$root"
