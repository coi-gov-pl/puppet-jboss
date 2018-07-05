# Class that evaluates given content, jboss console output, and replaces every tuple entry with curly braces
class PuppetX::Coi::Jboss::Internal::Sanitizer
  # It`s some kind of magic: https://regex101.com/r/uE3vD6/1
  REGEXP = Regexp.new('[\n\s]*=>[\n\s]*\[[\n\s]*(\([^\]]+\))[\n\s]*\]', Regexp::MULTILINE)
  # Method that evaluate given String
  # @param {String} content String that will be evaluated
  # @return {Hash} output hash that is a result of eval on given parameter
  def sanitize(content)
    # JBoss expression and Long value handling
    content.gsub!(/expression \"(.+)\",/, '\'\1\',')
    content.gsub!(/=> (\d+)L/, '=> \1')
    evaluate(content)
  end

  private

  # Private method that replaces brackets so it can be evaluated to Ruby style hash
  # @param {String} content String that has braces to be replaced
  # @param {String} output String without brackets
  def evaluate(content)
    double_quoteless = replace_double_quotas(content)

    output = double_quoteless.scan(REGEXP)

    left_param = []
    output.each do |elem|
      left_param.push(elem[0].gsub!(/\(/, '{'))
    end

    right_param = []

    left_param.each do |elem|
      right_param.push(elem.gsub!(/\)/, '}'))
    end

    replace(content, REGEXP, right_param)
  end

  # Private method that change every double quote for single quote
  # @param {String} content String in which we want ot replace
  def replace_double_quotas(content)
    content.gsub(/\"/, "'")
  end

  # Method that replaces text
  # @param {Hash} data hash with incorrect and correct values
  # @param {String} content string with output from jboss console
  def substitue(data, content)
    sanitized_content = content
    data.each do | old_match, sanitized_match |
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
      i = i + 1
    end
    match_sanitized
  end
end
