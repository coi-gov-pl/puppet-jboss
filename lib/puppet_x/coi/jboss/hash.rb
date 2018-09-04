# A Hash that can maintain order of inserted elements
class PuppetX::Coi::Jboss::Hash < Hash
  def initialize
    @keys = []
  end

  def []=(key, val)
    @keys << key unless @keys.include?(key)
    super
  end

  def delete(key)
    @keys.delete(key)
    super
  end

  def ordered_keys
    @keys ||= []
  end

  def each_in_order(&_block)
    ordered_keys.each do |key|
      yield(key, self[key])
    end
  end

  def each_sorted(&_block)
    keys.map(&:to_s).sort.each do |key|
      yield(key, self[key])
    end
  end
end
