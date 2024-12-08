# Parse arguments
Param (
    [Parameter(Mandatory = $true)]
    [string]$PICO8File,

    [Parameter(Mandatory = $true)]
    [string]$ReleaseVersion
)

# Define the function to export the PICO-8 file
function Export-PICO8File {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PICO8File,

        [Parameter(Mandatory = $true)]
        [string]$ReleaseVersion,

        [Parameter(Mandatory = $true)]
        [string]$ExportExtension
    )

    # Check if the PICO-8 file exists
    if (-not (Test-Path $PICO8File)) {
        Write-Error "File '$PICO8File' not found. Please check the file path."
        return
    }

    # Validate the file extension
    if ([System.IO.Path]::GetExtension($PICO8File) -ne ".p8") {
        Write-Error "The file must have a .p8 extension."
        return
    }

    # Generate the export filename
    $FileNameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($PICO8File)
    $ExportFileName = "${FileNameWithoutExtension}_v${ReleaseVersion}.${ExportExtension}"

    # Run the PICO-8 export command
    $Command = "pico8 $PICO8File -export $ExportFileName"

    Write-Host "Running command: $Command"
    $Process = Start-Process -FilePath "cmd.exe" -ArgumentList "/c", $Command -NoNewWindow -PassThru -Wait

    # Check if the process was successful
    if ($Process.ExitCode -eq 0) {
        Write-Host "Export successful! File saved as '$ExportFileName'." -ForegroundColor Green
    } else {
        Write-Error "Export failed with exit code $($Process.ExitCode)."
    }
}

# Run the function if arguments are provided
if ($PICO8File -and $ReleaseVersion) {
    Export-PICO8File -PICO8File $PICO8File -ReleaseVersion $ReleaseVersion -ExportExtension "bin"
    Export-PICO8File -PICO8File $PICO8File -ReleaseVersion $ReleaseVersion -ExportExtension "html"
    Export-PICO8File -PICO8File $PICO8File -ReleaseVersion $ReleaseVersion -ExportExtension "p8.png"
} else {
    Write-Host "Usage: .\Export-PICO8.ps1 -PICO8File <path_to_file.p8> -ReleaseVersion <version>"
}
