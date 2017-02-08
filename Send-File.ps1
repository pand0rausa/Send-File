function Send-File {
    param (
        [parameter(Mandatory=$True,Position=1)] [ValidateScript({ Test-Path -PathType Leaf $_ })] [String] $ResultFilePath,
        [parameter(Mandatory=$True,Position=2)] [System.URI] $ResultURL
    )
    $fileBin = [IO.File]::ReadAllBytes($ResultFilePath)

# Convert byte-array to string (without changing anything)
#
$enc = [System.Text.Encoding]::GetEncoding("iso-8859-1")
$fileEnc = $enc.GetString($fileBin)
$user = $env:userdomain + "\" + $env:username
$proxySetting = (get-itemproperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings').ProxyServer
$boundary = [System.Guid]::NewGuid().ToString()    # 

$LF = "`n"
$bodyLines = (
    "--$boundary",
    "Content-Disposition: form-data; filename=`"file`"$LF",   # filename= is optional
    $fileEnc,
    "--$boundary"
    ) -join $LF

try {
    # Returns the response gotten from the server (we pass it on).
    #
    Invoke-WebRequest -Uri $ResultURL -Method Post -ContentType "multipart/form-data; boundary=`"--$boundary`"" -TimeoutSec 20 -Body $bodyLines -Proxy $proxySetting -ProxyCredential $user -Credential $user
}
catch [System.Net.WebException] {
    Write-Error( "FAILED to reach '$URL': $_" )
    throw $_
}}
