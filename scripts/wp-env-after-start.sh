#!/usr/bin/env bash

#
# this script is used to customize the created wp-env instance
#

set -eo pipefail

WPENV_INSTALLPATH="$(realpath --relative-to $(pwd) $(pnpm exec wp-env install-path))"

# phpunit : install missing yoast/phpunit-polyfills
# this is neeed to run the tests in the WordPress environment
# @TODO: dont know why this is not automatically installed by wp-env, investigate into issue and fix it in wp-env
pnpm wp-env run tests-wordpress composer global require yoast/phpunit-polyfills:"^3.0" -W --dev

# execute only when NOT in CI environment
# https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/store-information-in-variables#default-environment-variables
if [[ "${CI:-}" != "true" ]]; then

  # MARK: supress xdebug warnings if vscode is not running in local developmt mode
  (
    prefix=$(basename "$(pnpm wp-env install-path)")
    # iterate over all wp-env containers and add "xdebug.log_level=0" to php.ini if not already present
    for suffix in 'cli-1' 'tests-cli-1' 'tests-wordpress-1' 'wordpress-1' ; do
      cat <<EOF | docker exec --interactive -u root "${prefix}-${suffix}" sh -
        grep -q 'xdebug.log_level=' /usr/local/etc/php/php.ini || \
          echo "xdebug.log_level=0" >> /usr/local/etc/php/php.ini
EOF
    done
  )
  # ENDMARK

  # MARK: copy PHPUNIT
  # copy phpunit files from wp-env container to phpunit-wordpress
  WORDPRESS_TEST_CONTAINER=$(docker ps -q --filter "name=tests-wordpress")
  docker cp $WORDPRESS_TEST_CONTAINER:/home/$USER/.composer/vendor/ ./phpunit/

  # @FIXME: doesnt work for me in github ci for some reason
  # # copy our phpunit config and bootstrap file to the wp-env wordpress test instance instead of mapping them in wp-env.json
  # # docker cp ./phpunit/phpunit.xml $WORDPRESS_TEST_CONTAINER:/var/www/html/
  # # docker cp ./phpunit/bootstrap.php $WORDPRESS_TEST_CONTAINER:/var/www/html/

  # ENDMARK

  # MARK: vscode configurations generation
  # generate .vscode/launch.json
  (
    # echoes comma spearated list of plugins
    function plugins {
      for PLUGIN in $(find packages/wp-plugin -mindepth 1 -maxdepth 1 -type d -printf '%f\n' 2>/dev/null || echo ''); do
        echo "        \"/var/www/html/wp-content/plugins/${PLUGIN}\":\"\${workspaceFolder}/packages/wp-plugin/${PLUGIN}\","
      done
    }

    # echoes comma spearated list of plugins
    function themes {
      for THEME in $(find packages/wp-theme -mindepth 1 -maxdepth 1 -type d -printf '%f\n' 2>/dev/null || echo ''); do
        echo "        \"/var/www/html/wp-content/themes/${THEME}\":\"\${workspaceFolder}/packages/wp-theme/${THEME}\","
      done
    }

    # generate launch configuration
    cat << EOF > '.vscode/launch.json'
{
  // THIS FILE IS MACHINE GENERATED by .wp-env-afterStart.sh - DO NOT EDIT!
  // If you need to confgure additional launch configurations consider defining them in a vscode *.code-workspace file
  "version": "0.2.0",
  "configurations": [
    {
      "name": "wp-env",
      "type": "php",
      "request": "launch",
      "port": 9003,
      "stopOnEntry": false, // set to true for debugging this launch configuration
      "log": false,         // set to true to get extensive xdebug logs
      "pathMappings": {
$(plugins)
$(themes)
        "/var/www/html": "\${workspaceFolder}/${WPENV_INSTALLPATH}/WordPress",
        // phpunit test path mappings
        "/wordpress-phpunit/includes": "\${workspaceFolder}/${WPENV_INSTALLPATH}/tests-WordPress-PHPUnit/tests/phpunit/includes",
        "/home/$USER/.composer/vendor": "\${workspaceFolder}/phpunit/vendor",

      }
    }
  ]
}
EOF
  )

    # generate settings.json
    cat << EOF > '.vscode/settings.json'
// THIS FILE IS MACHINE GENERATED by .wp-env-afterStart.sh - DO NOT EDIT!
// If you need to confgure additional launch configurations consider defining them in a vscode *.code-workspace file
{
  // show workspace folder in editor tab label
  "workbench.editor.labelFormat": "short",
  // see https://github.com/prettier/plugin-php?tab=readme-ov-file#visual-studio-code
  "prettier.documentSelectors": ["**/*.{js,jsx,ts,tsx,json,md,yaml,yml,php}"],
  "prettier.useEditorConfig": true,
  "prettier.configPath": ".prettierrc.js",
  "prettier.ignorePath": ".gitignore",
  "prettier.enableDebugLogs": true,
  "eslint.lintTask.enable": true,
  "eslint.useFlatConfig": true,
  "eslint.format.enable" : true,
  "eslint.ignoreUntitled": true,
  "eslint.run": "onSave",
    "eslint.codeAction.showDocumentation": {
    "enable": true
  },
  "cSpell.useGitignore": true,
  "editorconfig.generateAuto": false,
  "editor.codeActionsOnSave": {
    "source.fixAll": "never",
    "source.fixAll.eslint": "explicit",
    "source.organizeImports": "never"
  },
  "stylelint.validate": ["css", "scss"],
  "stylelint.packageManager": "pnpm",
  "stylelint.config": {
    "configBasedir": "\${workspaceFolder}"
  },
  "stylelint.configFile": ".stylelintrc.yml",
  "[php]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[css]": {
    "editor.defaultFormatter": "stylelint.vscode-stylelint"
  },
  "[scss]": {
    "editor.defaultFormatter": "stylelint.vscode-stylelint"
  },
  "eslint.validate": ["javascript", "javascriptreact", "json", "jsonc", "json5"],
  // enable globally (here: format on save)
  "editor.formatOnSave": true,
  "intelephense.files.exclude": [
    "**/.git/**",
    "**/.svn/**",
    "**/.hg/**",
    "**/CVS/**",
    "**/.DS_Store/**",
    "**/node_modules/**",
    "**/bower_components/**",
    "**/vendor/**/{Tests,tests}/**",
    "**/.history/**",
    "**/vendor/**/vendor/**",
    "**/dist/**",
    "**/buid/**",
  ],
  "search.exclude": {
    "**/node_modules": true,
    "**/build/**" : true,
    "**/build-module/**" : true
  },
  "intelephense.environment.phpVersion": "8.3",
  "intelephense.environment.includePaths": [
    "${WPENV_INSTALLPATH}/WordPress",
    "./phpunit/vendor/phpunit/phpunit/src"
  ],
  "git.autoRepositoryDetection": false,
  "json.schemas": [
    {
      "fileMatch": ["jsonschema.json", "*schema.json"],
      "url": "https://json-schema.org/draft/2019-09/schema"
    },
    {
      "fileMatch": ["tsconfig.json"],
      "url": "https://json.schemastore.org/tsconfig"
    }
  ],
  "[html]": {
    "editor.formatOnSave": false
  },
  "playwright.runGlobalSetupOnEachRun": true,
}
EOF
  # ENDMARK

fi

# remove dolly demo plugin
rm -f $WPENV_INSTALLPATH/{tests-WordPress,WordPress}/wp-content/plugins/hello.php

for prefix in '' 'tests-' ; do
  # this wp-cli configuration file needs to be created to enable wp-cli to work with the apache mod_rewrite module
  pnpm exec wp-env run ${prefix}cli sh -c 'echo -e "apache_modules:\n  - mod_rewrite" > /var/www/html/wp-cli.yml'

  # The wp rewrite structure command updates the permalink structure. --hard also updates the .htaccess file
  pnpm exec wp-env run ${prefix}cli wp --quiet rewrite structure '/%postname%' --hard

  # The wp rewrite flush command regenerates the rewrite rules for your WordPress site, which includes refreshing the permalinks.
  pnpm exec wp-env run ${prefix}cli wp --quiet rewrite flush

  # Updates an option value for example the value of Simple page is id = 2
  pnpm exec wp-env run ${prefix}cli wp option update page_on_front 2
  # Update the page as front page by default.
  pnpm exec wp-env run ${prefix}cli wp option update show_on_front page

  # activate twentytwenty-five theme in all wp-env instances (test and development)
  pnpm exec wp-env run ${prefix}cli wp theme activate twentytwentyfive

  # activate all installed plugins in all wp-env instances (test and development)
  pnpm exec wp-env run ${prefix}cli wp plugin activate --all

  # emulate ionos brand by default
  pnpm exec wp-env run ${prefix}cli wp option update ionos_group_brand_name ionos
done
