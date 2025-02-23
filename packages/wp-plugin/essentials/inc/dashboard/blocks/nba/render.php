<?php

namespace ionos_wordpress\essentials\dashboard\blocks\next_best_actions;

use ionos_wordpress\essentials\dashboard\blocks\next_best_actions\model\NBA;

require_once __DIR__ . '/model.php';
$actions = NBA::getActions();
if (empty($actions)) {
  return;
}

$template = '<div id="ionos-dashboard__essentials_nba" class="wp-block-group alignwide">'
. '<div class="wp-block-group is-vertical is-content-justification-left is-layout-flex wp-container-core-group-is-layout-2 wp-block-group-is-layout-flex">'
. sprintf('<h2 class="wp-block-heading">%s</h2>', \esc_html__('Next best actions ⚡', 'ionos-essentials'))
. sprintf('<p>%s</p>', \esc_html__('Description of this block', 'ionos-essentials'))
. '</div>'
. '<div class="wp-block-columns is-layout-flex wp-container-core-columns-is-layout-1 wp-block-columns-is-layout-flex">'
. '%s'
. '</div></div>';

$body = '';
foreach ($actions as $action) {
  $active = $action->active;
  if (! $active) {
    continue;
  }
  $body .= '<div class="wp-block-column is-style-default has-border-color is-layout-flow wp-block-column-is-layout-flow">'
  . sprintf('<h2 class="wp-block-heading">%s</h2>', \esc_html($action->title, 'ionos-essentials'))
  . sprintf('<p>%s</p>', \esc_html($action->description, 'ionos-essentials'))
  . '<div class="wp-block-buttons is-layout-flex wp-block-buttons-is-layout-flex">'
  . sprintf(
    '<div class="wp-block-button"><a href="%s" class="wp-block-button__link wp-element-button" target="_top">%s</a></div>',
    \esc_url($action->link),
    \esc_html("Primary button", 'ionos-essentials'),
  )
  . '<div class="wp-block-button is-style-outline is-style-outline--1">'
  . sprintf(
    '<div class="wp-block-button"><a id="%s" class="wp-block-button__link wp-element-button dismiss-nba" target="_top">%s</a></div>',
    $action->id,
    \esc_html("Dismiss", 'ionos-essentials')
  )
  . '</div></div></div>';
}

if (empty($body)) {
  return;
}

\printf($template, $body);
