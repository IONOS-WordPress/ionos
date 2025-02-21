<?php
/**
 * This class represents the Next Best Action (NBA) model.
 */

namespace ionos_wordpress\essentials\dashboard\blocks\next_best_actions;

/**
 * Class NBA
 */
final class Model
{
  const WP_OPTION_NAME='NBA_OPTION';

  static protected array $_wp_option;

  function __construct(
    readonly string $id,
    readonly string $title,
    readonly string $description,
    readonly string $link,
    readonly mixed $completeOnClickCallback,
    readonly string $image,
    readonly mixed $callback,
    readonly bool $completed = false,
    readonly bool $dismissed = false
    )
  {}

  function __set(string $optionName, mixed $value): void {
    match ($optionName) {
      'completed' => static::_setOption($this->id, 'completed', $value),
      'dismissed' => static::_setOption($this->id, 'dismissed', $value),
      default => throw new \InvalidArgumentException("Invalid property: $optionName"),
    };
  }

  function __get(string $optionName): mixed {
    return match ($optionName) {
      'id' => $this->id,
      'title' => $this->title,
      'description' => $this->description,
      'link' => $this->link,
      'completeOnClickCallback' => $this->completeOnClickCallback,
      'image' => $this->image,
      'callback' => $this->callback,
      'completed' => static::_getOption($this->id, 'completed'),
      'dismissed' => static::_getOption($this->id, 'dismissed'),
      default => throw new \InvalidArgumentException("Invalid property: $optionName"),
    };
  }

  protected static function _getWPOption() {
    if(!isset(static::$_wp_option)) {
      $option = \get_option(static::WP_OPTION_NAME);
      static::$_wp_option = is_array( $option ) ? $option : [];
    }
    return static::$_wp_option;
  }


  protected static function _setOption(string $id, string $optionName, string $value) {
    $wp_option = static::_getWPOption();
    $wp_option[$id][$optionName] = $value;
    \update_option(static::WP_OPTION_NAME, $wp_option);
  }

  protected static function _getOption(string $id, string $optionName): mixed {
    $wp_option = static::_getWPOption();
    return $wp_option[$id][$optionName] ?? false;
  }
}

