require 'rbbcc'
include RbBCC
pid = ARGV[0]&.to_i || raise("Usage: #{$0} PID")

bpf_text = <<BPF
#include <uapi/linux/ptrace.h>
struct data_t {
    u64 ts;
    char function[128];
};
BPF_PERF_OUTPUT(events);

int do_trace_function_entry(struct pt_regs *ctx) {
    struct data_t data = {};
    data.ts = bpf_ktime_get_ns();
    bpf_usdt_readarg_p(1, ctx, &data.function, sizeof(data.function));
    events.perf_submit(ctx, &data, sizeof(data));
    return 0;
};
BPF

u = USDT.new(pid: pid.to_i)
u.enable_probe(probe: "function__entry", fn_name: "do_trace_function_entry")

b = BCC.new(text: bpf_text, usdt_contexts: [u])
puts("%-18s %s" % ["TIME(s)", "function"])
start = nil
b["events"].open_perf_buffer do |cpu, data, size|
  event = b["events"].event(data)
  start ||= event.ts
  time_s = ((event.ts - start).to_f) / 1_000_000_000
  puts("%-18.9f %s" % [time_s, event.function])
end
Signal.trap(:INT) { puts "\nDone."; exit }
loop { b.perf_buffer_poll }