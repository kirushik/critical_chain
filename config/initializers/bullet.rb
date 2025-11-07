if defined?(Bullet)
  Bullet.enable = true
  Bullet.alert = true
  Bullet.bullet_logger = true
  Bullet.console = true
  Bullet.rails_logger = true
  Bullet.add_footer = true

  # Disable features that might be noisy during initial setup
  # You can enable these later as you fix issues
  Bullet.unused_eager_loading_enable = false
  Bullet.counter_cache_enable = false
end
