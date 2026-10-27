# Framework defaults held back from `config.load_defaults 8.1` in
# config/application.rb, until existing clients have caught up.
#
# The app ran on pre-5.0 defaults until load_defaults was set, so its session
# and Devise remember-me cookies are AES-256-CBC + HMAC, with keys derived
# through SHA1. Rails upgrades CBC cookies to AES-256-GCM on read, but derives
# the old key with the current key generator: switching it to SHA256 now would
# make every existing cookie unreadable and sign everybody out.
#
# Step 2, once the old cookies have expired or been re-issued (remember-me
# lasts Devise's `remember_for`, two weeks by default): delete this line, and
# rotate the SHA1-derived GCM and signed-cookie secrets as in
# https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#key-generator-digest-class-change-requires-a-cookie-rotator
Rails.application.config.active_support.key_generator_hash_digest_class = OpenSSL::Digest::SHA1
