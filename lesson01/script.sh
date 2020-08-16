# Set correct HostIP here.
export HostIP="10.0.2.94"

pd-server --name="pd" \
    --data-dir="pd" \
    --client-urls="http://${HostIP}:12379" \
    --peer-urls="http://${HostIP}:12380" \
    --log-file=pd.log

tikv-server --pd-endpoints="${HostIP}:12379" \
    --addr="${HostIP}:20160" \
    --data-dir=tikv1 \
    --log-file=tikv1.log

tikv-server --pd-endpoints="${HostIP}:12379" \
    --addr="${HostIP}:20161" \
    --data-dir=tikv2 \
    --log-file=tikv2.log

tikv-server --pd-endpoints="${HostIP}:12379" \
    --addr="${HostIP}:20162" \
    --data-dir=tikv3 \
    --log-file=tikv3.log

pd-ctl store -d -u http://${HostIP}:12379


tidb-server -path ${HostIP}:12379 -store tikv





