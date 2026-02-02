# Auto Commit Script - Commit setiap file yang berubah secara terpisah
# Jalankan: .\auto_commit.ps1

# Pindah ke direktori project
Set-Location -Path $PSScriptRoot

Write-Host "[INFO] Memeriksa perubahan di repository..." -ForegroundColor Cyan

# Ambil daftar file yang dimodifikasi (tracked)
$modifiedFiles = git diff --name-only
# Ambil daftar file baru (untracked)
$untrackedFiles = git ls-files --others --exclude-standard

# Commit file yang dimodifikasi
if ($modifiedFiles) {
    Write-Host ""
    Write-Host "[MODIFIED] File yang dimodifikasi:" -ForegroundColor Yellow
    foreach ($file in $modifiedFiles) {
        Write-Host "  - $file" -ForegroundColor Gray
        
        # Stage file
        git add $file
        
        # Buat commit message berdasarkan nama file
        $fileName = Split-Path $file -Leaf
        $parentPath = Split-Path $file -Parent
        if ($parentPath) {
            $folderName = Split-Path $parentPath -Leaf
            $commitMessage = "Update $fileName di $folderName"
        } else {
            $commitMessage = "Update $fileName"
        }
        
        # Commit
        git commit -m $commitMessage
        
        Write-Host "  [OK] Committed: $commitMessage" -ForegroundColor Green
    }
}

# Commit file baru (untracked)
if ($untrackedFiles) {
    Write-Host ""
    Write-Host "[NEW] File baru:" -ForegroundColor Yellow
    foreach ($file in $untrackedFiles) {
        Write-Host "  - $file" -ForegroundColor Gray
        
        # Stage file
        git add $file
        
        # Buat commit message berdasarkan nama file
        $fileName = Split-Path $file -Leaf
        $parentPath = Split-Path $file -Parent
        if ($parentPath) {
            $folderName = Split-Path $parentPath -Leaf
            $commitMessage = "Tambah $fileName di $folderName"
        } else {
            $commitMessage = "Tambah $fileName"
        }
        
        # Commit
        git commit -m $commitMessage
        
        Write-Host "  [OK] Committed: $commitMessage" -ForegroundColor Green
    }
}

if (-not $modifiedFiles -and -not $untrackedFiles) {
    Write-Host "[INFO] Tidak ada perubahan yang perlu di-commit!" -ForegroundColor Green
}

Write-Host ""
Write-Host "[DONE] Selesai!" -ForegroundColor Cyan

# Tampilkan log commit terbaru
Write-Host ""
Write-Host "[LOG] Commit terbaru:" -ForegroundColor Yellow
git log --oneline -10
