# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'create mapfiles' do
  describe 'one mapfile' do
    let(:pp) do
      <<-MANIFEST
      include ::haproxy
      haproxy::mapfile { 'single-mapfile':
        ensure   => 'present',
        mappings => [
          { 'example.com' => 'bk_com' },
          { 'example.net' => 'bk_net' },
          { 'example.edu' => 'bk_edu' },
        ],
      }
      MANIFEST
    end

    it 'applies the manifest twice with no stderr' do
      idempotent_apply(pp)
      expect(file('/etc/haproxy/single-mapfile.map')).to be_file
      expect(file('/etc/haproxy/single-mapfile.map').content).to match "example.com bk_com\nexample.net bk_net\nexample.edu bk_edu\n"
    end
  end

  describe 'multiple mapfiles' do
    let(:pp) do
      <<-MANIFEST
      include ::haproxy
      haproxy::mapfile { 'multiple-mapfiles':
        ensure => 'present',
      }
      haproxy::mapfile::entry { 'example.com bk_com':
        mapfile => 'multiple-mapfiles',
      }
      haproxy::mapfile::entry { 'org':
        mappings => ['example.org bk_org'],
        mapfile  => 'multiple-mapfiles',
        order    => '05',
      }
      haproxy::mapfile::entry { 'net':
        mappings => ['example.net bk_net'],
        mapfile  => 'multiple-mapfiles',
      }
      haproxy::mapfile::entry { 'edu':
        mappings => [{'example.edu' => 'bk_edu'}],
        mapfile  => 'multiple-mapfiles',
      }
      MANIFEST
    end

    it 'applies the manifest twice with no stderr' do
      idempotent_apply(pp)
      expect(file('/etc/haproxy/multiple-mapfiles.map')).to be_file
      expect(file('/etc/haproxy/multiple-mapfiles.map').content).to match "example.org bk_org\nexample.edu bk_edu\nexample.com bk_com\nexample.net bk_net\n"
    end
  end
end
