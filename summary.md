# BPF Summary

## 3行で

https://www.atmarkit.co.jp/ait/articles/1811/21/news010.html

https://go-vargo.hatenablog.com/entry/2020/03/29/210304

http://slankdev.hatenablog.com/entry/2017/05/06/164953

https://speakerdeck.com/takumakume/ebpf-getting-started


割とここらへんのまとめで良い気がしつつ

 - 出自はpacket filter
 - 現在のBPFはkernel、user-levelのstatic/dynamicなイベント、PMC、perf_eventなどをソースにできるmagic toolとして定義されている
 - berkeleyでもpacketでもfilterでもない

## 特徴

 - 安全（instruction verifier）
 - 高速（kernel上での動作）
 - 簡単（?）

以上の特徴を元に `in production` というワードが頻繁に出現する。

とはいえヘビーなイベントに対してkernl <-> user land間のデータのやりとりを頻繁に行うと無視できないオーバーヘッドは発生する

## 基本動作

chapter2 Technology Backgroundの図を参照する

## 利用プロダクト

なんか図があった気がするが・・

 - sysdig https://www.scsk.jp/sp/sysdig/blog/sysdig/ebpfsysdigfalco.html
 - cillium https://thinkit.co.jp/article/15281 https://github.com/cilium/cilium

## BPFによるトレース機構の利用

上から難易度の低い順に

 - 既存のツールを利用する
  - `***-bpfcc` なツール群
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
 - bpf program上ではループは使えない（Kernel5.3からbounded loopがサポートされている）
 - BPFの命令セットは当初4096という制限があったが、現在（Kernel5.2以降）は1 millionに拡張されている

## 期待する使いどころ

 - 本番環境でのオンデマンドな調査ツールとして
  - 関数コールの観測
  - ボトルネック調査
  - IP/プロセス単位でのリソース使用状況調査など
