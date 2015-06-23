# Fetches a file from external resource
define jboss::internal::util::fetch::file (
  $address,
  $fetch_dir,
  $mode       = '0640',
  $owner      = $jboss::jboss_user,
  $group      = $jboss::jboss_group,
  $filename   = $name,
  $attributes = {},
) {
  include jboss

  validate_string($address)

  $all_attrs = merge($attributes, {
    'filename'  => $filename,
    'fetch_dir' => $fetch_dir,
    'mode'      => $mode,
    'owner'     => $owner,
    'group'     => $group,
  })

  $emptyhack = ''

  create_resources($jboss::fetch_tool, {
    "${address}${emptyhack}" => $all_attrs
  })
}
