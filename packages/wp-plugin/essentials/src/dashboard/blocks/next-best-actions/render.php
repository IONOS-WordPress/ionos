<?php

// phpcs:disable WordPress.WP.GlobalVariablesOverride.Prohibited

namespace ionos_wordpress\essentials\dashboard\blocks\next_best_actions;

use ionos_wordpress\essentials\dashboard\blocks\next_best_actions\model\NBA;

$nba_data = __DIR__ . '/data.php';

if (! file_exists($nba_data)) {
  return;
}
require_once $nba_data;

$actions = getNBAData();
if (! is_array($actions)) {
  return;
}

printf('<h3>%s</h3>', \esc_html__('Next best actions ⚡', 'ionos-essentials'));
echo '<ul class="wp-block-list ionos-dashboard-nba ">';
foreach ($actions as $action) {
  //$action->__set('dismissed', 0);
  if ($action->__get('dismissed') === "1" || $action->__get('completed') === "1") {
    continue;
  }
  printf('<div class="wp-block-button is-style-outline is-style-outline--2">
    <a href="#" class="wp-block-button__link wp-element-button" callback-id="click-nba-dismiss" data-id="%s">%s</a>
  </div>',
  \esc_attr($action->__get('id')),
  'Dismiss'
  );
  printf(
    '<a href="%s" class="ionos-dashboard nba-action-link %s" callback-id="click-nba-action" data-id="%s" />%s',
    \esc_attr($action->__get('link')),
    $action->__get('completed') ? 'completed' : '',
    \esc_attr($action->__get('id')),
    \esc_html($action->__get('title'))
  );
}
echo '</li></ul>';

add_action('wp_ajax_execute-nba-callback', function() {
  \wp_send_json_error( new \WP_Error( 'geht_nicht', 'Test' ) );
});
