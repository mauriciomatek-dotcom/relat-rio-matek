$ErrorActionPreference = "Stop"
$port = 8765
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()
Start-Process "http://localhost:$port/index.html"
Write-Host "Matek Relatorio de Visita em execucao."
Write-Host "Feche esta janela para encerrar o aplicativo."
while ($listener.IsListening) {
  $ctx = $listener.GetContext()
  $rel = $ctx.Request.Url.AbsolutePath.TrimStart('/')
  if ([string]::IsNullOrWhiteSpace($rel)) { $rel = 'index.html' }
  $file = Join-Path $root $rel
  if (Test-Path $file -PathType Leaf) {
    $bytes = [IO.File]::ReadAllBytes($file)
    switch ([IO.Path]::GetExtension($file).ToLower()) {
      '.html' { $ctx.Response.ContentType='text/html; charset=utf-8' }
      '.js' { $ctx.Response.ContentType='application/javascript; charset=utf-8' }
      '.webmanifest' { $ctx.Response.ContentType='application/manifest+json; charset=utf-8' }
      '.svg' { $ctx.Response.ContentType='image/svg+xml' }
      default { $ctx.Response.ContentType='application/octet-stream' }
    }
    $ctx.Response.OutputStream.Write($bytes,0,$bytes.Length)
  } else {
    $ctx.Response.StatusCode=404
  }
  $ctx.Response.Close()
}
