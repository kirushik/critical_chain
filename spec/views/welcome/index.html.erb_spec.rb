require 'rails_helper'

RSpec.describe "welcome/index.html.erb", :type => :view do
  it 'should contain "Login with Google" button' do
    render
    expect(rendered).to match 'value="Login with Google"'
  end
end
