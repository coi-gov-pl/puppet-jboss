# jboss_member
#
module Puppet::Parser::Functions
  jboss_member_doc = <<-DOC
    This function determines if a variable is a member of an array.
    The variable can be a string, fixnum, or array.
    *Examples:*
        jboss_member(['a','b'], 'b')
    Would return: true
        jboss_member(['a', 'b', 'c'], ['a', 'b'])
    would return: true
        jboss_member(['a','b'], 'c')
    Would return: false
        jboss_member(['a', 'b', 'c'], ['d', 'b'])
    would return: false
    Note: Since Puppet 4.0.0 the same can be performed in the Puppet language. For single values
    the operator `in` can be used:
        'a' in ['a', 'b']  # true
    And for arrays by using operator `-` to compute a diff:
        ['d', 'b'] - ['a', 'b', 'c'] == []  # false because 'd' is not subtracted
        ['a', 'b'] - ['a', 'b', 'c'] == []  # true because both 'a' and 'b' are subtracted
    Also note that since Puppet 5.2.0 the general form of testing content of an array or hash is to use the built-in
    `any` and `all` functions.

    Copy of member function from puppetlabs/stdlib == 4.25.1
  DOC
  newfunction(:jboss_member, :type => :rvalue, :doc => jboss_member_doc) do |arguments|
    PuppetX::Coi::Jboss::Functions.member(arguments)
  end
end
