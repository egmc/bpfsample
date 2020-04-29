# sample code from https://udzura.hatenablog.jp/entry/2020/03/27/172104
require 'rbbcc'
include RbBCC
pid = ARGV[0]&.to_i || raise("Usage: #{$0} PID")

bpf_text = <<BPF
#include <uapi/linux/ptrace.h>
struct data_t {
    u64 ts;
    char klass[64];
    char path[256];
};
BPF_PERF_OUTPUT(events);

int do_trace_create_object(struct pt_regs *ctx) {
    struct data_t data = {};
    data.ts = bpf_ktime_get_ns();
    bpf_usdt_readarg_p(1, ctx, &data.klass, sizeof(data.klass));
    bpf_usdt_readarg_p(2, ctx, &data.path, sizeof(data.path));
    events.perf_submit(ctx, &data, sizeof(data));
    return 0;
};
BPF

u = USDT.new(pid: pid.to_i)
u.enable_probe(probe: "object__create", fn_name: "do_trace_create_object")

b = BCC.new(text: bpf_text, usdt_contexts: [u])
puts("%-18s %-24s %s" % ["TIME(s)", "KLASS", "PATH"])
start = nil
b["events"].open_perf_buffer do |cpu, data, size|
  event = b["events"].event(data)
  start ||= event.ts
  time_s = ((event.ts - start).to_f) / 1_000_000_000
  puts("%-18.9f %-24s %s" % [time_s, event.klass, event.path])
end
Signal.trap(:INT) { puts "\nDone."; exit }
loop { b.perf_buffer_poll }