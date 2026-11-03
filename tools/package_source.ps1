param([string]$OutputPath = (Join-Path $PSScriptRoot '..\..\submission\QE190009.zip'))
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$sourceRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$absoluteOutput = [System.IO.Path]::GetFullPath($OutputPath)
New-Item -ItemType Directory -Path ([System.IO.Path]::GetDirectoryName($absoluteOutput)) -Force | Out-Null
$entries = @('lib', 'android', 'assets', 'test', 'integration_test', 'test_driver', 'tools',
  'pubspec.yaml', 'pubspec.lock', 'analysis_options.yaml', 'firestore.rules', 'firebase.json',
  'firestore.indexes.json', '.firebaserc', '.gitignore', '.metadata', 'README.md', 'VERIFICATION.md')
$outputStream = [System.IO.File]::Open($absoluteOutput, [System.IO.FileMode]::Create)
$archive = New-Object System.IO.Compression.ZipArchive($outputStream, [System.IO.Compression.ZipArchiveMode]::Create, $false)
try {
  foreach ($entry in $entries) {
    $entryPath = Join-Path $sourceRoot $entry
    if (!(Test-Path -LiteralPath $entryPath)) { continue }
    $entryItem = Get-Item -LiteralPath $entryPath -Force
    $files = if ($entry -eq 'tools') { Get-ChildItem -LiteralPath $entryPath -File -Force }
      elseif ($entryItem.PSIsContainer) { Get-ChildItem -LiteralPath $entryPath -File -Recurse -Force }
      else { @($entryItem) }
    foreach ($file in $files) {
      $relative = $file.FullName.Substring($sourceRoot.Length + 1).Replace('\', '/')
      if ($relative -match '(^|/)(build|\.dart_tool|\.git|\.gradle|\.kotlin|node_modules|\.idea)(/|$)') { continue }
      if ($file.Name -in @('local.properties', 'GeneratedPluginRegistrant.java') -or $file.Extension -eq '.log') { continue }
      [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($archive, $file.FullName, $relative, [System.IO.Compression.CompressionLevel]::Optimal) | Out-Null
    }
  }
} finally { $archive.Dispose(); $outputStream.Dispose() }
$check = [System.IO.Compression.ZipFile]::OpenRead($absoluteOutput)
try {
  if (!($check.Entries.FullName -contains 'pubspec.yaml')) { throw 'pubspec.yaml is not at zip root' }
  if ($check.Entries.FullName -match '(^|/)(build|\.dart_tool|\.git|\.gradle|node_modules)(/|$)') { throw 'Cache found in source archive' }
  Write-Output ('Source packaged: ' + $absoluteOutput + ' (' + $check.Entries.Count + ' files)')
} finally { $check.Dispose() }
