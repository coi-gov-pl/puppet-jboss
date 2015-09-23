guard 'rake', :task => :spec_ruby do
  watch(%r{spec/(unit|functions|hosts|integration|types)/.+_spec\.rb})
  watch(%r{lib/.+\.rb})
end
guard 'rake', :task => :spec_puppet_prepared do
  watch(%r{spec/(classes|defines)/.+_spec\.rb})
  watch(%r{manifests/.+\.pp})
end
