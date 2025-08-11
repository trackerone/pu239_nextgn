<?php

namespace App\Services;

class Bencode
{
    public static function encode($value): string
    {
        if (is_int($value)) return 'i' . $value . 'e';
        if (is_string($value)) return strlen($value) . ':' . $value;
        if (is_array($value)) {
            $isList = array_keys($value) === range(0, count($value) - 1);
            if ($isList) {
                $out = 'l';
                foreach ($value as $v) $out .= self::encode($v);
                return $out . 'e';
            }
            ksort($value, SORT_STRING);
            $out = 'd';
            foreach ($value as $k => $v) {
                $out .= self::encode((string)$k) . self::encode($v);
            }
            return $out . 'e';
        }
        return self::encode((string)$value);
    }
}
