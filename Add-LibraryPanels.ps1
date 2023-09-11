Param(
    [string][Parameter(Mandatory)] $Grafana_Source_Url,
    [string][Parameter(Mandatory)] $Grafana_Source_Token,
    [string][Parameter(Mandatory)] $Grafana_Target_Url,
    [string][Parameter(Mandatory)] $Grafana_Target_Token
)

$GetHeaders = @{Authorization = "Bearer $Grafana_Source_Token"}
$ContentType = "application/json"
$WriteHostBreak = "`r`n ------------------------------------------"


$LibraryPanelResult = Invoke-WebRequest -Uri "$Grafana_Source_Url/api/library-elements" -ContentType $ContentType -headers $GetHeaders

$LibraryPanels = $LibraryPanelResult | ConvertFrom-Json -Depth 32

Write-Host $LibraryPanels.result.elements.length "Library Panels discovered." $WriteHostBreak


foreach($element in $LibraryPanels.result.elements){
    ### Blanking out the following values, as there appears to be a bug in the API when trying to create Library Panels in specific folders. 
    $element.folderUid = ""
    $element.meta.folderUid = ""
    $element.folderId = 0
    
    $PostBody =  ($element | ConvertTo-Json -Depth 32)
    

    $PostHeaders = @{Authorization = "Bearer $Grafana_Target_Token"}

    try {
        Invoke-RestMethod -Method 'Post' -Uri "$Grafana_Target_Url/api/library-elements" -Body $PostBody -ContentType $ContentType -Headers $PostHeaders
        Write-Host $element.name "created on target Grafana Instance: " $Grafana_Target_Url
    } catch [System.SystemException] {
        Write-Host "Error Message" $_.ErrorDetails -ForegroundColor Red
    }
}