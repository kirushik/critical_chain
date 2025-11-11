[![Circle CI](https://circleci.com/gh/kirushik/critical_chain.svg?style=svg)](https://circleci.com/gh/kirushik/critical_chain)

[![Code Climate](https://codeclimate.com/github/kirushik/critical_chain/badges/gpa.svg)](https://codeclimate.com/github/kirushik/critical_chain)
[![Test Coverage](https://codeclimate.com/github/kirushik/critical_chain/badges/coverage.svg)](https://codeclimate.com/github/kirushik/critical_chain/coverage)
[![security](https://hakiri.io/github/kirushik/critical_chain/master.svg)](https://hakiri.io/github/kirushik/critical_chain/master)


This is a free software, distributed under the GNU AGPL license. See `license.txt` for the full license text.


# Critical Chain Buffer Estimator

This project helps users to add sensible buffers to their project estimations (costs, lengths, resource usage...)
The assumptions and math behind it is based on principles of Critical Chain Project Management (CCPM).


Please see it in action [here](https://cc.pimenov.cc)


## Development instructions

It is a pretty typical Rails project.

Please fork it, clone it, run `bundle install` to fetch all the dependencies. Then copy `application.yml.sample` in application.yml, and populate it with proper Google API keys from [here](https://console.developers.google.com). You'll have to create a new OAuth credentials pair, bound to `localhost` host.

The project uses FOREMAN to properly set up processes and env variables. It comes with Google OAuth secrets valid for localhost:3000, in the `.env` file.
To properly launch Rails server in development mode, please run `env RAILS_ENV=development bundle exec foreman start`.

All tests are written in RSpec, so `bundle exec rspec` should do the trick with testing. `phantomjs` binary should be in `PATH` to run javascript-related feature tests. (See `spec/features` folder.)

Development is managed with [Waffle.io board](https://waffle.io/kirushik/critical_chain); feel free to report bugs, add new ideas and submit pull requests by default GitHub means.


## Deploy your own

This project can be deployed to any Rails-compatible hosting platform (Railway, Render, Fly.io, etc.).

### Required Environment Variables

**Please note** This project expects the following environment variables to be set:
- `google_oauth2_app_id` - Your Google OAuth2 application ID
- `google_oauth2_app_secret` - Your Google OAuth2 application secret

### Optional Environment Variables

- `RAILS_SERVE_STATIC_FILES` - Set to `false` if you're using a separate web server (like Nginx) to serve static files. By default, Rails will serve static files directly, which is appropriate for platforms like Railway and Heroku.

### Asset Compilation

The project includes `railway.toml` and `nixpacks.toml` configuration files that ensure assets are properly precompiled during deployment on Railway. If deploying to other platforms, ensure that `bundle exec rails assets:precompile` is run during the build phase.
