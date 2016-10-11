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
  $media          = "\\dellasm\razor\SQLServer2012",
  $instancename   = "MSSQLSERVER",
  $features       = "SQLENGINE,CONN,SSMS,ADV_SSMS",
  $sapwd          = "Sql!@as#2012demo",
  $agtsvcaccount  = "SQLAGTSVC",
  $agtsvcpassword = "Sql!@gt#2012demo",
  $assvcaccount   = "SQLASSVC",
  $assvcpassword  = "Sql!@s#2012demo",
  $rssvcaccount   = "SQLRSSVC",
  $rssvcpassword  = "Sql!Rs#2012demo",
  $sqlsvcaccount  = "SQLSVC",
  $sqlsvcpassword = "Sql!#2012demo",
  $instancedir    = "C:\Program Files\Microsoft SQL Server",
  $ascollation    = "Latin1_General_CI_AS",
  $sqlcollation   = "SQL_Latin1_General_CP1_CI_AS",
  $admin          = "Administrator",
  $netfxsource    = "\\dellasm\razor\windows_install\sources\sxs"
)  {

  User {
    ensure   => present,
    before => Exec["install_mssql_2012"],
  }

  user { "SQLAGTSVC":
    comment  => "SQL 2012 Agent Service.",
    password => $agtsvcpassword,
    provider => "asm_decrypt_token",
  }
  user { "SQLASSVC":
    comment  => "SQL 2012 Analysis Service.",
    password => $assvcpassword,
    provider => "asm_decrypt_token",
  }
  user { "SQLRSSVC":
    comment  => "SQL 2012 Report Service.",
    password => $rssvcpassword,
    provider => "asm_decrypt_token",
  }
  user { "SQLSVC":
    comment  => "SQL 2012 Service.",
    groups   => "Administrators",
    password => $sqlsvcpassword,
    provider => "asm_decrypt_token",
  }

  file { "C:\sql2012install.ini":
    content => template("mssql2012/config.ini.erb"),
  }

  dism { "NetFx3":
    ensure           => present,
    source           => $netfxsource,
    all_dependencies => 1
  }

  exec { "install_mssql_2012":
    command   => template("mssql2012/install_mssql_2012.ps1.erb"),
    logoutput => true,
    creates   => $instancedir,
    timeout   => 3000,
    require   => [ File["C:\sql2012install.ini"],
                       Dism["NetFx3"] ],
    provider  => powershell,
  }
}
