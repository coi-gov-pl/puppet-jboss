def search(pattern)
  result = Dir['/proc/[0-9]*/cmdline'].inject({}) do |h, file|
    (h[File.read(file).gsub(/\000/, ' ')] ||= []).push(file.match(/\d+/)[0].to_i)
    h
  end.map { |k, v| v if k.match(pattern) }.compact.flatten
  result if result.any?
end

Facter.add(:jboss_running) do
  setcode do
    search(/java .* -server .* org\.jboss\.as/).nil? != true
  end
end
