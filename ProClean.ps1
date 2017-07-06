try
{
   
    Add-Type -Path "C:\Source\Libraries\Microsoft.Xrm.Sdk.dll"
    Add-Type -Path "C:\Source\Libraries\Microsoft.Crm.Sdk.Proxy.dll"
    Add-Type -Path "C:\Source\Libraries\Microsoft.IdentityModel.dll"

$ServerUrl = "http://192.168.137.249:5555"
 
$OrganizationName = "IAMark2"

$Credentials = Get-Credential

$CrmConnection = Get-CrmConnection –ServerUrl $ServerUrl -Credential $Credentials -OrganizationName $OrganizationName
$entityname = "contact"
$entitynamePKname = "contactid"
$fieldname ="middlename"
$objectId = "0A800B39-F33F-E711-A9FF-00155D4B0103"

$fieldvalue = "Horace"

<#
Function UpdateCRMRecord
{
	Param (
		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
			[string]$entityname,
			[string]$entitynamePKname,
			[string]$fieldname,
		[guid]$objectId,
			[string]$fieldvalue,
			[bool]$isOptionSet
	)
		if ($isOptionSet)
		{
			$optionSetValue = New-Object -TypeName  "Microsoft.Xrm.Sdk.OptionSetValue" -ArgumentList $fieldvalue	
			$namefield = New-Object -TypeName 'Microsoft.Xrm.Tooling.Connector.CrmDataTypeWrapper' -ArgumentList $([Microsoft.Xrm.Sdk.OptionSetValue]$optionSetValue), $([Microsoft.Xrm.Tooling.Connector.CrmFieldType]::Raw)
		}
		else
		{
#>
			
    $namefield = New-Object -TypeName 'Microsoft.Xrm.Tooling.Connector.CrmDataTypeWrapper' -ArgumentList "$fieldvalue", $([Microsoft.Xrm.Tooling.Connector.CrmFieldType]::String)
		
	
	$updateData = New-Object -TypeName 'System.Collections.Generic.Dictionary[string, Microsoft.Xrm.Tooling.Connector.CrmDataTypeWrapper]'
	
	$updateData.Add($fieldname, $namefield);
	
	Write-Host "Updating $entityname ($objectId). Field: $fieldname to $fieldvalue"

	$result = $CrmConnection.UpdateEntity($entityname, $entitynamePKname, $objectId, $updateData,$applyToSolution, $enabledDuplicateDetection, "00000000-0000-0000-0000-000000000000")


	if(!$result)
		{
			throw $CrmConnection.LastCrmException
		}
}
catch
{
$thing = $_
    $_.LoaderExceptions | %
    {
        Write-Error $_.Message
    }
}	
