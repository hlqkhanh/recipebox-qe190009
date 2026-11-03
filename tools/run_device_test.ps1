param(
  [string]$TestEmail = $env:RECIPEBOX_TEST_EMAIL,
  [string]$TestPassword = $env:RECIPEBOX_TEST_PASSWORD,
  [string]$Device = 'emulator-5554'
)
$ErrorActionPreference = 'Continue'
if (!$TestEmail -or !$TestPassword) { throw 'Supply -TestEmail and -TestPassword or RECIPEBOX_TEST_EMAIL / RECIPEBOX_TEST_PASSWORD.' }
$sourceRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
Set-Location -LiteralPath $sourceRoot
$adb = Join-Path $env:ANDROID_HOME 'platform-tools\adb.exe'
$flutter = 'C:\src\flutter\bin\flutter.bat'
$screenshots = Join-Path $sourceRoot 'artifacts\screenshots'
New-Item -ItemType Directory -Path $screenshots -Force | Out-Null
$logPath = Join-Path $sourceRoot 'artifacts-integration.log'
Set-Content -LiteralPath $logPath -Value ''
# Pass values through JSON: flutter.bat/cmd can otherwise strip exclamation marks.
$definesPath = Join-Path $sourceRoot 'artifacts\device-test-defines.json'
$definesJson = @{ TEST_EMAIL = $TestEmail; TEST_PASSWORD = $TestPassword } | ConvertTo-Json
[System.IO.File]::WriteAllText($definesPath, $definesJson, (New-Object System.Text.UTF8Encoding $false))
& $flutter drive --no-enable-impeller --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart -d $Device '--dart-define-from-file=artifacts/device-test-defines.json' 2>&1 | ForEach-Object {
  $line = [string]$_
  Add-Content -LiteralPath $logPath -Value $line
  if ($line -match 'RECIPEBOX_SCREENSHOT:([a-zA-Z0-9_]+)') {
    $imageName = $Matches[1]
    & $adb -s $Device shell screencap -p /sdcard/recipebox_capture.png | Out-Null
    & $adb -s $Device pull /sdcard/recipebox_capture.png (Join-Path $screenshots ($imageName + '.png')) 2>&1 | Out-Null
    Write-Output ('Captured ' + $imageName)
  } elseif ($line -match 'I/flutter.*\d+:\d+|Exception|Test failed|All tests passed|Some tests failed|Failure Details|Timed out') {
    Write-Output $line
  }
}
$driveExit = $LASTEXITCODE
Get-Content -LiteralPath $logPath -Tail 20
exit $driveExit
