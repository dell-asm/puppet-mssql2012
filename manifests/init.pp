# Class: mssql2012
#
# This module manages mssql2012
#
# $media - location of installation files.
#
# Requires: see Modulefile
#
class mssql2012 (
# See http://msdn.microsoft.com/en-us/library/ms144259.aspx
  # Media is required to install
  $media          = '\\dellasm\razor\SQLServer2012',
  $instancename   = 'MSSQLSERVER',
  $features       = 'SQLENGINE,CONN,SSMS,ADV_SSMS',
  $sapwd          = 'Sql!@as#2012demo',
  $agtsvcaccount  = 'SQLAGTSVC',
  $agtsvcpassword = 'Sql!@gt#2012demo',
  $assvcaccount   = 'SQLASSVC',
  $assvcpassword  = 'Sql!@s#2012demo',
  $rssvcaccount   = 'SQLRSSVC',
  $rssvcpassword  = 'Sql!Rs#2012demo',
  $sqlsvcaccount  = 'SQLSVC',
  $sqlsvcpassword = 'Sql!#2012demo',
  $instancedir    = 'C:\Program Files\Microsoft SQL Server\\',
  $ascollation    = 'Latin1_General_CI_AS',
  $sqlcollation   = 'SQL_Latin1_General_CP1_CI_AS',
  $admin          = 'Administrator',
  $netfxsource    = '\\dellasm\razor\windows_install\sources\sxs'
)  {

  User {
    ensure   => present,
    before => Exec['install_mssql2012'],
  }

  user { 'SQLAGTSVC':
    comment  => 'SQL 2012 Agent Service.',
    password => $agtsvcpassword,
  }
  user { 'SQLASSVC':
    comment  => 'SQL 2012 Analysis Service.',
    password => $assvcpassword,
  }
  user { 'SQLRSSVC':
    comment  => 'SQL 2012 Report Service.',
    password => $rssvcpassword,
  }
  user { 'SQLSVC':
    comment  => 'SQL 2012 Service.',
    groups   => 'Administrators',
    password => $sqlsvcpassword,
  }

  file { 'C:\sql2012install.ini':
    content => template('mssql2012/config.ini.erb'),
  }

  dism { 'NetFx3':
    ensure           => present,
    source           => $netfxsource,
    all_dependencies => 1
  }

  exec { 'install_mssql2012':
    command   => "${media}\\setup.exe /Action=Install /IACCEPTSQLSERVERLICENSETERMS /Q /HIDECONSOLE /CONFIGURATIONFILE=C:\\sql2012install.ini /SAPWD=\"${sapwd}\" /SQLSVCPASSWORD=\"${sqlsvcpassword}\" /AGTSVCPASSWORD=\"${agtsvcpassword}\" /ASSVCPASSWORD=\"${assvcpassword}\" /RSSVCPASSWORD=\"${rssvcpassword}\"",
    cwd       => $media,
    path      => $media,
    logoutput => true,
    creates   => $instancedir,
    timeout   => 3000,
    require   => [ File['C:\sql2012install.ini'],
                   Dism['NetFx3'] ],
  }
}
