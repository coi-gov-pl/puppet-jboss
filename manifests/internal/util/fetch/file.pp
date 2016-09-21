# Fetches a file from external resource
define jboss::internal::util::fetch::file (
  $address,
  $fetch_dir,
  $mode       = '0640',
  $owner      = undef,
  $group      = undef,
  $fetch_tool = undef,
  $filename   = $name,
  $attributes = {},
) {

  if defined(Class['jboss']) {
    include jboss
    $actual_owner = $owner ? {
      undef   => $jboss::jboss_user,
      default => $owner
    }
    $actual_group = $group ? {
      undef   => $jboss::jboss_group,
      default => $group
    }
    $actual_fetch_tool = $fetch_tool ? {
      undef   => $jboss::fetch_tool,
      default => $fetch_tool,
    }
  } else {
    include jboss::params
    $actual_owner = $owner ? {
      undef   => $jboss::params::jboss_user,
      default => $owner
    }
    $actual_group = $group ? {
      undef   => $jboss::params::jboss_group,
      default => $group
    }
    $actual_fetch_tool = $fetch_tool ? {
      undef   => $jboss::params::fetch_tool,
      default => $fetch_tool,
    }
  }

  validate_string($address)

  $all_attrs = merge($attributes, {
    'filename'  => $filename,
    'fetch_dir' => $fetch_dir,
    'mode'      => $mode,
    'owner'     => $actual_owner,
    'group'     => $actual_group,
  })

  $emptyhack = ''

  create_resources($actual_fetch_tool, {
    "${address}${emptyhack}" => $all_attrs
  })
}
