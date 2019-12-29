# frozen_string_literal: true

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
    it { is_expected.to exist }
    it { is_expected.to have_login_shell '/bin/bash' }
  end

  describe process('caddy') do
    it { is_expected.to be_running }
    its(:user) { is_expected.to eq 'caddy' }
    its(:args) { is_expected.to match(/public/) }
  end

  describe command('caddy -plugins') do
    its(:stdout) { is_expected.to match(/tls\.dns\.route53/) }
    its(:stdout) { is_expected.to match(/http\.webdav/) }
  end

  describe 'the webserver' do
    it 'is available at port 80' do
      wait_for(port(80)).to be_listening.with('tcp')
    end
  end
end
