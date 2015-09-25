# Internal class - JBoss memory defaults
class jboss::internal::params::memorydefaults {
  # Perm Gen memory initial
  $permgensize    = hiera('jboss::internal::params::memorydefaults::permgensize', '32m')
  # Perm Gen memory maximum
  $maxpermgensize = hiera('jboss::internal::params::memorydefaults::maxpermgensize', '256m')
  # Heap memory initial
  $heapsize       = hiera('jboss::internal::params::memorydefaults::heapsize', '256m')
  # Heap memory maximum
  $maxheapsize    = hiera('jboss::internal::params::memorydefaults::maxheapsize', '1303m')
}
