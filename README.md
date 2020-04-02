# check_memory.sh
This Nagios/Icinga plugin can be used to check the memory usage. It checks the amount of used RAM.

## Getting Started

check_memory.sh is a shell script that checks the used memory of a system. The script was tested on bash and ash and is POSIX compatible. The Tool `free`has to be installed.

For installation place the python file in your plugin directory `/usr/lib/nagios/plugins/`.


Output of `free -m`:

                        total        used        free      shared  buff/cache   available
          Mem:           1992         115         104           1        1772        1693
          Swap:           979           0         979


The script is using solely the "used" column of Mem. Swap and buffered or cached RAM is ignored.

The check is based on a script by [sebastiaopburnay](https://exchange.nagios.org/directory/Plugins/Operating-Systems/Linux/check_memory-2Esh/details).

## Usage

    usage: check_memory.sh [-h] -w WARNING -c CRITICAL

    Script to check memory usage on Linux. Ignores memory used by disk cache Icinga plugin to check snap services

    arguments:
    -w WARNING  Warning level as a percentage
	  -c CRITICAL Critical level as a percentage

    optional arguments:
    -h, --help         show this help message and exit

## Examples

The following states can occur:

| State    | Situation                                                            |
| -------- | -------------------------------------------------------------------- |
| OK       | memory usage is below the warning level                              |
| WARNING  | memory usage is above the warning level and below the critical level |
| CRITICAL | memory usage is above the critical level                             |
| UNKNOWN  | other (e. g. something is broken)                                    |

### Everything is ok

No problem:

      ./check_memory.sh -w 50 -c 80
      Memory OK. 6% used. Using 124 MB out of 1992 MB.| 'Memory %'=6%;50;80

### Something is wrong


Warning:

    ./check_memory.sh -w 50 -c 80
    Memory WARNING. 60% used. Using 1240 MB out of 1992 MB.| 'Memory %'=60%;50;80
    
Critical:

    ./check_memory.sh -w 50 -c 80
    Memory CRITICAL. 100% used. Using 1992 MB out of 1992 MB.| 'Memory %'=100%;50;80
    
    
## Implemenation

In this part you can find configuration examples for Icinga 2.

### Command definiton


    object CheckCommand "used_memory" {
      command = [ PluginDir + "/check_used_memory.sh" ]


      arguments += {
        "-w" = "$used_memory_warning$"
        "-c" = "$used_memory_critical$"
      }
    }


### Service definition

    apply Service "ssh_used_memory" {
      import "generic-service"
      check_command = "used_memory"


      if ( host.vars.used_memory_warning) {
        vars.used_memory_warning = host.vars.used_memory_warning
      } else {
        vars.used_memory_warning = 80
      }


      if ( host.vars.used_memory_critical) {
        vars.used_memory_critical = host.vars.used_memory_critical
      } else {
        vars.used_memory_critical = 90
      }

      assign where host.vars.check_memory
    }

### Host definition

Check the memory usage

    object Host "example.org" {
      import "generic-host"

      # for warning use the default above
      # override critical
      vars.used_memory_critical = 85
   
      vars.check_memory = true
    }



## Author

Florian Köttner, 2020


## License

This project is licensed under the Apache 2.0 License - see the [LICENSE.md](LICENSE.md) file for details
