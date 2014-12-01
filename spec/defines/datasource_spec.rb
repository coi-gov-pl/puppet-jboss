require 'spec_helper'

describe 'jboss::datasource' do
  def merge_params(hash = {})
    hash.merge({
      :name => title,
      :username => 'test-username',
      :password => 'test-password',
      :jdbcscheme => 'test-scheme',
      :host => 'example.com',
      :port => '1234',
      :driver => {
        'name' => 'test-driver',
        'classname' => 'com.example.TestDriver',
        'modulename' => 'test-driver',
      },
    })
  end

  let(:title) { 'test-datasource' }
  let(:params) { merge_params }
  let(:facts) { {
    :osfamily => "RedHat",
    :operatingsystem => "RedHat",
    'jboss::profile' => "domain",
    'jboss::controller' => "controller.example.com",
    :concat_basedir => "/tmp/"
  } }

  it do
    should contain_jboss_datasource('test-datasource').
      with_useccm(false)
  end

  it do
    should contain_jboss_datasource('test-datasource').
      with_preparedstatementscachesize(0)
  end

  context 'with preparedstatementscachesize => 100' do
    let(:params) { merge_params({ :preparedstatementscachesize => 100 }) }

    it do
      should contain_jboss_datasource('test-datasource').
        with_preparedstatementscachesize(100)
    end
  end
end

