Import-Module ".\Libraries\Microsoft.Xrm.Data.PowerShell\Microsoft.Xrm.Data.PowerShell.psd1"
<#
$entityName = "contact"
$fieldName = "mobilephone"
$updateTo = "2342342"
#>

    if ($conn -eq $null) { $conn = Get-CrmConnection -InteractiveMode }

$configColl = Get-Content -Raw ".\ProClean.json" | ConvertFrom-Json
foreach ($config in $configColl.entities) {
    $entitykey = $config.entityName + "id"
    $attributes = ""; $criteria = ""; $fields = @{};
    foreach ($clearMe in $config.fieldsToClear) {
        $attributes += "<attribute name='$clearMe' />"
        $criteria += "<condition attribute='$clearMe' operator='not-null' />"
        $fields.Add($clearMe,"");
    }
    $fetch = '<fetch version="1.0" output-format="xml-platform" mapping="logical" distinct="false" no-lock="true">'
    $fetch += "<entity name='$($config.entityName)'>"
    $fetch += $attributes
    $fetch += "<filter type='or' >"
    $fetch += $criteria
    $fetch += "</filter></entity></fetch>"

  <# PII only, not resetting any fields
    $updateTo = $config.updateTo;
    if ($updateTo -eq $null) { $updateTo = "";}
    #>
    $page = 1
    $cookie = $null
    do {
        $records =  Get-CrmRecordsByFetch -conn $conn -Fetch $fetch -PageNumber $page -PageCookie $cookie  -AllRows
        #}
    
        "retrieved $($records.Count) records with non-null $($config.fieldname)"
        $cookie = $records.PagingCookie;
        $page += 1;


        foreach ($rec in $records.CrmRecords) {
            Set-CrmRecord -EntityLogicalName $config.entityName -Id $rec.($entitykey) -Fields $fields;
        }
    } while ($records.NextPage -eq $true)
}
