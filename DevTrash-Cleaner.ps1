param (
    [string]$Path = (Get-Location).Path
)

<#
=========================================================================
  FOLDER CLEANUP UTILITY
  Developed By: Waseem Ahmad Naeem (@WaseemAhmadNaeem)
  Version: 1.0
=========================================================================
  This script finds and deletes specified folders (node_modules, .angular, bin)
  in an optimized way to eliminate redundancy and improve cleanup efficiency.
#>

$foldersToDelete = @("node_modules", ".angular", "bin")

# Console styling variables
$headerFg = "White"
$headerBg = "DarkBlue"
$subheaderFg = "Cyan"
$warningFg = "Yellow"
$errorFg = "Red"
$successFg = "Green"
$highlightFg = "Magenta"
$normalFg = "White"

# Check if console supports colors
$hasColorSupport = $Host.UI.SupportsVirtualTerminal

# Function to set header background and foreground
function Write-Header {
    param ([string]$Text)
    
    if ($hasColorSupport) {
        $originalFg = $Host.UI.RawUI.ForegroundColor
        $originalBg = $Host.UI.RawUI.BackgroundColor
        
        $Host.UI.RawUI.ForegroundColor = $headerFg
        $Host.UI.RawUI.BackgroundColor = $headerBg
        
        $padding = " " * 2
        $paddedText = $padding + $Text + $padding
        $consoleCols = $Host.UI.RawUI.WindowSize.Width
        $textPadding = " " * ($consoleCols - $paddedText.Length)
        
        Write-Host ($paddedText + $textPadding)
        
        $Host.UI.RawUI.ForegroundColor = $originalFg
        $Host.UI.RawUI.BackgroundColor = $originalBg
    } else {
        Write-Host $Text -ForegroundColor $headerFg
    }
}

function Write-ColorText {
    param (
        [string]$Text,
        [string]$Color = $normalFg
    )
    
    Write-Host $Text -ForegroundColor $Color
}

function Write-Separator {
    Write-Host ("=" * 80) -ForegroundColor $subheaderFg
}

function Write-SubHeader {
    param ([string]$Text)
    
    Write-Host ""
    Write-Separator
    Write-ColorText $Text -Color $subheaderFg
    Write-Separator
}

# Enhanced progress bar with ASCII characters instead of Unicode blocks
function Show-EnhancedProgressBar {
    param (
        [int]$PercentComplete,
        [string]$Status,
        [string]$BarColor = $subheaderFg
    )
    
    $width = 50
    $filledWidth = [math]::Floor($width * $PercentComplete / 100)
    $emptyWidth = $width - $filledWidth
    
    # Use simple ASCII characters instead of Unicode blocks
    $progressBar = "[" + ("#" * $filledWidth) + (" " * $emptyWidth) + "]"
    Write-Host "`r$progressBar $PercentComplete% $Status" -ForegroundColor $BarColor -NoNewline
}

# Function for simple animation with ASCII characters
function Show-Animation {
    param (
        [string]$Message,
        [int]$Duration = 2,
        [string]$Color = $subheaderFg
    )
    
    # Always use simple ASCII spinner
    $spinner = @("-", "\", "|", "/")
    
    $endTime = (Get-Date).AddSeconds($Duration)
    
    $i = 0
    while ((Get-Date) -lt $endTime) {
        $frame = $spinner[$i % $spinner.Length]
        Write-Host "`r$Message $frame" -ForegroundColor $Color -NoNewline
        Start-Sleep -Milliseconds 100
        $i++
    }
    
    Write-Host "`r$Message... Complete!   " -ForegroundColor $successFg
}

# Function to format file size
function Format-FileSize {
    param ([long]$Size)
    
    if ($Size -ge 1TB) { return "{0:N2} TB" -f ($Size / 1TB) }
    elseif ($Size -ge 1GB) { return "{0:N2} GB" -f ($Size / 1GB) }
    elseif ($Size -ge 1MB) { return "{0:N2} MB" -f ($Size / 1MB) }
    elseif ($Size -ge 1KB) { return "{0:N2} KB" -f ($Size / 1KB) }
    else { return "$Size Bytes" }
}

# Function to simulate typing effect
function Write-TypeText {
    param(
        [string]$Text,
        [int]$DelayMilliseconds = 10,
        [string]$Color = $normalFg
    )
    
    if ($hasColorSupport) {
        foreach ($char in $Text.ToCharArray()) {
            Write-Host $char -NoNewline -ForegroundColor $Color
            Start-Sleep -Milliseconds $DelayMilliseconds
        }
        Write-Host ""
    } else {
        Write-Host $Text -ForegroundColor $Color
    }
}

# Clear the screen and show script header
Clear-Host

# Title with typing effect
if ($hasColorSupport) {
    Write-Host ""
    Write-TypeText "  INITIALIZING FOLDER CLEANUP UTILITY..." -Color $highlightFg -DelayMilliseconds 5
    Start-Sleep -Milliseconds 500
}

# Main header
Write-Header "  FOLDER CLEANUP UTILITY v1.0  "
Write-Host ""
Write-ColorText "  Developed By: Waseem Ahmad Naeem (@WaseemAhmadNaeem)" -Color $highlightFg
Write-Host ""
Write-Separator
Write-ColorText "  Path: $Path" -Color $subheaderFg
Write-ColorText "  Target Folders: $($foldersToDelete -join ', ')" -Color $subheaderFg
Write-Separator
Write-Host ""

# Start finding relevant folders
Show-Animation -Message "Scanning file system for target folders" -Duration 2

# Get all instances of target folders
$allFolders = @()
foreach ($folderName in $foldersToDelete) {
    Write-Host "  Searching for '$folderName' folders..." -NoNewline -ForegroundColor $normalFg
    
    $folderInstances = Get-ChildItem -Path $Path -Recurse -Directory -Force -ErrorAction SilentlyContinue | 
        Where-Object { $_.Name -eq $folderName } | 
        Select-Object -ExpandProperty FullName
    
    if ($folderInstances.Count -gt 0) {
        Write-Host " Found $($folderInstances.Count) instances." -ForegroundColor $successFg
    } else {
        Write-Host " None found." -ForegroundColor $warningFg
    }
    
    $allFolders += $folderInstances
}

Write-Host ""
if ($allFolders.Count -gt 0) {
    Write-ColorText "  Total folder instances found: $($allFolders.Count)" -Color $successFg
} else {
    Write-ColorText "  Total folder instances found: 0" -Color $warningFg
}
Write-Host ""

# Analyzing results
Show-Animation -Message "Analyzing folder structure and dependencies" -Duration 2

# Filter to keep only the highest-level instances
$foldersToProcess = @{}

Write-Host "  Optimizing folder selection for efficient deletion..." -NoNewline -ForegroundColor $normalFg
foreach ($folder in $allFolders) {
    $isRedundant = $false
    
    # Check if this folder is inside another folder that's already in our list
    foreach ($otherFolder in $allFolders) {
        if (($folder -ne $otherFolder) -and ($folder.StartsWith($otherFolder + "\"))) {
            $isRedundant = $true
            break
        }
    }
    
    if (-not $isRedundant) {
        $foldersToProcess[$folder] = $folder
    }
}

if ($foldersToProcess.Count -gt 0) {
    Write-Host " Optimized to $($foldersToProcess.Count) folders." -ForegroundColor $successFg
} else {
    Write-Host " No folders to process." -ForegroundColor $warningFg
}
Write-Host ""

if ($foldersToProcess.Count -eq 0) {
    Write-ColorText "  No matching folders found for deletion." -Color $warningFg
    Write-Host ""
    Write-Host "  Press Enter to exit..." -NoNewline
    Read-Host
    exit
}

# Display found folders
Write-SubHeader "  FOLDERS IDENTIFIED FOR DELETION"

$folderNumber = 1
$foldersToProcess.GetEnumerator() | ForEach-Object {
    Write-Host "  [$folderNumber] " -NoNewline -ForegroundColor $highlightFg
    Write-Host "$($_.Value)" -ForegroundColor $normalFg
    $folderNumber++
}

Write-Host ""
Show-Animation -Message "Calculating folder sizes and potential disk space savings" -Duration 3

# Calculate folder sizes with progress bar
$folderSizes = @{}
$totalSize = 0
$index = 0

foreach ($folder in $foldersToProcess.Keys) {
    $index++
    $percent = [math]::Floor(($index / $foldersToProcess.Count) * 100)
    
    Show-EnhancedProgressBar -PercentComplete $percent -Status "Analyzing: $(Split-Path $folder -Leaf)"
    
    try {
        $size = (Get-ChildItem -Path $folder -Recurse -File -Force -ErrorAction SilentlyContinue | 
            Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
        
        if ($null -eq $size) { $size = 0 }
        
        $folderSizes[$folder] = $size
        $totalSize += $size
    }
    catch {
        $folderSizes[$folder] = 0
    }
    
    # Small delay for visual effect
    Start-Sleep -Milliseconds 50
}

Write-Host ""
Write-Host ""
Write-ColorText "  Total potential space to recover: $(Format-FileSize $totalSize)" -Color $successFg
Write-Host ""

# Display detailed results with sizes
Write-SubHeader "  DETAILED SIZE ANALYSIS"

$folderNumber = 1
$foldersToProcess.GetEnumerator() | ForEach-Object {
    $folderPath = $_.Value
    $size = $folderSizes[$folderPath]
    
    if ($size -is [long]) {
        $formattedSize = Format-FileSize $size
        Write-Host "  [$folderNumber] " -NoNewline -ForegroundColor $highlightFg
        Write-Host "$folderPath " -NoNewline -ForegroundColor $normalFg
        Write-Host "($formattedSize)" -ForegroundColor $successFg
    }
    else {
        Write-Host "  [$folderNumber] " -NoNewline -ForegroundColor $highlightFg
        Write-Host "$folderPath " -NoNewline -ForegroundColor $normalFg
        Write-Host "(Size unknown)" -ForegroundColor $warningFg
    }
    
    $folderNumber++
}

# Confirm deletion
Write-Host ""
Write-Host "  " -NoNewline
Write-ColorText "WARNING: This operation cannot be undone!" -Color $warningFg
Write-Host ""
$confirmation = Read-Host "  Type 'YES' (case-sensitive) to proceed with deletion or press Enter to cancel"

if ($confirmation -ne "YES") {
    Write-Host ""
    Write-ColorText "  Operation cancelled. No folders were deleted." -Color $warningFg
    Write-Host ""
    Write-Host "  Press Enter to exit..." -NoNewline
    Read-Host
    exit
}

# Proceed with deletion
Write-Host ""
Write-SubHeader "  DELETION PROCESS STARTED"

$totalFoldersToDelete = $foldersToProcess.Count
$foldersDeleted = 0
$foldersFailedToDelete = 0
$deletedPaths = @()
$failedPaths = @()

$folderIndex = 0
$foldersToProcess.GetEnumerator() | ForEach-Object {
    $folderPath = $_.Value
    $folderIndex++
    $percentComplete = [math]::Floor(($folderIndex / $totalFoldersToDelete) * 100)
    $folderName = Split-Path $folderPath -Leaf
    
    Show-EnhancedProgressBar -PercentComplete $percentComplete -Status "Processing: $folderName" -BarColor $normalFg
    
    # Visual delay for feedback
    Start-Sleep -Milliseconds 300
    
    try {
        # Show deleting animation
        for ($i = 0; $i -lt 5; $i++) {
            $spinChar = ("-", "\", "|", "/", "-")[$i % 5]
            Write-Host "`r  Deleting $spinChar $folderName" -ForegroundColor $subheaderFg -NoNewline
            Start-Sleep -Milliseconds 150
        }
        
        # Perform the deletion
        Remove-Item -Path $folderPath -Recurse -Force -ErrorAction Stop
        
        Write-Host "`r  Successfully deleted: " -NoNewline -ForegroundColor $normalFg
        Write-Host "$folderPath" -ForegroundColor $successFg
        $foldersDeleted++
        $deletedPaths += $folderPath
    }
    catch {
        Write-Host "`r  Failed to delete: " -NoNewline -ForegroundColor $normalFg
        Write-Host "$folderPath" -ForegroundColor $errorFg
        Write-Host "    Error: $($_.Exception.Message)" -ForegroundColor $errorFg
        $foldersFailedToDelete++
        $failedPaths += $folderPath
    }
}

# Calculate recovered space
$recoveredSize = 0
foreach ($path in $deletedPaths) {
    if ($folderSizes.ContainsKey($path)) {
        $recoveredSize += $folderSizes[$path]
    }
}

# Display summary results
Write-Host ""
Write-SubHeader "  OPERATION SUMMARY"

Write-Host "  Timestamp: " -NoNewline -ForegroundColor $normalFg
Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor $subheaderFg
Write-Host ""

Write-Host "  Total folders processed: " -NoNewline -ForegroundColor $normalFg
Write-Host "$totalFoldersToDelete" -ForegroundColor $subheaderFg

Write-Host "  Successfully deleted: " -NoNewline -ForegroundColor $normalFg
Write-Host "$foldersDeleted" -ForegroundColor $successFg

Write-Host "  Failed to delete: " -NoNewline -ForegroundColor $normalFg
if ($foldersFailedToDelete -gt 0) {
    Write-Host "$foldersFailedToDelete" -ForegroundColor $errorFg
} else {
    Write-Host "$foldersFailedToDelete" -ForegroundColor $successFg
}

Write-Host "  Approximate space recovered: " -NoNewline -ForegroundColor $normalFg
Write-Host "$(Format-FileSize $recoveredSize)" -ForegroundColor $successFg

Write-Host ""
Write-Separator
Write-ColorText "  Developed By: Waseem Ahmad Naeem (@WaseemAhmadNaeem)" -Color $highlightFg
Write-Separator
Write-Host ""

# Final message with typing effect
if ($hasColorSupport) {
    Write-TypeText "  Cleanup process completed successfully!" -Color $successFg -DelayMilliseconds 10
} else {
    Write-ColorText "  Cleanup process completed successfully!" -Color $successFg
}

Write-Host ""
Write-Host "  Press Enter to exit..." -NoNewline
Read-Host