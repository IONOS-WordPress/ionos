<?php

namespace ionos_wordpress\essentials\dashboard\blocks\deep_links;

$tenant = strtolower(\get_option('ionos_group_brand', false));

$config_file = __DIR__ . '/config/' . $tenant . '.php';

if ($tenant && file_exists($config_file)) {
  require_once $config_file;

  printf('<h3>%s</h3>', \esc_html__('Deep-Links', 'ionos-essentials'));
  printf('<p>%s</p>', \esc_html__('Use these links to get to your control panel.', 'ionos-essentials'));

  echo '<ul class="wp-block-list">';
  // PHPCS:ignore WordPress.WP.GlobalVariablesOverride.Prohibited
  foreach (links as $link) {
    printf(
      '<li><a href="%s" target="_blank">%s</a></li>',
      \esc_url($domain . $link['url']),
      \esc_html($link['anchor'])
    );
  }
  echo '</ul>';
}
