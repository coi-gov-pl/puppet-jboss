class Puppet_X::Coi::Jboss::Internal::Evaluator
  # It`s some kind of magic: https://regex101.com/r/uE3vD6/1
  REGEXP = Regexp.new('[\n\s]*=>[\n\s]*\[[\n\s]*(\([^\]]+\))[\n\s]*\]', Regexp::MULTILINE)
  # Method that evaluate given String
  # @param {String} content String that will be evaluated
  # @return {Hash} output hash that is a result of eval on given parameter
  def evaluate(content)
    sanitized_content = sanitize(content)
  end

  private

  # Private method that replaces brackets so it can be evaluated to Ruby style hash
  # @param {String} content String that has braces to be replaced
  # @param {String} output String without brackets
  def sanitize(content)
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

    sanitized_conent = replace(content, REGEXP, right_param)
  end

  # Private method that change every double quote for single quote
  # @param {String} content String in which we want ot replace
  # @param {String} replaced String with replaced content
  def replace_double_quotas(content)
    replaced = content.gsub(/\"/, "'")
  end

  def substitue(data, content)
    sanitized_content = content
    data.each do | old_match, sanitized_match |
      sanitized_content = sanitized_content.sub(old_match, sanitized_match)
    end
    sanitized_content
  end

  def replace(content, regexp, sanitized_content)
    data = make_data_structure(regexp, content, sanitized_content)
    substitue(data, content)
  end

  def make_data_structure(regexp, content, sanitized_content)
    rep = {}
    i = 0
    content.scan(regexp) do |match|
      rep[match[0]] = sanitized_content[i]
      i = i + 1
    end
    rep
  end
end
