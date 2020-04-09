#!/bin/bash

input_file=/var/log/openvpn/openvpn-status.log

declare -a data                                                 # create arrays to store data
declare -a ip
i=0                                                             # keep a count of total lines
j=0                                                             # secondary counter for private IP section
while read line; do                                             # loop through all input lines
    if [[ "$line" = *,* ]]; then                                # if line has a comma in it, it contains usable data
        IFS=',' read -ra fields <<< "$line"                     # convert string to array, split by comma
        if [[ "${fields[1]}" =~ \.[0-9]{1,3}:[0-9] ]]; then     # if 2nd field seems to contain an ip address
                received=$((fields[2] / 2**20))                 # extract bytes received and convert to MB
                sent=$((fields[3] / 2**20))                     # extract bytes sent and convertt to MB
                # store a long string of the relevant data with tab separators
                data[$i]="${fields[0]}"$'\t'"${received}"$'\t'$'\t'"${sent}"$'\t'$'\t'"${fields[4]}"$'\t'
                i=$((i+1))                                      # increment record counter to track total clients
        fi
        if [[ "${fields[2]}" =~ \.[0-9]{1,3}:[0-9] ]]; then     # if 3rd field seems to contain an ip address
                ip[$j]="${fields[0]}"                           # store the private ip info in another array
                j=$((j+1))
        fi
    fi
done < $input_file

# output header columns
echo "Client"$'\t'$'\t'$'\t'"MB Recvd"$'\t'"MB Sent"$'\t'$'\t'"Since"$'\t'$'\t'$'\t'$'\t'"Private IP"

for (( i=0; i<$j; i++ ))                # loop through the client records
do
        echo "${data[$i]}${ip[$i]}"     # output the client info and private ip
done
