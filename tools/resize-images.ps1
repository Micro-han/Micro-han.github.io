# Downsamples the site's figures to web-friendly JPEGs using only .NET's built-in
# imaging, so the repo needs no Node/Python toolchain. Originals stay recoverable
# through git history.
param(
  [int]$MaxWidth = 640,
  [int]$Quality = 80,
  # Substring filter on the output path, so a single figure can be redone
  # without recompressing the ones already processed in place.
  [string]$Only = ''
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

$jobs = @(
  @{ Src = 'papers/ALOE_arXiv2026/aloe.png';            Dst = 'papers/ALOE_arXiv2026/aloe.jpg' }
  @{ Src = 'papers/HOLO_WACV2026/holo.jpeg';            Dst = 'papers/HOLO_WACV2026/holo.jpeg' }
  @{ Src = 'papers/SGGS_ICASSP2025/sggs1.png';          Dst = 'papers/SGGS_ICASSP2025/sggs1.jpg' }
  @{ Src = 'papers/AttenPoint_PRCV2024/PRCV.png';       Dst = 'papers/AttenPoint_PRCV2024/PRCV.jpg' }
  @{ Src = 'papers/GreedyAgent_ICIC2024/ICIC.jpg';      Dst = 'papers/GreedyAgent_ICIC2024/ICIC.jpg' }
  @{ Src = 'papers/ASG_MICCAI2024/ASGMVLP.jpg';         Dst = 'papers/ASG_MICCAI2024/ASGMVLP.jpg' }
  @{ Src = 'projects/LLM_Kaggle2023/kaggleLLAM.jpg';    Dst = 'projects/LLM_Kaggle2023/kaggleLLAM.jpg' }
  @{ Src = 'projects/eScape_GameJam2023/eScape.png';    Dst = 'projects/eScape_GameJam2023/eScape.jpg' }
  @{ Src = 'assets/images/microhan.png';                Dst = 'assets/images/avatar-320.jpg'; MaxWidth = 320; Quality = 85; Square = $true }
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

foreach ($job in $jobs) {
  if ($Only -and $job.Dst -notlike "*$Only*") { continue }

  $src = Join-Path $root $job.Src
  $dst = Join-Path $root $job.Dst
  $maxW = if ($job.ContainsKey('MaxWidth')) { $job.MaxWidth } else { $MaxWidth }
  $q = if ($job.ContainsKey('Quality')) { $job.Quality } else { $Quality }
  $square = $job.ContainsKey('Square') -and $job.Square

  $before = [math]::Round((Get-Item $src).Length / 1KB)
  $dim = Convert-One $src $dst $maxW $q $square
  $after = [math]::Round((Get-Item $dst).Length / 1KB)

  "{0,-46} {1,5} KB -> {2,4} KB   {3}x{4}" -f $job.Dst, $before, $after, $dim.Width, $dim.Height
}
