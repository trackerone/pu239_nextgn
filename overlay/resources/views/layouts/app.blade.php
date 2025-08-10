<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>{{ config('app.name', 'Pu-239 NextGen') }}</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="color-scheme" content="dark light">
  <style>
    :root { --bg:#0b0f14; --fg:#e6edf3; --muted:#9aa4ad; --card:#111720; --accent:#4aa3ff; }
    @media (prefers-color-scheme: light) {
      :root { --bg:#f6f8fa; --fg:#0b0f14; --muted:#5e6a75; --card:#ffffff; --accent:#2563eb; }
    }
    *{box-sizing:border-box} body{margin:0;background:var(--bg);color:var(--fg);font-family:ui-sans-serif,system-ui,-apple-system,Segoe UI,Roboto,Inter,Arial}
    .wrap{max-width:960px;margin:0 auto;padding:32px}
    .card{background:var(--card);border-radius:16px;padding:28px;box-shadow:0 8px 24px rgba(0,0,0,.25)}
    h1{margin:0 0 8px;font-size:28px}
    p{color:var(--muted);line-height:1.6}
    .grid{display:grid;gap:16px;grid-template-columns:repeat(auto-fit,minmax(260px,1fr));margin-top:20px}
    .btn{display:inline-block;padding:10px 14px;border-radius:12px;border:1px solid transparent;background:var(--accent);color:white;text-decoration:none;font-weight:600}
    .btn.alt{background:transparent;border-color:var(--accent);color:var(--accent)}
    code{background:rgba(148,163,184,.15);padding:2px 6px;border-radius:6px}
    footer{margin-top:28px;color:var(--muted);font-size:14px}
  </style>
</head>
<body>
  <div class="wrap">
    <div class="card">
      @yield('content')
    </div>
    <footer>
      <div>Pu-239 NextGen • Laravel • Docker • Render</div>
    </footer>
  </div>
</body>
</html>
