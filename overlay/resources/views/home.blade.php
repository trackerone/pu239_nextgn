@extends('layouts.app')

@section('content')
  <h1>Pu-239 NextGen</h1>
  <p>Starter template is live and running on <strong>Render</strong>.</p>

  <div class="grid">
    <div>
      <h3>Status</h3>
      <p>Use <code>/status</code> to verify App, DB and migrations.</p>
      <p><a class="btn" href="/status">Open /status</a></p>
    </div>
    <div>
      <h3>Health</h3>
      <p>Use <code>/health</code> for uptime checks and load balancers.</p>
      <p><a class="btn alt" href="/health">Open /health</a></p>
    </div>
  </div>

  <hr style="margin:24px 0;border:0;border-top:1px solid rgba(148,163,184,.25)">

  <p>Next steps:</p>
  <ol>
    <li>Add your Pu-239 routes, controllers, and views into <code>overlay/</code>.</li>
    <li>Commit & push → Render auto-redeploys.</li>
    <li>Promote to a bigger instance when needed.</li>
  </ol>
@endsection
