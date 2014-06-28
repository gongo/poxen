$userdir = "/Users/${boxen_user}"

define goget ($package = $title) {
  exec { "go get -u ${package}":
  }
}

node default {
  # This is required to apply some manifests since these are not using
  # appropriate user, group or full path to the command.
  Exec {
    group => 'staff',
    user => $boxen_user,
    path => [
      "${userdir}/.homebrew/bin",
      '/usr/local/bin',
      '/usr/bin',
      '/bin',
      '/usr/sbin',
      '/sbin'
    ],
    environment => [
      "HOME=${userdir}",
      "GOPATH=${userdir}/.go"
    ]
  }

  Package {
    provider => homebrew,
    require => Class['homebrew']
  }

  # This is also required to apply some manifests correctly.
  File {
    group => 'staff',
    owner => $boxen_user
  }

  # Run all defaults command as login user.
  Boxen::Osx_defaults {
    user => $boxen_user
  }

  # Your manifests goes here.

  include osx::dock::autohide

  file { '/tmp/Brewfile':
    ensure    => present,
    content   => template('Brewfile')
  }

  exec { 'brew bundle /tmp/Brewfile':
    logoutput => true,
    timeout   => 0
  }

  $go_packages = [
    'code.google.com/p/go.tools/cmd/goimports',
    'github.com/golang/lint/golint',
    'github.com/nsf/gocode'
  ]

  goget { $go_packages: }
}
