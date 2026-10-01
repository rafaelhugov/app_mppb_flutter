$ErrorActionPreference = "Stop"

$env:PATH = "C:\Users\rafae\AppData\Local\Android\Sdk\platform-tools;" + $env:PATH
$deviceId = "RX8RC09H70X"
$package = "br.mp.mppbapp.app.homolog"
$activity = "br.mp.mppbapp.app.MainActivity"
$component = "$package/$activity"

$rawDir = "C:\Users\rafae\projetosMPPB\app_mppb_flutter\qualidade\evidencias\Q8\raw"
if (!(Test-Path $rawDir)) { New-Item -Path $rawDir -ItemType Directory -Force | Out-Null }

function Get-TotalPss([string[]]$rawLines) {
    $linha = $rawLines | Select-String -Pattern 'TOTAL PSS:\s*(\d+)' | Select-Object -First 1
    if ($linha -and $linha.Line -match 'TOTAL PSS:\s*(\d+)') {
        $val = [math]::Round(([double]$Matches[1]) / 1024, 2)
        if ($val -le 50) {
            throw "Valor invalido de TOTAL PSS: $val MB (esperado > 50 MB)"
        }
        return $val
    }
    throw "TOTAL PSS nao encontrado no dump meminfo"
}

# 1. COLD START (5 amostras válidas > 0)
Write-Host "=== 1. Medindo Cold Start em PROFILE (5 amostras validas > 0) ==="
$coldTimes = @()
$attempt = 0
while ($coldTimes.Count -lt 5 -and $attempt -lt 15) {
    $attempt++
    adb -s $deviceId shell am force-stop $package
    Start-Sleep -Seconds 3
    $out = adb -s $deviceId shell am start-activity -W -n $component
    $totalLine = $out | Select-String "TotalTime:\s*(\d+)"
    if ($totalLine -and $totalLine.Line -match "TotalTime:\s*(\d+)") {
        $ms = [int]$Matches[1]
        if ($ms -gt 0) {
            $coldTimes += $ms
            Write-Host "Cold Start valido #$($coldTimes.Count): $ms ms"
        } else {
            Write-Host "Tentativa #$attempt retornou 0 ms (invalido, descartado)"
        }
    }
}
$coldSorted = $coldTimes | Sort-Object
$coldMedian = $coldSorted[[math]::Floor($coldSorted.Count / 2)]
Write-Host "Cold Start Mediana: $coldMedian ms"

# 2. WARM START (5 amostras válidas > 0)
Write-Host "`n=== 2. Medindo Warm Start em PROFILE (5 amostras validas) ==="
$warmTimes = @()
$wAttempt = 0
while ($warmTimes.Count -lt 5 -and $wAttempt -lt 15) {
    $wAttempt++
    adb -s $deviceId shell input keyevent 3 # HOME
    Start-Sleep -Seconds 2
    $out = adb -s $deviceId shell am start-activity -W -n $component
    $totalLine = $out | Select-String "TotalTime:\s*(\d+)"
    if ($totalLine -and $totalLine.Line -match "TotalTime:\s*(\d+)") {
        $ms = [int]$Matches[1]
        if ($ms -gt 0) {
            $warmTimes += $ms
            Write-Host "Warm Start valido #$($warmTimes.Count): $ms ms"
        }
    }
}
$warmSorted = $warmTimes | Sort-Object
$warmMedian = $warmSorted[[math]::Floor($warmSorted.Count / 2)]
Write-Host "Warm Start Mediana: $warmMedian ms"

# Assegura que o app está ativo na Home
adb -s $deviceId shell am start -n $component
Start-Sleep -Seconds 4

# CPU SAMPLE: IDLE
$cpuIdle1 = adb -s $deviceId shell "top -b -n 1 | grep mppbapp"
Write-Host "`nCPU Idle Inicial: $cpuIdle1"

# M0: Home estabilizada
Write-Host "`n=== 3. Coleta Temporal de Memoria M0 (Home Estabilizada) ==="
$m0Raw = adb -s $deviceId shell dumpsys meminfo $package
$m0Raw | Set-Content -Path "$rawDir\meminfo_M0_baseline.txt"
$m0Pss = Get-TotalPss $m0Raw
Write-Host "M0 (Home Baseline): $m0Pss MB"

# Função de Ciclo de Navegação
function Invoke-NavCycle {
    # Toque no card de Notícias (aprox x=350, y=950)
    adb -s $deviceId shell input tap 350 950
    Start-Sleep -Milliseconds 700
    # Swipe contínuo em Notícias
    adb -s $deviceId shell input swipe 500 1500 500 700 200
    Start-Sleep -Milliseconds 400
    # Retorno
    adb -s $deviceId shell input keyevent 4 # KEYCODE_BACK
    Start-Sleep -Milliseconds 600
    # Toque em Diário Oficial (aprox x=750, y=950)
    adb -s $deviceId shell input tap 750 950
    Start-Sleep -Milliseconds 700
    # Retorno
    adb -s $deviceId shell input keyevent 4
    Start-Sleep -Milliseconds 600
}

# CPU DURING SCROLL
Write-Host "`n=== Executando Scrolls e Coletando CPU de Scroll ==="
$cpuScrollSamples = @()
for ($s = 1; $s -le 4; $s++) {
    adb -s $deviceId shell input swipe 500 1600 500 700 200
    Start-Sleep -Milliseconds 300
    $sample = adb -s $deviceId shell "top -b -n 1 | grep mppbapp"
    $cpuScrollSamples += $sample
    adb -s $deviceId shell input swipe 500 700 500 1600 200
    Start-Sleep -Milliseconds 300
}
Write-Host "CPU Scroll: $($cpuScrollSamples -join '; ')"

# M1: Após 5 ciclos
Write-Host "`n=== Executando Ciclos 1 a 5 ==="
for ($c = 1; $c -le 5; $c++) { Invoke-NavCycle }
$m1Raw = adb -s $deviceId shell dumpsys meminfo $package
$m1Raw | Set-Content -Path "$rawDir\meminfo_M1_5ciclos.txt"
$m1Pss = Get-TotalPss $m1Raw
Write-Host "M1 (Apos 5 ciclos): $m1Pss MB"

# CPU DURING NAVIGATION
$cpuNavSample = adb -s $deviceId shell "top -b -n 1 | grep mppbapp"
Write-Host "CPU Navegacao: $cpuNavSample"

# M2: Após 10 ciclos
Write-Host "`n=== Executando Ciclos 6 a 10 ==="
for ($c = 6; $c -le 10; $c++) { Invoke-NavCycle }
$m2Raw = adb -s $deviceId shell dumpsys meminfo $package
$m2Raw | Set-Content -Path "$rawDir\meminfo_M2_10ciclos.txt"
$m2Pss = Get-TotalPss $m2Raw
Write-Host "M2 (Apos 10 ciclos): $m2Pss MB"

# M3: Após 15 ciclos
Write-Host "`n=== Executando Ciclos 11 a 15 ==="
for ($c = 11; $c -le 15; $c++) { Invoke-NavCycle }
$m3Raw = adb -s $deviceId shell dumpsys meminfo $package
$m3Raw | Set-Content -Path "$rawDir\meminfo_M3_15ciclos.txt"
$m3Pss = Get-TotalPss $m3Raw
Write-Host "M3 (Apos 15 ciclos): $m3Pss MB"

# M4: Retorno à Home + período curto de idle (8 segundos)
Write-Host "`n=== Retorno a Home e Idle (8s) para M4 ==="
adb -s $deviceId shell am start -n $component
Start-Sleep -Seconds 8
$m4Raw = adb -s $deviceId shell dumpsys meminfo $package
$m4Raw | Set-Content -Path "$rawDir\meminfo_M4_idle.txt"
$m4Pss = Get-TotalPss $m4Raw
Write-Host "M4 (Home pós-idle): $m4Pss MB"

# CPU AFTER IDLE
$cpuIdleAfter = adb -s $deviceId shell "top -b -n 1 | grep mppbapp"
Write-Host "CPU Idle Final: $cpuIdleAfter"

# Ler frame timings gravados do sandbox do aplicativo
Write-Host "`n=== 4. Lendo Frame Timings Gravados do Dispositivo ==="
$frameTimingsJson = adb -s $deviceId shell "run-as $package cat files/q8_frame_timing.json"
$frameTimingsJson | Set-Content -Path "$rawDir\q8_frame_timing_raw.json"

# Processa métricas dos frames se existirem
$framesAnalyzed = 0
$jank60Count = 0
$jank90Count = 0
$buildTimes = @()
$rasterTimes = @()

if ($frameTimingsJson -and $frameTimingsJson.Trim().StartsWith("[")) {
    $parsedFrames = $frameTimingsJson | ConvertFrom-Json
    $framesAnalyzed = $parsedFrames.Count
    foreach ($f in $parsedFrames) {
        $buildTimes += [double]$f.buildMs
        $rasterTimes += [double]$f.rasterMs
        if ($f.buildMs -gt 16.666 -or $f.rasterMs -gt 16.666) { $jank60Count++ }
        if ($f.buildMs -gt 11.111 -or $f.rasterMs -gt 11.111) { $jank90Count++ }
    }
}
Write-Host "Total de Frames Analisados: $framesAnalyzed"

# Consolida resultados Flutter em JSON
$results = [ordered]@{
    deviceId = $deviceId
    model = "Samsung Galaxy A52 (SM-A525M)"
    androidVersion = "14 (API 34)"
    package = $package
    buildMode = "PROFILE"
    apiUrl = "https://aplicativo-mppb-homolog.mppb.mp.br"
    coldStartMs = $coldTimes
    coldStartMedianMs = $coldMedian
    warmStartMs = $warmTimes
    warmStartMedianMs = $warmMedian
    temporalMemory = [ordered]@{
        M0_baselineMb = $m0Pss
        M1_5ciclosMb = $m1Pss
        M2_10ciclosMb = $m2Pss
        M3_15ciclosMb = $m3Pss
        M4_idleMb = $m4Pss
        deltaTotalMb = [math]::Round($m4Pss - $m0Pss, 2)
        trend = if ($m4Pss -le $m3Pss) { "ESTABILIZADO / SEM TENDENCIA LINEAR DE LEAK" } else { "CRESCIMENTO CONTINUO" }
    }
    cpuSeries = [ordered]@{
        idleInicial = "$cpuIdle1"
        scrollSamples = $cpuScrollSamples
        navegacao = "$cpuNavSample"
        idleFinal = "$cpuIdleAfter"
    }
    frameTiming = [ordered]@{
        totalFrames = $framesAnalyzed
        jank60Frames = $jank60Count
        jank60Percent = if ($framesAnalyzed -gt 0) { [math]::Round(($jank60Count / $framesAnalyzed) * 100, 2) } else { 0 }
        jank90Frames = $jank90Count
        jank90Percent = if ($framesAnalyzed -gt 0) { [math]::Round(($jank90Count / $framesAnalyzed) * 100, 2) } else { 0 }
    }
}

$results | ConvertTo-Json -Depth 5 | Set-Content -Path "$rawDir\flutter_perf_summary_q8_r01.json"
Write-Host "`n=== Benchmarks Flutter Q8-R01 concluídos com sucesso! ==="
