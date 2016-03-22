module Testing::Acceptance::SmokeTestReader
  class << self
    def smoke_pp(pp_symbol)
      path = smokedir.join(pp_symbol.to_s.gsub(/::/, '/') + '.pp')
      path.read
    end

    private

    def smokedir
      rootdir.join('tests')
    end

    def rootdir
      Pathname.new(__FILE__).parent.parent.parent.parent.realpath
    end
  end
end
