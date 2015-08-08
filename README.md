[![Circle CI](https://circleci.com/gh/kirushik/critical_chain.svg?style=svg)](https://circleci.com/gh/kirushik/critical_chain)

[![Code Climate](https://codeclimate.com/github/kirushik/critical_chain/badges/gpa.svg)](https://codeclimate.com/github/kirushik/critical_chain)
[![Test Coverage](https://codeclimate.com/github/kirushik/critical_chain/badges/coverage.svg)](https://codeclimate.com/github/kirushik/critical_chain/coverage)
[![Dependency Status](https://gemnasium.com/kirushik/critical_chain.svg)](https://gemnasium.com/kirushik/critical_chain)
[![security](https://hakiri.io/github/kirushik/critical_chain/master.svg)](https://hakiri.io/github/kirushik/critical_chain/master)


This is a free software, distributed under the GNU AGPL license. See `license.txt` for the full license text.


# Critical Chain Buffer Estimator

This project helps users to add sensible buffers to their project estimations (costs, lengths, resource usage...)
The assumptions and math behind it is based on principles of Critical Chain Project Management (CCPM).


Please see it in action [here](https://cc.pimenov.cc)


## Development instructions

It is a pretty typical Rails project.

Please fork it, clone it, run `bundle install` to fetch all the dependencies.

All tests are written in RSpec, so `bundle exec rspec` should do the trick with testing. `phantomjs` binary should be in `PATH` to run javascript-related feature tests. (See `spec/features` folder.)

Development is managed with [Waffle.io board](https://waffle.io/kirushik/critical_chain); feel free to report bugs, add new ideas and submit pull requests by default GitHub means.
