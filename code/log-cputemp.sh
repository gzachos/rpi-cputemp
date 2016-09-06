#!/bin/bash

#+-----------------------------------------------------------------------+
#|                 Copyright (C) 2016 George Z. Zachos                   |
#+-----------------------------------------------------------------------+
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
# Contact Information:
# Name: George Z. Zachos
# Email: gzzachos_at_gmail.com


################################################################################
#                              create_rrdb()                                   #
################################################################################

# Create a Round Robin Database (RRD) named "cputemp.rrd" in $RRD_DIR
# that will store one (1) temperature value every minute. The storing
# capability of the database will be 535680 values (~1 year).
create_rrdb () {
	rrdtool create ${RRD_DIR}/cputemp.rrd \
		--start now \
		--step 60 \
		--no-overwrite \
		DS:cpu_temp:GAUGE:120:U:U \
		RRA:AVERAGE:0.5:1:535680 # 12months * 31days * 24hours * 60minutes
}


################################################################################
#                              create_webpage()                                #
################################################################################

# Create an index.html file in $WWW_DIR.
create_webpage () {
	# If the index.html file already exists and it has size greather than 0,
	# do nothing.
	if [ -e ${WWW_DIR}/index.html ] && [ -s ${WWW_DIR}/index.html ]
	then
		return
	fi

cat > ${WWW_DIR}/index.html << __EOF__
<!DOCTYPE html>
<head>
	<title>RPi CPU Temperature</title>
	<meta charset="UTF-8">
	<style>
	html {
		text-align: center;
		background: radial-gradient(circle, #DCDFEF, #7886C4);
	}

	body {
		width: 910px;
		margin: auto;
	}
	</style>
</head>
<body>
	<h2>RPi CPU Temperature Graph Report</h2><br>
	<img src="./00-temp-1h.png"  alt="00-temp-1h.png">
	<img src="./01-temp-2h.png"  alt="01-temp-2h.png">
	<img src="./02-temp-4h.png"  alt="02-temp-4h.png">
	<img src="./03-temp-12h.png" alt="03-temp-12h.png">
	<img src="./04-temp-24h.png" alt="04-temp-24h.png">
	<img src="./05-temp-1w.png"  alt="05-temp-1w.png">
	<img src="./06-temp-4w.png"  alt="06-temp-4w.png">
	<img src="./07-temp-24w.png" alt="07-temp-24w.png">
	<img src="./08-temp-1y.png"  alt="08-temp-1y.png">
</body>
</html>
__EOF__
}


################################################################################
#                                   main()                                     #
################################################################################
main () {
	# $WWW_DIR and $RRD_DIR can differ.
	WWW_DIR="/var/www/html/cpu-temp"   # Modify at your discretion.
	RRD_DIR="/var/www/html/cpu-temp"   # Modify at your discretion.

	# Check if $WWW_DIR is a valid directory.
	if [ ! -d ${WWW_DIR} ]
	then
		# Create it if it doesn't exit.
		mkdir -p ${WWW_DIR}
		# Exit if the directory cannot be created.
		if [ $? -ne 0 ]
		then
			echo "${WWW_DIR}: Error creating directory!"
			echo "Script will now exit..."
			exit 1
		fi
	fi

	# Check if $RRD_DIR is a valid directory.
        if [ ! -d ${RRD_DIR} ]
        then
                # Create it if it doesn't exit.
                mkdir -p ${RRD_DIR}
                # Exit if the directory cannot be created.
                if [ $? -ne 0 ]
                then
                        echo "${RRD_DIR}: Error creating directory!"
                        echo "Script will now exit..."
                        exit 1
                fi
        fi

	# Calling functions.
	create_rrdb
	create_webpage

	# $TEMP_READING is assigned a string of the following format: temp=40.6'C
	TEMP_READING=$(/opt/vc/bin/vcgencmd measure_temp)

	# $TEMP_VALUE is assigned the numerical value of CPU temperature (i.e. 40.6).
	TEMP_VALUE=${TEMP_READING:5:4}

	# Current time in seconds since 1970-01-01 00:00:00 UTC is assigned to $TIMESTAMP.
	TIMESTAMP=$(date +%s)

	# Store $TEMP_VALUE in the RRDatabase.
	rrdtool update ${RRD_DIR}/cputemp.rrd ${TIMESTAMP}:${TEMP_VALUE}

	# Print CPU temperature to console. To be used for debug purposes.
	# echo ${TEMP_VALUE}
}


# Calling main function.
main

