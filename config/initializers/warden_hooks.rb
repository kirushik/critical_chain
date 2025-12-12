# Warden hook to immediately terminate sessions for banned users.
# This runs on every request after the user is loaded from session,
# ensuring banned users are logged out even if they have active sessions.
Warden::Manager.after_set_user do |user, auth, opts|
  if user.banned?
    auth.logout
    throw :warden, message: :banned
  end
end
