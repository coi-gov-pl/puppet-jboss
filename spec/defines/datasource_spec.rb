require 'spec_helper_puppet'

describe 'jboss::datasource', :type => :define do
  def default_driver_params
    {
      'name'       => 'test-driver',
      'classname'  => 'com.example.TestDriver',
      'modulename' => 'test-driver'
    }
  end

  def default_params
    {
      :username   => 'test-username',
      :password   => 'test-password',
      :jdbcscheme => 'test-scheme',
      :host       => 'example.com',
      :port       => '1234',
      :driver     => default_driver_params
    }
  end

  def merge_params(hash = {})
    hash.merge(default_params)
  end

  context 'on RedHat os family' do
    extend Testing::RspecPuppet::SharedExamples

    let(:title) { 'test-datasource' }
    let(:params) { merge_params }
    let(:facts) { Testing::RspecPuppet::SharedFacts.oraclelinux_facts }

    it { is_expected.to compile.with_all_deps }
    it_behaves_like containing_basic_class_structure

    it do
      is_expected.to contain_jboss_jdbcdriver('test-driver').
        with_classname('com.example.TestDriver').with_modulename('test-driver')
    end
    it { is_expected.to contain_jboss_datasource('test-datasource') }
    it { is_expected.to contain_jboss__datasource('test-datasource') }

    it do
      is_expected.to contain_jboss_datasource('test-datasource').
        with_port(1234)
    end

    it do
      is_expected.to contain_jboss_datasource('test-datasource').
        with_xa(false)
    end

    context 'with option prepared-statements-cache-size set to 46' do
      let(:options) do
        {
          'prepared-statements-cache-size' => 46
        }
      end
      context 'in XA mode' do
        let(:params) do
          merge_params(:options => options, :xa => true)
        end

        it { is_expected.to contain_jboss_datasource('test-datasource').with_xa(true) }
        it do
          is_expected.to contain_jboss_datasource('test-datasource').with_options(
            'validate-on-match'              => false,
            'background-validation'          => false,
            'share-prepared-statements'      => false,
            'prepared-statements-cache-size' => 46,
            'same-rm-override'               => true,
            'wrap-xa-resource'               => true
          )
        end
      end
      context 'in non-XA mode' do
        let(:params) do
          merge_params(:options => options, :xa => false)
        end

        it { is_expected.to contain_jboss_datasource('test-datasource').with_xa(false) }
        it do
          is_expected.to contain_jboss_datasource('test-datasource').with_options(
            'validate-on-match'              => false,
            'background-validation'          => false,
            'share-prepared-statements'      => false,
            'prepared-statements-cache-size' => 46
          )
        end
      end
    end
  end

  context 'on Ubuntu os family' do
    extend Testing::RspecPuppet::SharedExamples

    let(:title) { 'test-datasource' }
    let(:params) { merge_params }
    let(:facts) { Testing::RspecPuppet::SharedFacts.ubuntu_facts }

    it { is_expected.to compile.with_all_deps }
    it_behaves_like containing_basic_class_structure

    it do
      is_expected.to contain_jboss_jdbcdriver('test-driver').
        with_classname('com.example.TestDriver').with_modulename('test-driver')
    end
    it { is_expected.to contain_jboss_datasource('test-datasource') }
    it { is_expected.to contain_jboss__datasource('test-datasource') }

    it do
      is_expected.to contain_jboss_datasource('test-datasource').
        with_port(1234)
    end

    it do
      is_expected.to contain_jboss_datasource('test-datasource').
        with_xa(false)
    end

    context 'with option prepared-statements-cache-size set to 46' do
      let(:options) do
        {
          'prepared-statements-cache-size' => 46
        }
      end
      context 'in XA mode' do
        let(:params) do
          merge_params(:options => options, :xa => true)
        end

        it { is_expected.to contain_jboss_datasource('test-datasource').with_xa(true) }
        it do
          is_expected.to contain_jboss_datasource('test-datasource').with_options(
            'validate-on-match'              => false,
            'background-validation'          => false,
            'share-prepared-statements'      => false,
            'prepared-statements-cache-size' => 46,
            'same-rm-override'               => true,
            'wrap-xa-resource'               => true
          )
        end
      end
      context 'in non-XA mode' do
        let(:params) do
          merge_params(:options => options, :xa => false)
        end

        it { is_expected.to contain_jboss_datasource('test-datasource').with_xa(false) }
        it do
          is_expected.to contain_jboss_datasource('test-datasource').with_options(
            'validate-on-match'              => false,
            'background-validation'          => false,
            'share-prepared-statements'      => false,
            'prepared-statements-cache-size' => 46
          )
        end
      end
    end
  end
end
