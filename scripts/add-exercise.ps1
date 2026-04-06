param(
    [Parameter(Mandatory = $true)]
    [string]$Slug,

    [Parameter(Mandatory = $true)]
    [string]$Title,

    [Parameter(Mandatory = $true)]
    [string]$AssignedDate
)

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
$basePath = Join-Path $exercisesPath $Slug

if (Test-Path $basePath) {
    Write-Error "Exercise already exists: $Slug"
    exit 1
}

if (-not (Test-Path $exercisesPath)) {
    New-Item -ItemType Directory -Path $exercisesPath | Out-Null
}

$existingMetaFiles = Get-ChildItem -Path $exercisesPath -Recurse -Filter "meta.json" -File -ErrorAction SilentlyContinue

foreach ($metaFile in $existingMetaFiles) {
    $existingMeta = Get-Content $metaFile.FullName -Raw | ConvertFrom-Json

    if ($existingMeta.assignedDate -eq $AssignedDate) {
        Write-Error "AssignedDate '$AssignedDate' is already used by exercise '$($existingMeta.slug)'"
        exit 1
    }
}

$pascalParts = ($Slug -split '-') | ForEach-Object {
    if ($_.Length -gt 0) {
        $_.Substring(0, 1).ToUpper() + $_.Substring(1).ToLower()
    }
}

$pascal = $pascalParts -join ''

if ([string]::IsNullOrWhiteSpace($pascal)) {
    Write-Error "Could not build PascalCase name from slug '$Slug'"
    exit 1
}

New-Item -ItemType Directory -Path $basePath | Out-Null

$metaObject = [ordered]@{
    slug = $Slug
    title = $Title
    assignedDate = $AssignedDate
}

$metaObject | ConvertTo-Json -Depth 3 | Out-File (Join-Path $basePath "meta.json") -Encoding utf8

@"
# $Title

Write your solution here.
"@ | Out-File (Join-Path $basePath "instructions.md") -Encoding utf8

@"
public class $pascal
{
}
"@ | Out-File (Join-Path $basePath "$pascal.cs") -Encoding utf8

@"
using Xunit;

public class ${pascal}Tests
{
    [Fact]
    public void Test1()
    {
        Assert.True(true);
    }
}
"@ | Out-File (Join-Path $basePath "${pascal}Tests.cs") -Encoding utf8

& (Join-Path $PSScriptRoot "rebuild-config.ps1")

Write-Host "Exercise created: $Slug"