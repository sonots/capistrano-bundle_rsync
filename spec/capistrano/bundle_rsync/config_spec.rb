require 'spec_helper'

describe Capistrano::BundleRsync::Config do
  describe '.bundle_install_standalone_option' do
    before {
      allow(described_class).to receive(:fetch).with(:bundle_rsync_bundle_install_standalone).and_return(value)
    }
    subject { described_class.bundle_install_standalone_option }
    context "`set :bundle_rsync_bundle_install_standalone, nil` or the case that it does not be configured" do
      let(:value) { nil }
      it { should eq nil }
    end
    context "`set :bundle_rsync_bundle_install_standalone, true`" do
      let(:value) { true }
      it { should eq "--standalone" }
    end
    context "`set :bundle_rsync_bundle_install_standalone, false`" do
      let(:value) { false }
      it { should eq nil }
    end
    context "`set :bundle_rsync_bundle_install_standalone, ['foo', 'bar']" do
      let(:value) { %w(foo bar) }
      it { should eq "--standalone foo bar" }
    end
    context "`set :bundle_rsync_bundle_install_standalone, [:foo, :bar]" do
      let(:value) { [:foo, :bar] }
      it { should eq "--standalone foo bar" }
    end
    context "`set :bundle_rsync_bundle_install_standalone, 'foo bar'" do
      let(:value) { 'foo bar' }
      it { should eq "--standalone foo bar" }
    end
  end
end
