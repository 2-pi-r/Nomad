# Silo(TPC-C) 준비. 저장소 루트에서 실행한다.
# prepare.sh와 달리 third_party/tmp를 통째로 지우지 않으므로 따로 돌려도 안전하다.
#
# 의존 패키지 (libmysqld-dev는 불필요 — Makefile이 MYSQL_S를 정의하지 않아 항상 -DNO_MYSQL):
#   sudo apt-get install -y g++ libnuma-dev libdb++-dev libaio-dev libssl-dev zlib1g-dev libjemalloc-dev

set -e

curr_dir=$PWD
silo_dir=third_party/tmp/silo

rm -rf third_party/tmp/memtis ${silo_dir}

# Memtis(SOSP'23)의 Silo 트리만 sparse checkout.
# upstream stephentu/silo와 tpcc.cc / dbtest.cc는 바이트 단위로 동일하고,
# masstree와 lz4가 트리에 포함되어 있어 빌드 중 네트워크가 필요 없다.
git clone --depth 1 --filter=blob:none --sparse \
    https://github.com/cosmoss-jigu/memtis.git third_party/tmp/memtis
cd third_party/tmp/memtis
git sparse-checkout set memtis-userspace/bench_dir/silo
cd ${curr_dir}

cp -a third_party/tmp/memtis/memtis-userspace/bench_dir/silo ${silo_dir}
rm -rf third_party/tmp/memtis

cd ${silo_dir}
patch -p1 < ../../silo.diff
MODE=perf make -j`nproc` dbtest
cd ${curr_dir}

ls -l ${silo_dir}/out-perf.masstree/benchmarks/dbtest
