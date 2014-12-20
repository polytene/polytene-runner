#!/bin/bash

### BEGIN INIT INFO
# Provides:          start_stop_polytene-runners
# Required-Start:    $local_fs $all
# Required-Stop:     $local_fs $all
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start Stop Polytene Runners
# Description:       Start Stop Polytene Runners
### END INIT INFO

PATH=/bin:/usr/bin:/sbin:/usr/sbin
RUNNERS=/etc/polytene-runner.d/*.conf
BIN="polytene-runner"

update_runners(){
  for runner in $RUNNERS
  do
    test -f "$runner" || continue
    source "$runner"

    COMMAND="su - $RUN_AS_USER -c \"cd $BASE_DIR && git pull"
  done
}

start_stop_runers(){
  for runner in $RUNNERS
  do
    test -f "$runner" || continue
    source "$runner"
    
    COMMAND="su - $RUN_AS_USER -c \"cd $BASE_DIR && $BASE_DIR/bin/$BIN $1 $2\""
   
    eval $COMMAND;
  done
}

case "${1:-''}" in
  'start')
    ACTION="start -d"
    start_stop_runers $ACTION
    ;;
  'stop')
    ACTION=stop
    start_stop_runers $ACTION
    ;;
  'restart')
    ACTION=restart
    start_stop_runers $ACTION
    ;;
  'update')
    start_stop_runers stop
    update_runners
    start_stop_runers start -d
    ;;
  *)
    echo "Usage: $SELF start|stop|restart|update"
    exit 1
    ;;
esac

exit 0
