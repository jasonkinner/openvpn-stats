#!/bin/bash

input_file=/var/log/openvpn/openvpn-status.log

declare -a client                                               # array to store client names
declare -a recvd						# array to store client MB received
declare -a sent							# array to store client MB sent
declare -a since						# array to store client *connected since* info
declare -a ippub						# array to store client publice IPs (and ports)
declare -a ippriv						# array to store client private IPs

i=0                                                             # keep a count of total lines
mbsent=0							# keep total count of MB sent
mbrecd=0							# keep total count of MB rec'd

while read line; do                                             # loop through all input lines from file
    if [[ "$line" = *,* ]]; then                                # if line has a comma in it, it may contain usable data
        IFS=',' read -ra fields <<< "$line"                     # convert string to array, split by comma
        if [[ "${fields[1]}" =~ \.[0-9]{1,3}:[0-9] ]]; then     # if 2nd field seems to contain an ip address:
                recvd[$i]=$((fields[2] / 2**20))                #   convert bytes received to MB, store in recvd array
		mbrecd=$((mbrecd + ${recvd[$i]}))		# keep track of total bytes received amongst all clients
                sent[$i]=$((fields[3] / 2**20))                 #   convert bytes sent to MB, store in sent array
	mbsent=$((mbsent + ${sent[$i]}))			# keep track of total bytes sent amongst all clients
                client[$i]="${fields[0]}"			#   store client name into client array
		since[$i]="${fields[4]}"			#   store connected since data into since array
		ippub[$i]="${fields[1]}"			#   store public IP and port into ippub array
                i=$((i+1))                                      #   increment record counter to track total clients
        fi
        if [[ "${fields[2]}" =~ \.[0-9]{1,3}:[0-9] ]]; then     # if 3rd field seems to contain an ip address:
		for (( k=0; k<$i; k++ ))			# clients in 2nd half of log aren't always in order
		do						#   so loop through them until we find the right one
			if [[ "${fields[1]}" == "${client[$k]}" ]]; then	# this logic isn't working currently
		                ippriv[$k]="${fields[0]}"       # store the private ip into ippriv array
			fi
		done
        fi
    fi
done < $input_file

# output header columns -- feel free to customize ordering (must change in loop below as well)
printf '%-20s\t%-20s\t%8s\t%8s\t%-26s\t%-15s\n' "Client" "From (IP:port)" "MB Sent" "MB Recvd" "Connected Since" "Private IP"
printf '%-20s\t%-20s\t%8s\t%8s\t%-26s\t%-15s\n' "------" "--------------" "-------" "--------" "---------------" "----------"

for (( j=0; j<$i; j++ ))                # loop through the client records
do
	# output the info -- ordering can be customized here (be sure to match ordering of column headers above
	# arrays are: client, ippub, ippriv, sent, recvd, since
	printf '%-20s\t%-20s\t%8s\t%8s\t%-26s\t%-15s\n' "${client[$j]}" "${ippub[$j]}" "${sent[$j]} MB" "${recvd[$j]} MB" "${since[$j]}" "${ippriv[$j]}"
done
echo "-------------------------------------------------------------------------------------------------------------------------------"
printf '%-20s\t%20s\t%8s\t%8s\n' "TOTALS" "$j clients" "$mbsent MB" "$mbrecd MB"
