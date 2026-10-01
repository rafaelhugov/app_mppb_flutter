$ErrorActionPreference = "Stop"

$env:PATH = "C:\Users\rafae\flutter\bin;C:\Users\rafae\AppData\Local\Android\Sdk\platform-tools;" + $env:PATH
$deviceId = "RX8RC09H70X"
$package = "br.mp.mppbapp.app.homolog"
$activity = "br.mp.mppbapp.app.MainActivity"
$component = "$package/$activity"

$rawDir = "C:\Users\rafae\projetosMPPB\app_mppb_flutter\qualidade\evidencias\Q8\raw"
if (!(Test-Path $rawDir)) { New-Item -Path $rawDir -ItemType Directory -Force | Out-Null }

Write-Host "=== 1. Medindo Cold Start (5 execuções) ==="
$coldTimes = @()
for ($i = 1; $i -le 5; $i++) {
    adb -s $deviceId shell am force-stop $package
    Start-Sleep -Seconds 2
    $out = adb -s $deviceId shell am start-activity -W -n $component
    $totalLine = $out | Select-String "TotalTime:\s*(\d+)"
    if ($totalLine -match "TotalTime:\s*(\d+)") {
        $ms = [int]$matches[1]
        $coldTimes += $ms
        Write-Host "Cold Start #$i : $ms ms"
    }
}
$coldSorted = $coldTimes | Sort-Object
$coldMedian = $coldSorted[[math]::Floor($coldSorted.Count / 2)]
Write-Host "Cold Start Mediana: $coldMedian ms"

Write-Host "`n=== 2. Medindo Warm Start (5 execuções) ==="
$warmTimes = @()
for ($i = 1; $i -le 5; $i++) {
    adb -s $deviceId shell input keyevent 3 # KEYCODE_HOME
    Start-Sleep -Seconds 2
    $out = adb -s $deviceId shell am start-activity -W -n $component
    $totalLine = $out | Select-String "TotalTime:\s*(\d+)"
    if ($totalLine -match "TotalTime:\s*(\d+)") {
        $ms = [int]$matches[1]
        $warmTimes += $ms
        Write-Host "Warm Start #$i : $ms ms"
    }
}
$warmSorted = $warmTimes | Sort-Object
$warmMedian = $warmSorted[[math]::Floor($warmSorted.Count / 2)]
Write-Host "Warm Start Mediana: $warmMedian ms"

Write-Host "`n=== 3. Medindo Memória Baseline ==="
Start-Sleep -Seconds 3
$memBaselineRaw = adb -s $deviceId shell dumpsys meminfo $package
$memBaselineRaw | Set-Content -Path "$rawDir\meminfo_baseline.txt"
$totalPssBaseline = 0
if ($memBaselineRaw -match "TOTAL PSS:\s*(\d+)") {
    $totalPssBaseline = [math]::Round([int]$matches[1] / 1024, 2)
}
Write-Host "Total PSS Baseline: $totalPssBaseline MB"

Write-Host "`n=== 4. Teste de Scroll e Frames (Gfxinfo) ==="
adb -s $deviceId shell dumpsys gfxinfo $package reset | Out-Null

# Executa interações de scroll na Home e lista de Notícias
for ($s = 0; $s -lt 8; $s++) {
    adb -s $deviceId shell input swipe 500 1500 500 600 200 # swipe up
    Start-Sleep -Milliseconds 400
    adb -s $deviceId shell input swipe 500 600 500 1500 200 # swipe down
    Start-Sleep -Milliseconds 400
}

$gfxRaw = adb -s $deviceId shell dumpsys gfxinfo $package
$gfxRaw | Set-Content -Path "$rawDir\gfxinfo_scroll.txt"

Write-Host "`n=== 5. Teste de Navegação Repetida (Ciclo Home -> Notícias -> Diário -> Home) ==="
for ($c = 1; $c -le 5; $c++) {
    Write-Host "Ciclo de navegacao #$c..."
    # Toque no card de Notícias (aprox x=300, y=1000 dependendo da resolução)
    adb -s $deviceId shell input tap 350 950
    Start-Sleep -Milliseconds 800
    adb -s $deviceId shell input keyevent 4 # BACK
    Start-Sleep -Milliseconds 500
    # Toque em outro item
    adb -s $deviceId shell input tap 750 950
    Start-Sleep -Milliseconds 800
    adb -s $deviceId shell input keyevent 4 # BACK
    Start-Sleep -Milliseconds 500
}

Write-Host "`n=== 6. Medindo Memória após Navegação Repetida ==="
Start-Sleep -Seconds 2
$memAfterNavRaw = adb -s $deviceId shell dumpsys meminfo $package
$memAfterNavRaw | Set-Content -Path "$rawDir\meminfo_after_nav.txt"
$totalPssAfterNav = 0
if ($memAfterNavRaw -match "TOTAL PSS:\s*(\d+)") {
    $totalPssAfterNav = [math]::Round([int]$matches[1] / 1024, 2)
}
Write-Host "Total PSS após Navegação: $totalPssAfterNav MB"

# Coleta uso de CPU do processo
$cpuInfo = adb -s $deviceId shell top -b -n 1 | Select-String "mppbapp"
Write-Host "CPU Info: $cpuInfo"

# Consolida resultados Flutter em JSON
$results = @{
    deviceId = $deviceId
    model = "Samsung Galaxy A52 (SM-A525M)"
    androidVersion = "14 (API 34)"
    package = $package
    coldStartMs = $coldTimes
    coldStartMedianMs = $coldMedian
    warmStartMs = $warmTimes
    warmStartMedianMs = $warmMedian
    memBaselineMb = $totalPssBaseline
    memAfterNavMb = $totalPssAfterNav
    cpuSnapshot = "$cpuInfo"
}
$results | ConvertTo-Json -Depth 3 | Set-Content -Path "$rawDir\flutter_perf_summary.json"

Write-Host "`n=== Benchmarks Flutter concluídos com sucesso! ==="
