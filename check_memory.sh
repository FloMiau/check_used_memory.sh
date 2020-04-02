#!/bin/sh
#
#    Script to check memory usage on Linux. Ignores memory used by disk cache.
#
#    Version 1.0
#
#    Created 2020 Florian Köttner
#
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#
#
#                              $1 $2 $3 $4
# ./check_memory -w 85 -c 95
print_help() {
    echo "Usage:"
    echo "[-w] Warning level as a percentage"
    echo "[-c] Critical level as a percentage"
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

if [ "$warn_level" = "" ]; then
    echo "No Warning Level Specified"
    print_help
    exit 3;
fi

if [ "$critical_level" = "" ]; then
    echo "No Critical Level Specified"
    print_help
    exit 3;
fi


used=$(free -m | grep "Mem:" | awk '{print $3}')
total=$(free -m | grep "Mem:" | awk '{print $2}')
result=$((100*used/total))

if [ "$result" -gt "$critical_level" ]; then
    echo "Memory CRITICAL. $result% used. Using $used MB out of $total MB.| 'Memory %'=$result%;$warn_level;$critical_level"
    exit 2;
elif [ "$result" -ge "$warn_level" ] && [ "$result" -le "$critical_level" ]; then
    echo "Memory WARNING. $result% used. Using $used MB out of $total MB.| 'Memory %'=$result%;$warn_level;$critical_level"
    exit 1;
elif [ "$result" -lt "$warn_level" ]; then
    echo "Memory OK. $result% used. Using $used MB out of $total MB.| 'Memory %'=$result%;$warn_level;$critical_level"
    exit 0;
else
    echo "Unknown: if failed"
    exit 3;
fi


