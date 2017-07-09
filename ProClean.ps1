Import-Module ".\Libraries\Microsoft.Xrm.Data.PowerShell\Microsoft.Xrm.Data.PowerShell.psd1"
<#
$entityName = "contact"
$fieldName = "mobilephone"
$updateTo = "2342342"
#>


$config = Get-Content -Raw ".\ProClean.json" | ConvertFrom-Json
$entitykey = $config.entityName + "id"
$updateTo = $config.updateTo;
if ($updateTo -eq $null) { $updateTo = "";}

if ($conn -eq $null) { $conn = Get-CrmConnection -InteractiveMode }
$records = Get-CrmRecords -conn $conn -entityLogicalName $config.entityName -filterAttribute $config.fieldName -FilterOperator "not-null" -Fields $fieldName,$($entityName+"id")

"retrieved $($records.Count) records with non-null $($config.fieldname)"

foreach ($rec in $records.CrmRecords) {Set-CrmRecord -EntityLogicalName $config.entityName -Id $rec.($entitykey)-Fields @{$config.fieldName=$config.updateTo}}

