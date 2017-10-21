require 'spec_helper'

describe 'gitea Docker container' do
  set :os, family: :alpine
  set :backend, :docker
  set :docker_image, 'caddy'

  describe user('caddy') do
    it { should exist }
    it { should have_login_shell '/bin/bash' }
  end

  describe process('caddy') do
    it { should be_running }
    its(:user) { should eq 'caddy' }
    its(:args) { should match(/public/) }
  end

  describe 'the webserver' do
    it 'should be running on port 2015' do
      wait_for(port(2015)).to be_listening.with('tcp')
    end
  end
end
