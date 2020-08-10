<#
.SYNOPSIS
Ensure that SIS TCH EM (email) field use proper email format
.DESCRIPTION
This Script Updates the Aeries SIS currentyeardb.dbo.tch table.
.EXAMPLE
Update-AeriesTCH.PS1 -DC $dc -ADCred $adCred -SISServer SISServer -SISData SISDB -SISCred $SISCred
.INPUTS
.OUTPUTS
.NOTES
.LINK
#>

[cmdletbinding()]
param (
 # Student Information Server
 [Parameter(Mandatory = $true)]
 [ValidateScript( { Test-Connection -ComputerName $_ -Quiet -Count 1 })]
 [string]$SISServer,
 [Parameter(Mandatory = $true)]
 [string]$SISDatabase,
 [Parameter(Mandatory = $true)]
 [System.Management.Automation.PSCredential]$SISCredential,
 [Parameter(Mandatory = $true)]
 [string]$StartDomain,
 [Parameter(Mandatory = $true)]
 [string]$EndDomain,
 # Run a Whatif on commands - no data will be changed
 [Alias('wi')]
	[switch]$WhatIf
)

Clear-Host ; $error.clear() # Clear screen and error log.
Get-PSSession | Remove-PSSession -WhatIf:$false

# Variables

# Imported Functions
. '.\lib\Add-Log.ps1'
. '.\lib\Invoke-SQLCOmmand.PS1'

$dbParams = @{
 Server     = $SISServer
 Database   = $SISDatabase
 Credential = $SISCredential
}

# RUn x times and exit
$x = 4
for ($i;$i -le $x;$i++){
 $query = "SELECT EM FROM TCH WHERE TCH.EM LIKE `'%$StartDomain`'"
 $results = Invoke-SQLCommand @dbParams -SqlCommand $query
 
 if ($results) {
  foreach ($em in $results) {
   $samid = $em.em.split('@')[0]
   Add-Log update ('TCH.EM value {0}{1} set to {0}{2}'-f $samid,$StartDomain,$EndDomain)
  }
  $updateStatement = "update tch set tch.em = replace (TCH.EM ,`'$StartDomain`',`'$EndDomain`')  where tch.em like `'%$StartDomain`';"
  Invoke-SQLCommand @dbParams -SqlCommand $updateStatement -WhatIf:$WhatIf
 }
 if ( $WhatIf ) { break } # break loop if testing
 # Wait x hours
 $hours = 2
 Add-log sleep ('Next run at {0}'-f ((Get-Date).AddHours($hours)) )
 Start-Sleep (60*60*$hours)
}

Add-Log script "Tearing down PS Sessions..."
Get-PSSession | Remove-PSSession -WhatIf:$false