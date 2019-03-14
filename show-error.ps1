function show-error ([string]$Message, [int]$ExitStatus=1) {
    
    Write-Host -ForegroundColor red "`n$Message"
    Write-Host -ForegroundColor White "`nHow to use this script :"
    exit $ExitStatus
}

show-error "can't find"