require 'spec_helper'

module Helpers
  def compose
    @compose ||= Docker::Compose.new
  end
end

RSpec.configure do |c|
  c.include Helpers
  c.extend Helpers
end

describe 'caddy Docker container', :extend_helpers do
  set :os, family: :alpine
  set :backend, :docker
  set :docker_container, 'caddy'

  before(:all) do
    compose.up('caddy', detached: true)
  end

  after(:all) do
    compose.kill
    compose.rm(force: true, volumes: true)
  end

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
    it 'should be running on port 80' do
      wait_for(port(80)).to be_listening.with('tcp')
    end
  end
end
