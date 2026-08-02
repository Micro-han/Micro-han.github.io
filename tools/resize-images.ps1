# Builds the two JPEG sizes each figure needs, using only .NET's built-in
# imaging so the repo needs no Node/Python toolchain.
#
#   <name>-full.jpg   up to 1280px wide, quality 82 — what the lightbox opens
#   <name>.jpg        up to  640px wide, quality 80 — the list thumbnail
#
# The -full.jpg is the archived source: thumbnails are always derived from it,
# so a rerun never recompresses a thumbnail against itself. Publisher-resolution
# originals are not kept in the repo; drop one next to the `Orig` path below to
# regenerate a -full.jpg from scratch.
#
# Usage:
#   .\tools\resize-images.ps1              # rebuild every thumbnail
#   .\tools\resize-images.ps1 -Only vine   # just the figures matching "vine"
param(
  [int]$FullWidth = 1280,
  [int]$FullQuality = 82,
  [int]$ThumbWidth = 640,
  [int]$ThumbQuality = 80,
  # Substring filter on the output paths.
  [string]$Only = ''
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

# `Orig` is optional and normally absent; `Full` doubles as the archived source.
$figures = @(
  @{ Orig = '.brainstorm/orig/vine_overview.png'; Full = 'papers/VINE_arXiv2026/vine-full.jpg';        Thumb = 'papers/VINE_arXiv2026/vine.jpg' }
  @{ Orig = '.brainstorm/orig/aloe.png';          Full = 'papers/ALOE_arXiv2026/aloe-full.jpg';        Thumb = 'papers/ALOE_arXiv2026/aloe.jpg' }
  @{ Orig = '.brainstorm/orig/holo.jpeg';         Full = 'papers/HOLO_WACV2026/holo-full.jpg';         Thumb = 'papers/HOLO_WACV2026/holo.jpg' }
  @{ Orig = '.brainstorm/orig/sggs1.png';         Full = 'papers/SGGS_ICASSP2025/sggs1-full.jpg';      Thumb = 'papers/SGGS_ICASSP2025/sggs1.jpg' }
  @{ Orig = '.brainstorm/orig/PRCV.png';          Full = 'papers/AttenPoint_PRCV2024/PRCV-full.jpg';   Thumb = 'papers/AttenPoint_PRCV2024/PRCV.jpg' }
  @{ Orig = '.brainstorm/orig/ICIC.jpg';          Full = 'papers/GreedyAgent_ICIC2024/ICIC-full.jpg';  Thumb = 'papers/GreedyAgent_ICIC2024/ICIC.jpg' }
  @{ Orig = '.brainstorm/orig/ASGMVLP.jpg';       Full = 'papers/ASG_MICCAI2024/ASGMVLP-full.jpg';     Thumb = 'papers/ASG_MICCAI2024/ASGMVLP.jpg' }
  @{ Orig = '.brainstorm/orig/kaggleLLAM.jpg';    Full = 'projects/LLM_Kaggle2023/kaggleLLAM-full.jpg'; Thumb = 'projects/LLM_Kaggle2023/kaggleLLAM.jpg' }
  @{ Orig = '.brainstorm/orig/eScape.png';        Full = 'projects/eScape_GameJam2023/eScape-full.jpg'; Thumb = 'projects/eScape_GameJam2023/eScape.jpg' }
  # The avatar is square-cropped and needs no lightbox size.
  @{ Orig = 'assets/images/microhan.png'; Full = ''; Thumb = 'assets/images/avatar-320.jpg'; ThumbWidth = 320; ThumbQuality = 85; Square = $true }
)

$codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
         Where-Object { $_.MimeType -eq 'image/jpeg' }

function Convert-One($srcPath, $dstPath, $maxW, $q, $square) {
  # Load through a memory stream so the source file stays unlocked and can be
  # overwritten in place.
  $bytes = [System.IO.File]::ReadAllBytes($srcPath)
  $stream = New-Object System.IO.MemoryStream($bytes, $false)
  $img = [System.Drawing.Image]::FromStream($stream)
  try {
    # Source rectangle: the whole image, or a centred square crop.
    $sx = 0; $sy = 0; $sw = $img.Width; $sh = $img.Height
    if ($square) {
      $side = [math]::Min($img.Width, $img.Height)
      $sx = [int](($img.Width - $side) / 2)
      $sy = [int](($img.Height - $side) / 2)
      $sw = $side; $sh = $side
    }

    $w = $sw; $h = $sh
    if ($w -gt $maxW) {
      $h = [int][math]::Round($h * ($maxW / $w))
      $w = $maxW
    }

    $bmp = New-Object System.Drawing.Bitmap $w, $h
    try {
      $g = [System.Drawing.Graphics]::FromImage($bmp)
      try {
        $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
        # Flatten transparency onto white; JPEG has no alpha channel.
        $g.Clear([System.Drawing.Color]::White)
        $destRect = New-Object System.Drawing.Rectangle 0, 0, $w, $h
        $g.DrawImage($img, $destRect, $sx, $sy, $sw, $sh, [System.Drawing.GraphicsUnit]::Pixel)
      } finally { $g.Dispose() }

      $params = New-Object System.Drawing.Imaging.EncoderParameters 1
      $params.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter(
        [System.Drawing.Imaging.Encoder]::Quality, [int]$q)

      $tmp = "$dstPath.tmp"
      $bmp.Save($tmp, $codec, $params)
      $params.Dispose()
      Move-Item -Force $tmp $dstPath
    } finally { $bmp.Dispose() }

    return @{ Width = $w; Height = $h }
  } finally { $img.Dispose(); $stream.Dispose() }
}

function Report($label, $srcPath, $dstPath, $dim) {
  $before = [math]::Round((Get-Item $srcPath).Length / 1KB)
  $after = [math]::Round((Get-Item $dstPath).Length / 1KB)
  "{0,-52} {1,5} KB -> {2,4} KB   {3}x{4}" -f $label, $before, $after, $dim.Width, $dim.Height
}

foreach ($fig in $figures) {
  if ($Only -and "$($fig.Full) $($fig.Thumb)" -notlike "*$Only*") { continue }

  $square = $fig.ContainsKey('Square') -and $fig.Square

  # Rebuild the archived -full.jpg only when a higher-resolution original is present.
  if ($fig.Full) {
    $orig = Join-Path $root $fig.Orig
    $full = Join-Path $root $fig.Full
    if (Test-Path $orig) {
      $dim = Convert-One $orig $full $FullWidth $FullQuality $false
      Report $fig.Full $orig $full $dim
    } elseif (-not (Test-Path $full)) {
      "{0,-52} no original and no -full.jpg, skipped" -f $fig.Full
      continue
    }
    $thumbSrc = $full
  } else {
    $thumbSrc = Join-Path $root $fig.Orig
    if (-not (Test-Path $thumbSrc)) {
      "{0,-52} source missing, skipped" -f $fig.Thumb
      continue
    }
  }

  $tw = if ($fig.ContainsKey('ThumbWidth')) { $fig.ThumbWidth } else { $ThumbWidth }
  $tq = if ($fig.ContainsKey('ThumbQuality')) { $fig.ThumbQuality } else { $ThumbQuality }

  $thumb = Join-Path $root $fig.Thumb
  $dim = Convert-One $thumbSrc $thumb $tw $tq $square
  Report $fig.Thumb $thumbSrc $thumb $dim
}
