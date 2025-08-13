<?php

namespace App\Http\Controllers;

use App\Services\Bencode;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Config;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class TrackerController extends Controller
{
    public function announce(Request $r)
    {
        // External mode: bounce to external tracker (HTTP redirect) or hint (UDP)
        if (Config::get('tracker.mode') === 'external') {
            $url = Config::get('tracker.external_announce');
            if (!$url) {
                return response('tracker misconfigured', 500);
            }
            if (Str::startsWith($url, ['http://', 'https://'])) {
                return redirect()->away($url);
            }
            return $this->bencode([
                'failure reason' => 'use external tracker',
                'announce'       => $url,
            ]);
        }

        // --- Embedded mode (handle announce locally) ---
        $infoHash = $this->rawBin($r->query('info_hash', ''));
        $peerId   = $this->rawBin($r->query('peer_id', ''));
        $port     = (int) $r->query('port', 0);

        if (strlen($infoHash) !== 20 || strlen($peerId) !== 20 || $port <= 0) {
            return $this->bencode(['failure reason' => 'invalid parameters']);
        }

        $uploaded   = (int) $r->query('uploaded', 0);
        $downloaded = (int) $r->query('downloaded', 0);
        $left       = (int) $r->query('left', 0);
        $event      = (string) $r->query('event', '');
        $compact    = (int) $r->query('compact', 1);
        $ipParam    = $r->query('ip');

        $ip = filter_var($ipParam, FILTER_VALIDATE_IP) ?: $r->ip();
        $now = now();

        $hexInfo = bin2hex($infoHash);
        $hexPeer = bin2hex($peerId);

        DB::table('peers')->upsert([
            'info_hash'      => $hexInfo,
            'peer_id'        => $hexPeer,
            'ip'             => $ip,
            'port'           => $port,
            'uploaded'       => $uploaded,
            'downloaded'     => $downloaded,
            'left_bytes'     => $left,
            'last_announce'  => $now,
            'event'          => $event,
        ], ['info_hash', 'peer_id'], [
            'ip','port','uploaded','downloaded','left_bytes','last_announce','event'
        ]);

        DB::table('peers')->where('last_announce', '<', $now->copy()->subMinutes(45))->delete();

        if ($event === 'stopped') {
            DB::table('peers')->where([
                'info_hash' => $hexInfo,
                'peer_id'   => $hexPeer,
            ])->delete();

            return $this->bencode([
                'interval'   => 1800,
                'complete'   => 0,
                'incomplete' => 0,
                'peers'      => $compact ? '' : [],
            ]);
        }

        $rows = DB::table('peers')
            ->select('ip','port','peer_id','left_bytes')
            ->where('info_hash', $hexInfo)
            ->where('peer_id', '!=', $hexPeer)
            ->limit(50)
            ->get();

        $interval   = 1800;
        $incomplete = DB::table('peers')->where('info_hash', $hexInfo)->where('left_bytes', '>', 0)->count();
        $complete   = DB::table('peers')->where('info_hash', $hexInfo)->where('left_bytes', '=', 0)->count();

        $resp = [
            'interval'   => $interval,
            'complete'   => $complete,
            'incomplete' => $incomplete,
        ];

        if ($compact === 1) {
            $bin = '';
            for ($i=0; $i<count($rows); $i++) {
                $row = $rows[$i];
                if (filter_var($row->ip, FILTER_VALIDATE_IP, FILTER_FLAG_IPV4)) {
                    $bin .= pack('Nn', ip2long($row->ip), (int)$row->port);
                }
            }
            $resp['peers'] = $bin;
        } else {
            $list = [];
            foreach ($rows as $row) {
                $list[] = [
                    'ip'   => $row->ip,
                    'port' => (int)$row->port,
                ];
            }
            $resp['peers'] = $list;
        }

        return $this->bencode($resp);
    }

    public function scrape(Request $r)
    {
        if (Config::get('tracker.mode') === 'external') {
            $url = Config::get('tracker.external_announce');
            if (!$url) {
                return response('tracker misconfigured', 500);
            }
            if (Str::startsWith($url, ['http://', 'https://'])) {
                return redirect()->away($url);
            }
            return $this->bencode(['failure reason' => 'use external tracker', 'announce' => $url]);
        }

        $infoHash = $this->rawBin($r->query('info_hash', ''));
        if (strlen($infoHash) !== 20) {
            return $this->bencode(['failure reason' => 'invalid info_hash']);
        }

        $hexInfo   = bin2hex($infoHash);
        $incomplete = DB::table('peers')->where('info_hash', $hexInfo)->where('left_bytes', '>', 0)->count();
        $complete   = DB::table('peers')->where('info_hash', $hexInfo)->where('left_bytes', '=', 0)->count();
        $downloaded = 0;

        $resp = [
            'files' => [
                $infoHash => [
                    'complete'   => $complete,
                    'downloaded' => $downloaded,
                    'incomplete' => $incomplete,
                ],
            ],
        ];

        return $this->bencode($resp);
    }

    private function rawBin(?string $s): string
    {
        return rawurldecode($s ?? '');
    }

    private function bencode(array $data)
    {
        return response(Bencode::encode($data), 200, ['Content-Type' => 'text/plain']);
    }
}
