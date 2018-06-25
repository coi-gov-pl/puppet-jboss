unless File.respond_to? :absolute_path
  # Overriden Ruby class (for Ruby 1.8)
  class File
    class << self
      def absolute_path(path, directory = Dir.pwd)
        File.expand_path(path, directory)
      end
    end
  end
end
