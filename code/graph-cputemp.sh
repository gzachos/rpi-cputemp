#!/bin/bash


################################################################################
#                            generate_rrdgraph()                               #
################################################################################

# Creates a specific temperature graph from data stored in an RRDatabase.
# (Parameters:	$1 -> Graph index [00-08],
#		$2 -> Time interval {1h, 2h, 4h, 12h, 24h, 1w, 4w, 24w, 1y},
#		$3 -> Graph title)
generate_rrdgraph () {
	rrdtool graph ${WWW_DIR}/0${INDEX}-temp-${2}.png \
		--start -${2} \
		--title "${3} Log" \
		--vertical-label "Temperature ºC" \
		--width 600 \
		--height 200 \
		--color GRID#C2C2D6 \
		--color MGRID#E2E2E6 \
		--dynamic-labels \
		--grid-dash 1:1 \
		--font TITLE:10 \
		--font UNIT:9 \
		--font LEGEND:8 \
		--font AXIS:8 \
		--font WATERMARK:8 \
		--lazy \
		--watermark "$(date -R)" \
		DEF:cpu_temp=${RRD_DIR}/cputemp.rrd:cpu_temp:AVERAGE \
		AREA:cpu_temp#FF0000AA:"RPi CPU" \
		LINE2:cpu_temp#FF0000
}


################################################################################
#                                main()                                        #
################################################################################

# Creates all the graphs.
main () {
	WWW_DIR="/var/www/html/cpu-temp"   # Should match $WWW_DIR of log_cputemp.sh
	RRD_DIR="/var/www/html/cpu-temp"   # Should match $RRD_DIR of log_cputemp.sh
	INDEX=0
	INTERVALS="1h 2h 4h 12h 24h 1w 4w 24w 1y"
	TITLES=('1 Hour' '2 Hour' '4 Hour' '12 Hour' '24 Hour' '1 Week' '1 Month' '6 Month' '1 Year')

	if [ ! -d ${WWW_DIR} ]
	then
		echo "${WWW_DIR}: No such directory!"
		echo "Script will now exit!"
		exit 1
	fi

	if [ ! -d ${RRD_DIR} ]
	then
		echo "${RRD_DIR}: No such directory!"
		echo "Script will now exit!"
		exit 1
	fi

	# Small delay so that the RRDatabase gets updated before graphs are created.
	sleep 5

	for interval in ${INTERVALS}
	do
		generate_rrdgraph "${INDEX}" "${interval}" "${TITLES[$INDEX]}"
		((INDEX += 1))
	done
}


# Calling main function.
main

