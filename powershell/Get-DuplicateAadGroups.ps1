# Finds duplicate AAD Groups or AAD Applications using the Microsoft Graph PowerShell SDK
# https://learn.microsoft.com/en-us/powershell/microsoftgraph/installation?view=graph-powershell-1.0

# install module
Install-Module Az.Accounts, Microsoft.Graph.Authentication
Get-Module Az.Accounts, Microsoft.Graph.Authentication -ListAvailable

# login
# open browser (but may not come into focus)
Connect-AzAccount -UseDeviceAuthentication

# check login context
Get-AzContext

# authenticate to the Microsoft Graph
$accessToken = Get-AzAccessToken -ResourceTypeName 'MSGraph' -ErrorAction 'Stop'
Connect-MgGraph -AccessToken $accessToken.Token

# see debugging output of the command by adding "-Debug"
# Get-MgUser -Top 10 -Debug
# Get-MgApplication -Top 10 -Debug
Get-MgGroup -Top 10 # -Debug

# choose one of the following AD objects
# $aadObjects = Get-MgApplication -All
$aadObjects = Get-MgGroup -All

# check AD objects
$aadObjects.Count
$aadObjects | Sort-Object -Property DisplayName

# group AD objects
$aadObjectsGrouped = $aadObjects | Group-Object -Property DisplayName

# find duplicates
$aadObjectsGroupedDupes = $aadObjectsGrouped | Where-Object Count -GT 1
$aadObjectsGroupedDupes | Sort-Object -Property Count -Descending | Format-Table -AutoSize

# display info
$aadObjectsGroupedDupes.Group | Format-Table -AutoSize
$aadObjectsGroupedDupes.Group | Format-Table -AutoSize | clip.exe
