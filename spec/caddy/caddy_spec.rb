# frozen_string_literal: true

require 'spec_helper'

describe 'caddy Docker container', :extend_helpers do
  set :os, family: :alpine
  set :backend, :docker
  set :docker_image, ENV['CONTAINER']

  describe user('caddy') do
    it { is_expected.to exist }
    it { is_expected.to have_login_shell '/bin/bash' }
  end

  describe process('caddy') do
    it { is_expected.to be_running }
    its(:user) { is_expected.to eq 'caddy' }
    its(:args) { is_expected.to match(/run/) }
  end

  describe command('caddy list-modules') do
    its(:stdout) { is_expected.to match(/dns\.providers\.route53/) }
  end

  describe 'the webserver' do
    it 'is available at port 2019' do
      wait_for(port(2019)).to be_listening.with('tcp')
    end
  end
end
