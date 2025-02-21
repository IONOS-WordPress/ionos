<?php
/**
 * This class represents the Next Best Action (NBA) model.
 */
namespace ionos_wordpress\essentials\dashboard\blocks\next_best_actions;

$model_path = __DIR__ . '/model.php';
if (! file_exists($model_path)) {
  return;
}
require_once $model_path;

function getNBAData() {
  return array(
    new Model(
      id: 'checkPluginsPage',
      title: 'Check Plugins Page',
      description: 'Check the plugins page for updates and security issues.',
      link: admin_url('plugins.php'),
      image: 'https://raw.githubusercontent.com/codeformm/mitaka-kichijoji-wapuu/main/mitaka-kichijoji-wapuu.png',
      completeOnClickCallback: fn() => false,
      callback: fn() => false,
    ),
    new Model(
      id: 'checkThemesPage',
      title: 'Check Themes Page',
      description: 'Check the themes page for updates and security issues.',
      link: admin_url('themes.php'),
      image: 'https://raw.githubusercontent.com/codeformm/mitaka-kichijoji-wapuu/main/mitaka-kichijoji-wapuu.png',
      completeOnClickCallback: fn() => false,
      callback: fn() => true,
    ),
    new Model(
      id: 'checkUpdatesPage',
      title: 'Check Updates Page',
      description: 'Check the updates page for updates and security issues.',
      link: admin_url('update-core.php'),
      image: 'https://raw.githubusercontent.com/codeformm/mitaka-kichijoji-wapuu/main/mitaka-kichijoji-wapuu.png',
      completeOnClickCallback: fn() => true,
      callback: fn() => true,
    ),
    new Model(
      id: 'checkSettingsPage',
      title: 'Check Settings Page',
      description: 'Check the settings page for updates and security issues.',
      link: admin_url('options-general.php'),
      image: 'https://raw.githubusercontent.com/codeformm/mitaka-kichijoji-wapuu/main/mitaka-kichijoji-wapuu.png',
      completeOnClickCallback: fn() => true,
      callback: fn() => true,
    ),
    new Model(
      id: 'checkUsersPage',
      title: 'Check Users Page',
      description: 'Check the users page for updates and security issues.',
      link: admin_url('users.php'),
      image: 'https://raw.githubusercontent.com/codeformm/mitaka-kichijoji-wapuu/main/mitaka-kichijoji-wapuu.png',
      completeOnClickCallback: fn() => true,
      callback: fn() => true,
    )
  );
}

