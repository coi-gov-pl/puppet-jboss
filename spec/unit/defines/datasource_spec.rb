require 'spec_helper'

describe 'jboss::datasource', :type => :define do
  def merge_params(hash = {})
    hash.merge({
      :username   => 'test-username',
      :password   => 'test-password',
      :jdbcscheme => 'test-scheme',
      :host       => 'example.com',
      :port       => '1234',
      :driver     => {
        'name'       => 'test-driver',
        'classname'  => 'com.example.TestDriver',
        'modulename' => 'test-driver',
      },
    })
  end

  let(:title) { 'test-datasource' }
  let(:params) { merge_params }
  let(:facts) { {
    :osfamily            => "RedHat",
    :operatingsystem     => "RedHat",
    :'jboss::profile'    => "domain",
    :'jboss::controller' => "controller.example.com",
    :concat_basedir      => "/tmp/"
  } }

  it { is_expected.to compile.with_all_deps }
  it { is_expected.to contain_jboss_datasource('test-datasource') }
  it { is_expected.to contain_jboss__datasource('test-datasource') }

  it do
    is_expected.to contain_jboss_datasource('test-datasource').
      with_port(1234)
  end
  
  it do
    is_expected.to contain_jboss_datasource('test-datasource').
      with_xa(true)
  end

  context 'with option prepared-statements-cache-size set to 46' do
    let(:options) do {
        'prepared-statements-cache-size' => 46
      }
    end
    context 'in XA mode' do
      let(:params) do
        merge_params({ :options => options })
      end
  
      it { is_expected.to contain_jboss_datasource('test-datasource').with_xa(true) }
      it do is_expected.to contain_jboss_datasource('test-datasource').with_options({
        "validate-on-match"=>false,
        "background-validation"=>false,
        "share-prepared-statements"=>false,
        "prepared-statements-cache-size"=>46,
        "same-rm-override"=>true,
        "wrap-xa-resource"=>true
        })
      end
    end
    context 'in non-XA mode' do
      let(:params) do
        merge_params({ :options => options, :xa => false })
      end
  
      it { is_expected.to contain_jboss_datasource('test-datasource').with_xa(false) }
      it do is_expected.to contain_jboss_datasource('test-datasource').with_options({
        "validate-on-match"=>false,
        "background-validation"=>false,
        "share-prepared-statements"=>false,
        "prepared-statements-cache-size"=>46
        })
      end
    end
  end
end

