#!/bin/sh
echo "USAGE: $0 [-daemon] [-loggc] "

MAIN_CLASS=${project.mainClass}

##which java to use
if [ -z "$JAVA_HOME" ];then
    export JAVA=`which java`
else
    export JAVA="$JAVA_HOME/bin/java"
fi

##classpath:jar
BIN_DIR=$(cd `dirname $0`; pwd)
BASE_DIR=$(cd `dirname $BIN_DIR`;pwd)
cd ${BASE_DIR}
LIB_DIR=$BASE_DIR/lib
for file in "$LIB_DIR"/*.jar
do
    CLASSPATH="$CLASSPATH":"$file"
done

##classpath:config file
CONF_DIR=$BASE_DIR/conf
CLASSPATH=$CLASSPATH:$CONF_DIR

#JMX settings
JMX_PORT=""
if [ $JMX_PORT ];then
    JMX_OPTS="-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.authenticate=false  -Dcom.sun.management.jmxremote.ssl=false  -Dcom.sun.management.jmxremote.port=$JMX_PORT "
fi

##Log file
LOG_DIR=$BASE_DIR/log
NO_HUP_FILE=$LOG_DIR/nohup
PID_FILE=$BIN_DIR/run.pid

##HEAP_OPTS
if [ -z "$HEAP_OPTS" ];then
    HEAP_OPTS="-Xmx512m -Xms256m -server"
fi

##JVM performance options
if [ -z "$JVM_PERFORMANCE_OPTS" ];then
    JVM_PERFORMANCE_OPTS="-XX:+UseConcMarkSweepGC -XX:+UseCMSCompactAtFullCollection"
fi

##get the input argv
while [ $# -gt 0 ]; do
  COMMAND=$1
  case $COMMAND in
    -loggc)
      if [ -z "$GC_LOG_OPTS" ]; then
        GC_LOG_ENABLED="true"
      fi
      shift
      ;;
    -daemon)
      DAEMON_MODE="true"
      shift
      ;;
    *)
      break
      ;;
  esac
done


##GC options
GC_FILE=$LOG_DIR/gc.log
if [ "x$GC_LOG_ENABLED" = "xtrue" ];then
    GC_LOG_OPTS="-Xloggc:$GC_FILE -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintGCTimeStamps "
fi

##judge if has started
if [ -f "$PID_FILE" ]; then
    pid=$(cat "$PID_FILE")
    process=`ps aux | grep "$pid" | grep -v grep`;
    if [ "$process" != "" ];then
        echo "the server is running!";
        exit 1;
    fi
fi

sleep 1
if [ "x$DAEMON_MODE" = "xtrue" ];then
    nohup $JAVA $HEAP_OPTS $JVM_PERFORMANCE_OPTS $GC_LOG_OPTS  -classpath $CLASSPATH  $MAIN_CLASS  2>&1 >$NO_HUP_FILE &
else
    exec $JAVA $HEAP_OPTS $JVM_PERFORMANCE_OPTS $GC_LOG_OPTS  -classpath $CLASSPATH  $MAIN_CLASS
fi

touch $PID_FILE
echo $! > $PID_FILE
chmod 755 $PID_FILE



