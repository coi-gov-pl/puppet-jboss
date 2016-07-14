# == Class jboss::internal::relationship::module_before_user
# Class that contains relationship beetwen modules and user, all modules have to be assembled before user is made
class jboss::internal::relationship::module_user {

  anchor { 'jboss::internal::relationship::module_user': }
}
