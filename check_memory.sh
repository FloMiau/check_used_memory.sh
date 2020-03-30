#!/bin/bash
#
# Script to check memory usage on Linux. Ignores memory used by disk cache.
#
# Requires the bc command
#				 $1 $2 $3 $4
# ./check_memory -w 85 -c 95
print_help() {
    echo "Usage:"
    echo "[-w] Warning level as a percentage"
    echo "[-c] Critical level as a percentage"
    exit 0
}

while test -n "$1"; do
    case "$1" in
        --help|-h)
            print_help
            exit 0
            ;;
        -w)
            warn_level=$2
            shift
            ;;
        -c)
            critical_level=$2
            shift
            ;;
        *)
            echo "Unknown Argument: $1"
            print_help
            exit 3
            ;;
    esac
    shift
done

if [ "$warn_level" == "" ]; then
    echo "No Warning Level Specified"
    print_help
    exit 3;
fi

if [ "$critical_level" == "" ]; then
    echo "No Critical Level Specified"
    print_help
    exit 3;
fi

# free -m | grep "cache:" | awk '{print $1}'
free=`free -m | grep "cache:" | awk '{print $4}'`
used=` free -m | grep "cache:" | awk '{print $3}'`

total=$(($free+$used))

#result=$(echo "$used / $total * 100" |bc -l|cut -c -2)
#echo "$used / $total * 100" |bc -l|cut -c -2

useAux=$((100*$used))
result=$(($useAux/$total))

#echo "used:           $used"
#echo "free:           $free"
#echo "total:          $total"

#echo "resAux:         $resAux"
#echo "result:         $result"
#echo "warn_level:     $warn_level"
#echo "critical_level: $critical_level"

## Código para debug
if [ "$result" -lt "$warn_level" ]; then
    echo "Memory OK. $result% used. Using $used MB  out of $total MB| 'Memory %'=$result%;$warn_level;$critical_level"
    exit 0;
elif [ "$result" -ge "$warn_level" ] && [ "$result" -le "$critical_level" ]; then
    echo "Memory WARNING. $result% used. Using $used MB out of $total MB| 'Memory %'=$result;$warn_level;$critical_level%"
    exit 1;
elif [ "$result" -gt "$critical_level" ]; then
    echo "Memory CRITICAL. $result% used. Using $used MB out of $total MB| 'Memory %'=$result%;$warn_level;$critical_level"
    exit 2;
fi
