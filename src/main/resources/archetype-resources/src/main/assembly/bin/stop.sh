BIN_DIR=$(cd `dirname $0`; pwd)
BASE_DIR=$(cd `dirname $BIN_DIR`;pwd)
CONF_DIR=$BASE_DIR/conf
LOG_DIR=$BASE_DIR/log
LIB_DIR=$BASE_DIR/lib
NO_HUP_FILE=$LOG_DIR/nohup
PID_FILE=$BIN_DIR/run.pid

pid=$(cat $PID_FILE)
if [ -f "$PID_FILE" ]; then
    process=`ps aux | grep "$pid" | grep -v grep`;
    if [ "$process" == "" ];then
        echo "the server is not running!";
        exit 1;
    fi
else
    echo "the server is not running!";
    exit 1;
fi

count=0
while :
do
    count=$(( $count + 2 ))
    echo "Stopping the server $count times"
    if [ $count -gt 20 ];then
        kill -9  $pid
    else
        kill -15 $pid
    fi
    sleep 2
    process=`ps aux | grep "$pid" | grep -v grep`;
    if [ "$process" == "" ];then
        break;
    fi

done
echo "Stop the server successfully"
rm $PID_FILE
rm $NO_HUP_FILE





