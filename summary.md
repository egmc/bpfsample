# BPF Summary

## 3行

https://www.atmarkit.co.jp/ait/articles/1811/21/news010.html

https://go-vargo.hatenablog.com/entry/2020/03/29/210304

http://slankdev.hatenablog.com/entry/2017/05/06/164953



割とここらへんのまとめで良い気がしつつ

 - 出自はpacket filter
 - 現在のBPFはkernel、user-levelのstatic/dynamicなイベント、PMC、perf_eventなどをソースにできるmagic tool
 - berkeleyでもpacketでもfilterでもない

## 特徴

 - 安全（instruction verifier）
 - 高速（kernel上での動作）
 - 簡単（?）

以上の特徴を元に `in production` というワードが頻繁に出現する。

とはいえヘビーなイベントに対してkernl <-> user land間のデータのやりとりを頻繁に行うと多少のオーバーヘッドは発生する

## BPFによるトレース機構の利用

上から難易度の低い順に

 - 既存のツールを利用する
  - `***-bpf`　なツール群
  - https://github.com/iovisor/bcc/tree/master/examples
 - bpftraceを利用する
  - ワンライナーなプログラム or スクリプトの実行
  - awkみたいな感覚
 - 自作する（BCC + python/ruby binding）
  - python3-bpfcc / rbbcc(https://github.com/udzura/rbbcc)

## 制約

 - 512バイトのスタックサイズ制限
  - bptraceのstr()で長い文字列を扱うことはできない
 - https://github.com/iovisor/bpftrace/pull/299


## 期待する使いどころ

 - 本番環境でのオンデマンドな調査ツールとして
  - 関数コールの観測
  - ボトルネック調査
  - IP/プロセス単位でのリソース使用状況調査など
