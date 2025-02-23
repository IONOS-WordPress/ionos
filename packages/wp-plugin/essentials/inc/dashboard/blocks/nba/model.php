<?php

/**
 * This class represents the Next Best Action (NBA) model.
 */

namespace ionos_wordpress\essentials\dashboard\blocks\next_best_actions\model;

class NBA
{
  private static $option_name = 'ionos_nba_status';

  private static $option_value;
  private static array $actions = [];

  private function __construct(
    readonly string $id,
    readonly string $title,
    readonly string $description,
    readonly string $link,
    readonly bool $completed
  ) {
    $a = "b";
    self::$actions[$this->id] = $this;
  }

  public function __get($property)
  {
    if ('active' === $property) {
      $status = $this->_get_status();
      if (isset($status["completed"]) && $status["completed"] || isset($status["dismissed"]) && $status["dismissed"]) {
        return false;
      }
      // $status = (object) $this->_get_status();
      // if ($status?->completed ?? false || $status?->dismissed ?? false) {
      //   return false;
      // }
      return ! $this->completed;
    }
  }

  private static function _get_option()
  {
    if (! isset(self::$option_value)) {
      self::$option_value = \get_option(self::$option_name, []);
    }
    return self::$option_value;
  }

  private static function _set_option(array $option)
  {
    return \update_option(self::$option_name, $option);
  }

  private function _get_status()
  {
    $option = $this->_get_option();
    return $option[$this->id] ?? [];
  }

  function setStatus($key, $value) {
    $id = $this->id;
    $option = self::_get_option();

    $option[$id] ??= [];
    $option[$id][$key] = $value;
    return self::_set_option($option);
  }

  public static function getNBA($id)
  {
    return self::$actions[$id];
  }

  public static function getActions()
  {
    return self::$actions;
  }

  public static function register($id, $title, $description, $link, $completed = false)
  {
    new NBA($id, $title, $description, $link, $completed);
  }

}

NBA::register(
  id: 'checkPluginsPage',
  title: 'Check plugins page',
  description: 'Ensure all your plugins are up-to-date and functioning correctly.',
  link: admin_url('plugins.php?complete_nba=checkPluginsPage'),
  // completed: (function(){
  //   return false;
  // })()
);

NBA::register(
  id: 'checkThemesPage',
  title: 'Check themes page',
  description: 'Review and manage your installed themes for a fresh look.',
  link: admin_url('themes.php?complete_nba=checkThemesPage'),
  // completed: (function(){
  //   return false;
  // })()
);

NBA::register(
  id: 'checkSettingsPage',
  title: 'Check settings page',
  description: 'Verify your site settings to ensure everything is configured properly.',
  link: admin_url('options-general.php?complete_nba=checkSettingsPage'),
  // completed: (function(){
  //   return false;
  // })()
);

NBA::register(
  id: 'checkUpdatesPage',
  title: 'Check updates page',
  description: 'Stay secure by keeping your WordPress installation up-to-date.',
  link: admin_url('update-core.php?complete_nba=checkUpdatesPage'),
  // completed: (function(){
  //   return false;
  // })()
);

NBA::register(
  id: 'checkCommentsPage',
  title: 'Check comments page',
  description: 'Moderate and manage comments to keep your community engaged.',
  link: admin_url('edit-comments.php?complete_nba=checkCommentsPage'),
  // completed: (function(){
  //   return false;
  // })()
);

NBA::register(
  id: 'checkPostsPage',
  title: 'Check posts page',
  description: 'Review your posts to ensure they are up-to-date and relevant.',
  link: admin_url('edit.php?post_type=post&complete_nba=checkPostsPage'),
  // completed: (function(){
  //   return false;
  // })()
);

NBA::register(
  id: 'checkUsersPage',
  title: 'Check users page',
  description: 'Manage user roles and permissions to maintain site security.',
  link: admin_url('users.php?complete_nba=checkUsersPage'),
  // completed: (function(){
  //   return false;
  // })()
);
