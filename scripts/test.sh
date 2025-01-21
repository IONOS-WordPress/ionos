#!/usr/bin/env bash

#
# script is not intended to be executed directly. use 'pnpm exec ...' instead or call it as package script.
#
# this script is used to execute the tests
#
# run 'pnpm run test --help' for help
#

# bootstrap the environment
source "$(realpath $0 | xargs dirname)/includes/bootstrap.sh"

ADDITIONAL_ARGS=()

USE=()

while [[ $# -gt 0 ]]; do
  case $1 in
    --help)
      cat <<EOF
Usage: $0 [options] [-- additional-args]"

Executes tests.

This action will start wp-env if it is not already running.

Options:

  --help    Show this help message and exit

  --use     Specify which tests to execute (default: all)

            Available options:
              - php       execute PHPUnit tests
              - e2e       execute E2E tests
              - react     execute Storybook/React tests

            This option can be used multiple times to specify multiple tests.

  Example usage :
    Execute only PHPUnit and E2e tests: 'pnpm run test --use e2e --use php'

    Execute PHPUnit tests and provide additional args to PHPUnit :

      'pnpm test --use php -- --filter test_my_test_method'

      'pnpm test --use php -- --filter MyTestClass'

      'pnpm run test --use php -- --group foo'
EOF
      exit 0
      ;;
    --use)
      # convert value to lowercase and append value to USE array
      USE+=("${2,,}")
      shift 2
      ;;
    --)
      shift
      ADDITIONAL_ARGS=("$@")
      break
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
  esac
done

# invoke all tests by default
[[ ${#USE[@]} -eq 0 ]] && USE=("all")

if [[ "${USE[@]}" =~ all|react ]]; then
  # MARK: ensure the playwright cache is generated in the same environment (devcontainer or local) as the tests are executed
  # (this is necessary because the cache is not portable between environments)
  PLAYWRIGHT_DIR=$(realpath ./playwright)
  if [[ -f "$PLAYWRIGHT_DIR/.cache/metainfo.json" ]] && ! grep "$PLAYWRIGHT_DIR" ./playwright/.cache/metainfo.json > /dev/null; then
    # ./playwright/.cache/metainfo.json contains not the absolute path to the cache directory of the current environment
    rm -rf "$PLAYWRIGHT_DIR/.cache"
  fi
  # ENDMARK

  # execute playwright tests
  # when executed locally it expects chromium to be installed on the host machine : 'playwright install --with-deps chromium'
  pnpm exec playwright test -c ./playwright-ct.config.js "${ADDITIONAL_ARGS[@]}"
fi

if [[ "${USE[@]}" =~ all|php|e2e ]]; then
  # MARK: ensure wp-env started
  # ensure wp-env is running
  # - if the install path does not exist
  # - or if the containers are not running
  WPENV_INSTALLPATH="$(realpath --relative-to $(pwd) $(pnpm exec wp-env install-path))"
  if [[ ! -d "$WPENV_INSTALLPATH/WordPress" ]] || [[ "$(docker ps -q --filter "name=$(basename $WPENV_INSTALLPATH)" | wc -l)" != '6' ]]; then
    pnpm start
  fi
  # ENDMARK
fi

if [[ "${USE[@]}" =~ all|php ]]; then
  # start wp-env unit tests
  pnpm phpunit:test -- "${ADDITIONAL_ARGS[@]}"
fi

if [[ "${USE[@]}" =~ all|e2e ]]; then
  # start wp-env e2e tests
  (
    # used to prevent wp-scripts test-playwright command from downloading browsers
    export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
    # we need to inject the path to the installed chrome binary
    # via PLAYWRIGHT_CHROME_PATH
    export PLAYWRIGHT_CHROME_PATH=$(find ~/.cache/ms-playwright -name "chrome")
    pnpm exec wp-scripts test-playwright -c ./playwright.config.js "${ADDITIONAL_ARGS[@]}"
  )
fi
