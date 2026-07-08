import matplotlib.pyplot as plt
import pandas as pd
import os

microbench_logs = ["zipfan_hottest_10G.read.log.csv" ,  "zipfan_hottest_13.5G.read.log.csv" ,  "zipfan_hottest_27G.read.log.csv",
 "zipfan_hottest_10G.write.log.csv",  "zipfan_hottest_13.5G.write.log.csv" , "zipfan_hottest_27G.write.log.csv"]

test_name = ["small-read", "medium-read", "large-read", "small-write", "medium-write", "large-write"]

microbench_log_dir = ["microbench_nomad" , "microbench_tpp"]
legends = ["nomad", "tpp"]
# microbench_log_dir = ["microbench_memtis" , "microbench_nomad" , "microbench_tpp"]
# legends = ["memtis", "nomad", "tpp"]

base_dir = "src/post_processing/tmp"

def read_bandwidths(log_names):
    transient = []
    steady = []
    for i in log_names:
        df = pd.read_csv(i, index_col=0)
        transient.append(df.loc[1, "Bandwidth(MB/s)"])
        steady.append(df.loc[4, "Bandwidth(MB/s)"])
    return transient, steady

def plot_microbench_bw(transient, steady, legends, graph_name, ymax):
    fig, (ax0, ax1) = plt.subplots(1, 2)
    ax0.bar(range(len(transient)) , transient)
    ax0.set_xticks(range(len(transient)), legends)
    ax1.bar(range(len(steady)) , steady)
    ax1.set_xticks(range(len(steady)), legends)
    ax0.sharey(ax1)
    ax1.set_ylim(0, ymax)
    ax0.set_ylabel('Bandwidth (MB/s)',fontsize = 18)
    ax0.set_title("migration in progress")
    ax1.set_title("migration stable")
    foo_fig = plt.gcf()
    foo_fig.savefig(graph_name)
    plt.close(fig)


# First pass: read every log and find the global max so all graphs share one y-scale.
all_bandwidths = []
global_max = 0
for log_name in microbench_logs:
    logs = []
    for dir in microbench_log_dir:
        log_to_be_ploted = os.path.join(base_dir, dir, log_name)
        if(not os.path.exists(log_to_be_ploted)):
            print(log_to_be_ploted, "not found")
            exit(1)
        logs.append(log_to_be_ploted)
    transient, steady = read_bandwidths(logs)
    all_bandwidths.append((transient, steady))
    global_max = max(global_max, max(transient), max(steady))

global_max *= 1.05  # headroom so the tallest bar doesn't touch the axis top

for (transient, steady), graph_name in zip(all_bandwidths, test_name):
    plot_microbench_bw(transient, steady, legends, os.path.join(base_dir,"microbench" + graph_name + ".png"), global_max)
    
