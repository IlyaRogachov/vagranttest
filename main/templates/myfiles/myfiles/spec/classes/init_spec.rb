require 'spec_helper'
describe 'myfiles' do
  context 'with default values for all parameters' do
    it { should contain_class('myfiles') }
  end
end
