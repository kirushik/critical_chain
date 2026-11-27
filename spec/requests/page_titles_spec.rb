require 'rails_helper'

RSpec.describe 'Page titles', type: :request do
  include Warden::Test::Helpers

  let(:user) { create(:user) }
  let(:estimation) { create(:estimation, user: user, title: 'Kitchen remodel') }

  def title
    response.body[%r{<title>(.*?)</title>}m, 1]
  end

  after { Warden.test_reset! }

  it 'names the sign-in page' do
    get new_user_session_path
    expect(title).to eq('Please sign in - Buffer Estimator')
  end

  context 'when signed in' do
    before { login_as(user, scope: :user) }

    it 'names the estimations list' do
      get estimations_path
      expect(title).to eq('Your estimations - Buffer Estimator')
    end

    it 'names an estimation after its title' do
      get estimation_path(estimation)
      expect(title).to eq('Kitchen remodel - Buffer Estimator')
    end

    it 'names the sharing page after the estimation' do
      get estimation_estimation_shares_path(estimation)
      expect(title).to eq('Sharing options - Kitchen remodel - Buffer Estimator')
    end
  end

  it 'names a publicly shared estimation after its title' do
    estimation.generate_share_token!
    get public_estimation_path(estimation, estimation.share_token)
    expect(title).to eq('Kitchen remodel - Buffer Estimator')
  end

  it 'escapes the estimation title' do
    estimation.update!(title: '<b>Bold</b> & co')
    login_as(user, scope: :user)
    get estimation_path(estimation)
    expect(title).to eq('&lt;b&gt;Bold&lt;/b&gt; &amp; co - Buffer Estimator')
  end
end
