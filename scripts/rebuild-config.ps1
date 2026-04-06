$ErrorActionPreference = 'Stop'

function Format-Json {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Json
    )

    $node = [System.Text.Json.Nodes.JsonNode]::Parse($Json)
    return $node.ToJsonString([System.Text.Json.JsonSerializerOptions]@{
        WriteIndented = $true
    })
}

$rootPath = Split-Path -Parent $PSScriptRoot
$exercisesPath = Join-Path $rootPath "exercises"
$outputPath = Join-Path $rootPath "exercises.json"

if (-not (Test-Path $exercisesPath)) {
    Write-Error "Exercises directory not found: $exercisesPath"
    exit 1
}

$exerciseDirs = Get-ChildItem -Path $exercisesPath -Directory
$exercises = @()
$usedDates = @{}

foreach ($dir in $exerciseDirs) {
    $metaPath = Join-Path $dir.FullName "meta.json"

    if (-not (Test-Path $metaPath)) {
        continue
    }

    $meta = Get-Content $metaPath -Raw | ConvertFrom-Json

    if (-not $meta.slug) {
        Write-Error "Missing 'slug' in $metaPath"
        exit 1
    }

    if (-not $meta.title) {
        Write-Error "Missing 'title' in $metaPath"
        exit 1
    }

    if (-not $meta.assignedDate) {
        Write-Error "Missing 'assignedDate' in $metaPath"
        exit 1
    }

    $dateKey = [string]$meta.assignedDate

    if ($usedDates.ContainsKey($dateKey)) {
        Write-Error "Duplicate assignedDate '$dateKey' found in '$metaPath' and '$($usedDates[$dateKey])'"
        exit 1
    }

    $usedDates[$dateKey] = $metaPath

    $exercises += [ordered]@{
        slug = $meta.slug
        title = $meta.title
        assignedDate = $meta.assignedDate
    }
}

$sortedExercises = $exercises | Sort-Object assignedDate

$configObject = [ordered]@{
    exercises = $sortedExercises
}

$configObject | ConvertTo-Json -Depth 5 | Out-File $outputPath -Encoding utf8

Write-Host "exercises.json rebuilt"