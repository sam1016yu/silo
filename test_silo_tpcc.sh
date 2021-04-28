#!/bin/bash

set +e
# set -x


silo_tpcc_neworder(){
    threads=$1
    warehouse=$2
    remote_per=$3
    echo "Testing Silo TPCC new_order only|Threads:$threads|#Warehouse:$warehouse|RemoteNewOrder:$remote_per"
    timeout -s SIGINT 15m ./out-perf.masstree/benchmarks/dbtest --bench tpcc --db-type ndb-proto2 --num-threads $threads --scale-factor $warehouse --txn-flags 1 --runtime 60 --bench-opts --workload-mix\ 100,0,0,0,0\ --new-order-remote-item-pct\ $remote_per --numa-memory 240G
}

pt_tpcc_neworder(){
    threads=$1
    warehouse=$2
    remote_per=$3
    echo "Testing Partitioned Store TPCC new_order only|Threads:$threads|#Warehouse:$warehouse|RemoteNewOrder:$remote_per"
    timeout -s SIGINT 15m ./out-perf.masstree/benchmarks/dbtest --bench tpcc --db-type kvdb-st --num-threads $threads --scale-factor $warehouse --txn-flags 1 --runtime 60 --bench-opts --workload-mix\ 100,0,0,0,0\ --enable-separate-tree-per-partition\ --enable-partition-locks\ --new-order-remote-item-pct\ $remote_per --numa-memory 240G
}

silo_tpcc_all(){
    threads=$1
    warehouse=$2
    echo "Testing Silo TPCC all transaction|Threads:$threads|#Warehouse:$warehouse"
    timeout -s SIGINT 15m ./out-perf.masstree/benchmarks/dbtest --bench tpcc --db-type ndb-proto2 --num-threads $threads --scale-factor $warehouse --txn-flags 1 --runtime 60 --numa-memory 240G
}


silo_tpcc_NP(){
    threads=$1
    mem=`expr 4 \* $threads`
    echo "Testing Silo TPCC 2T only|Threads:$threads|#Warehouse:$threads"
    timeout -s SIGINT 15m ./out-perf.masstree/benchmarks/dbtest --bench tpcc --db-type ndb-proto2 --num-threads $threads --scale-factor $threads --txn-flags 1 --runtime 60 --bench-opts --workload-mix\ 50,50,0,0,0 --numa-memory ${mem}G
}



pt_tpcc_all(){
    threads=$1
    warehouse=$2
    echo "Testing  Partitioned Store TPCC  all transaction|Threads:$threads|#Warehouse:$warehouse"
    timeout -s SIGINT 15m ./out-perf.masstree/benchmarks/dbtest --bench tpcc --db-type kvdb-st --num-threads $threads --scale-factor $warehouse --txn-flags 1 --runtime 60 --bench-opts \ --enable-separate-tree-per-partition\ --enable-partition-locks --numa-memory 240G
}

tpcc_all(){
    threads=$1
    warehouse=$2
    # silo_tpcc_all $threads $warehouse
    # pt_tpcc_all $threads $warehouse
    # for remote_per in 0 1 2 3 4 5 6 7 8 9 10
    for remote_per in 1 3 5
    do
        # silo_tpcc_neworder $threads $warehouse $remote_per
        pt_tpcc_neworder $threads $warehouse $remote_per
    done
}



for th in 20 24 28 32
do
    silo_tpcc_NP $th 2>&1 | tee -a ./logs/tpcc_NP.out
done


# pt_tpcc_all 31 62 6 | tee -a ./logs/tpcc_test.out
# pt_tpcc_all 28 56 6 | tee -a ./logs/tpcc_test.out

#  tpcc_all 32 160 2>&1 | tee -a ./logs/tpcc2.out

# for warehouse_num in 96 144 160
# do
#     tpcc_all 32 $warehouse_num 2>&1 | tee -a ./logs/tpcc_odd.out
# done


# for warehouse_num in 64 96 144 160
# do
#     tpcc_all $warehouse_num $warehouse_num 2>&1 | tee -a ./logs/tpcc.out
# done
