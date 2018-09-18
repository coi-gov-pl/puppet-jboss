# Class that evaluates given content, jboss console output, and replaces every tuple entry with curly braces
class PuppetX::Coi::Jboss::Internal::Sanitizer
  # It`s some kind of magic: https://regex101.com/r/uE3vD6/1
  REGEXP = Regexp.new('[\n\s]*=>[\n\s]*\[[\n\s]*(\([^\]]+\))[\n\s]*\]', Regexp::MULTILINE)

  # Method that sanitizes given JBoss DMR string to be JSON loadable
  #
  # @param content [String] String that will be sanitized
  # @return [String] output sanitized string
  def sanitize(content)
    # JBoss expression and Long value handling
    result = content
    result = replace_bytes_repr(result).
             gsub(/expression \"(.+)\"/, "'\\1'").
             gsub(/=> (-?\d+)L/, '=> \1')
    evaluate(result).
      gsub(/\s*=>/, ':').
      gsub(/(:\s*)'([^']+)'/, '\1"\2"').
      gsub(/:\s*undefined/, ': null').
      gsub(/:\s*nil/, ': null').
      gsub(/,(\s+[\}\]])/m, '\1')
  end

  private

  # Ref: https://regex101.com/r/VNUZYh/1
  def replace_bytes_repr(content)
    result = content
    loop do
      match = content.match(/bytes \{\s+((?:0x[0-9a-f]{2},\s+)*0x[0-9a-f]{2})\s+\}/m)
      break if match.nil?
      full = match[0]
      bytes = match[1].gsub(/\s+/m, '').split(',').map { |byte| Integer(byte) }
      result.gsub!(full, bytes.inspect)
    end
    result
  end

  # Private method that replaces brackets so it can be evaluated to Ruby style hash
  # @param {String} content String that has braces to be replaced
  # @param {String} output String without brackets
  def evaluate(content)
    output = content.scan(REGEXP)

    left_param = []
    output.each do |elem|
      left_param.push(elem[0].tr!('(', '{'))
    end

    right_param = []

    left_param.each do |elem|
      right_param.push(elem.tr!(')', '}'))
    end

    replace(content, REGEXP, right_param)
  end

  # Method that replaces text
  # @param {Hash} data hash with incorrect and correct values
  # @param {String} content string with output from jboss console
  def substitue(data, content)
    sanitized_content = content
    data.each do |old_match, sanitized_match|
      sanitized_content = sanitized_content.sub(old_match, sanitized_match)
    end
    sanitized_content
  end

  # Method that delegates substitution of given content
  # @param {String} content with text to be repalaced
  # @param {Regexp} regexp that will be used to search for text
  # @param {List} sanitized_content is a list with correct text
  def replace(content, regexp, sanitized_content)
    data = make_data_structure(regexp, content, sanitized_content)
    substitue(data, content)
  end

  # Method that makes hash with old match as key and sanitized content as output
  # @param {Regexp} regexp that is used to search for forbidden text
  # @param {String} content with text that contains forbidden text
  # @param {List} list of sanitized text
  def make_data_structure(regexp, content, sanitized_content)
    match_sanitized = {}
    i = 0
    content.scan(regexp) do |match|
      match_sanitized[match[0]] = sanitized_content[i]
      i += 1
    end
    match_sanitized
  end
end
