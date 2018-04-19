pkill -9 test_connection
pkill -9 caffe
#!/bin/bash
# set -x
if [ $# -lt 3 ]; then
    echo "usage: $0 num_servers num_workers bin [args..]"
    exit -1;
fi

export DMLC_NUM_SERVER=$1
shift
export DMLC_NUM_WORKER=$1
shift
bin=$1
shift
arg="$@"

# start the scheduler
export DMLC_PS_ROOT_URI='127.0.0.1'
export DMLC_PS_ROOT_PORT=8011
export DMLC_ROLE='scheduler'
/home/student/ps-lite-sj/tests/test_connection &


# start servers
export DMLC_ROLE='server'
for ((i=0; i<DMLC_NUM_SERVER; ++i)); do
    export HEAPPROFILE=./S${i}
    /home/student/ps-lite-sj/tests/test_connection &
done

# start workers
export DMLC_ROLE='worker'
for ((i=0; i<DMLC_NUM_WORKER; ++i)); do
    export HEAPPROFILE=./W${i}
    ./build/tools/caffe train --solver=examples/mnist/lenet_solver.prototxt &
done

wait