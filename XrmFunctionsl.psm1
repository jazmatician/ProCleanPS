#
# XrmFunctionsl.ps1
#
	[System.Reflection.Assembly]::LoadFrom('C:\Source\Libraries\Microsoft.Xrm.Sdk.dll')  
	[System.Reflection.Assembly]::LoadFrom('C:\Source\Libraries\Microsoft.Crm.Sdk.Proxy.dll')  
	[System.Reflection.Assembly]::LoadFrom('C:\Source\Libraries\Microsoft.Xrm.Client.dll')  
	[System.Reflection.Assembly]::LoadFrom('C:\Source\Libraries\Microsoft.IdentityModel.dll')  
	Add-PSSnapin Microsoft.Xrm.Tooling.Connector

function Get-Crm-Connection
{
    # Configure CRM connection
    #$url = "http://organization.domain.com";
    #$login = "user@domain.com";
    #$pwd = "Pass@word1";
    
    #$crmConnection = [Microsoft.Xrm.Client.CrmConnection]::Parse("Url=$url; Username=$login; Password=$pwd");
    #return $crmConnection;
	
$ServerUrl = "http://192.168.137.249:5555"
 
$OrganizationName = "IAMark2"
	$PWord = ConvertTo-SecureString -String "pass@word1" -AsPlainText -Force
	$User = "red\administrator"
$Credentials = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $User, $PWord

$CrmConnection = Get-CrmConnection –ServerUrl $ServerUrl -Credential $Credentials -OrganizationName $OrganizationName
	return $CrmConnection
	
}

function Get-Multiple-Records
{
    PARAM
    (
        [parameter(Mandatory=$true)]$service,
        [parameter(Mandatory=$true)]$query
    )

    $pageNumber = 1;

    $query.PageInfo = New-Object -TypeName Microsoft.Xrm.Sdk.Query.PagingInfo;
    $query.PageInfo.PageNumber = $pageNumber;
    $query.PageInfo.Count = 1000;
    $query.PageInfo.PagingCookie = $null;

    $records = $null;
    while($true)
    {
        $results = $service.RetrieveMultiple($query);
                
        Write-Progress -Activity "Retrieve data from CRM" -Status "Processing record page : $pageNumber" -PercentComplete -1;
        if($results.Entities.Count -gt 0)
        {
            if($records -eq $null)
            {
                $records = $results.Entities;
            }
            else
            {
                $records.AddRange($results.Entities);
            }
        }
        if($results.MoreRecords)
        {
            $pageNumber++;
            $query.PageInfo.PageNumber = $pageNumber;
            $query.PageInfo.PagingCookie = $results.PagingCookie;
        }
        else
        {
            break;
        }
    }
    return $records;
}

function Update-CRM-Record
{
	Param (
        [parameter(Mandatory=$true)]
		[ValidateNotNull()]
			$CrmConnection,
		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
			[string]$entityname,
			[string]$fieldname,
		[guid]$objectId,		
			[string]$entitynamePKname="",
			[string]$fieldvalue="",
			[bool]$isOptionSet=$false
	)
		if($entitynamePKname -eq "") {$entitynamePKname = $entityname + "id"}
		if ($isOptionSet)
		{
			$optionSetValue = New-Object -TypeName  "Microsoft.Xrm.Sdk.OptionSetValue" -ArgumentList $fieldvalue	
			$namefield = New-Object -TypeName 'Microsoft.Xrm.Tooling.Connector.CrmDataTypeWrapper' -ArgumentList $([Microsoft.Xrm.Sdk.OptionSetValue]$optionSetValue), $([Microsoft.Xrm.Tooling.Connector.CrmFieldType]::Raw)
		}
		else
		{
			$namefield = New-Object -TypeName 'Microsoft.Xrm.Tooling.Connector.CrmDataTypeWrapper' -ArgumentList "$fieldvalue", $([Microsoft.Xrm.Tooling.Connector.CrmFieldType]::String)
		}
	$updateData = New-Object -TypeName 'System.Collections.Generic.Dictionary[string, Microsoft.Xrm.Tooling.Connector.CrmDataTypeWrapper]'
	
	$updateData.Add($fieldname, $namefield);
	
	Write-Host "Updating $entityname ($objectId). Field: $fieldname to $fieldvalue"

	$result = $CrmConnection.UpdateEntity($entityname, $entitynamePKname, $objectId, $updateData,$applyToSolution, $enabledDuplicateDetection, "00000000-0000-0000-0000-000000000000")


	if(!$result)
		{
			throw $CrmConnection.LastCrmException
		}
	return $result
}