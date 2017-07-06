
try
{   
	#Add-PSSnapin Microsoft.Xrm.Tooling.Connector
	Import-Module "C:\Source\ProCleanPS\XrmFunctionsl.psm1" -Force
	$CrmConnection = Get-Crm-Connection
#$service = New-Object -TypeName Microsoft.Xrm.Client.Services.OrganizationService -ArgumentList $CrmConnection;
$entityname = "contact"
$entitynamePKname = "contactid"
$fieldname ="middlename"
$objectId = "0A800B39-F33F-E711-A9FF-00155D4B0103"

$fieldvalue = "Polygast"
	Update-CRM-Record $CrmConnection $entityname $fieldname $objectId
}
catch
{
$thing = $_
    #$_.LoaderExceptions | %
    #{
    #   # Write-Error $_.Message
    #}
}	

