<?php

namespace ionos_wordpress\essentials\dashboard\blocks\next_best_actions;
use const ionos_wordpress\essentials\PLUGIN_DIR;

\add_action('init', function () {
  \register_block_type(
    PLUGIN_DIR . '/build/dashboard/blocks/next-best-actions',
    // [
    //   'render_callback' => function ($attributes) {
    //     require_once __DIR__ . '/render.php';
    //   },
    // ]
  );
});

\add_action('admin_init', function () {
  if (isset($_GET['complete_nba'])) {
    require_once __DIR__ . '/model.php';
    $nba_id = $_GET['complete_nba'];

    $nba = \ionos_wordpress\essentials\dashboard\blocks\next_best_actions\model\NBA::getNBA($nba_id);
    $nba->setStatus( "completed", true);
  }
});

\add_action('rest_api_init', function () {
  \register_rest_route('ionos/v1', '/dismiss_nba/(?P<id>[a-zA-Z0-9-]+)', [
    'methods' => 'GET',
    'callback' => function ($request) {
      require_once __DIR__ . '/model.php';
			$params = $request->get_params();
			$nba_id = $params['id'];

      $nba = \ionos_wordpress\essentials\dashboard\blocks\next_best_actions\model\NBA::getNBA($nba_id);
      $res = $nba->setStatus( "dismissed", true);
      if ($res) {
        return new \WP_REST_Response(['status' => 'success', 'res' => $res], 200);
      }
      return new \WP_REST_Response(['status' => 'error'], 500);
    },
    'permission_callback' => function () {
      return true || \current_user_can('manage_options');
    },
  ]);
});


