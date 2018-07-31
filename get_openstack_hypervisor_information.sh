#!/bin/bash
#title           :get_openstack_hypervisor_information
#description     :This script will generate usage statistics of OpenStack VMs from the hypervisor directly
#author          :Maximilian Hanussek
#date            :2018-06-22
#version         :0.6
#usage           :sh get_openstack_hypervisor_information.sh
#notes           :Install jq to parse json file 
#bash_version    :4.2.46(1)-release
#=========================================================================================================
if [ -f /root/openstack_hypervisor_usage/actual_openstack_projects.txt ]; then               # Check if file with project names exists or maybe it is updating

while read -r project; do                                                                      # Iterate over the projects from the created .txt file and get information about the instances
  project_wo_spaces=$(echo "$project" | tr -d "[:blank:]")
  if [ -f /root/openstack_hypervisor_usage/instances_"$project_wo_spaces".json ]; then                 # Check if file with hypervisor information of the project exist or maybe it is updating

    echo $project                                                                            # Print out the project of the current iteration
    if ! [ -f /root/openstack_hypervisor_usage/usage_info_hypervisor_"$project_wo_spaces".txt ]; then  # Check if a usage information file for the current project already exists, if not print table header first
      printf "%s %s %s %s %s %s %s %s\n" "DATE" "PROJECT_NAME" "USER_ID" "VMID" "HOST" "CPU_USAGE(%)" "MEM_USAGE(%)" "PID" >> /root/openstack_hypervisor_usage/usage_info_hypervisor_"$project_wo_spaces".txt
    fi
    
    HEADER=$(grep -c "DATE" /root/openstack_hypervisor_usage/usage_info_hypervisor_"$project_wo_spaces".txt) # Get the number of the string "DATE" in stats file 

    if [ $HEADER == 0 ]; then                                                                # If number of "DATE" is zero, than there is no header line and it will be added
      ex -sc '1i|DATE PROJECT_NAME USER_ID VMID HOST CPU_USAGE(%) MEM_USAGE(%) PID' -cx /root/openstack_hypervisor_usage/usage_info_hypervisor_"$project_wo_spaces".txt # Add header on first line via vim in execution mode
    fi

    VMIDS=$(cat /root/openstack_hypervisor_usage/instances_"$project_wo_spaces".json | jq '.["id"]')   # Get the VM IDs from the corresponding .json file of the project as a single string
    VMIDS=(`echo $VMIDS | sed 's/\s/\n/g'`)                                                  # Split the string of VM IDs on the spaces and convert it to an array
    HOSTS=$(cat /root/openstack_hypervisor_usage/instances_"$project_wo_spaces".json | jq '.["OS-EXT-SRV-ATTR:host"]')   # Get the Host names from the corresponding .json file of the project as a single string
    HOSTS=(`echo $HOSTS | sed 's/\s/\n/g'`)                                                  # Split the string of names on the spaces and convert it to an array
    USIDS=$(cat /root/openstack_hypervisor_usage/instances_"$project_wo_spaces".json | jq '.["user_id"]')                # Get the User IDs from the corresponding .json file of the project as a single string
    USIDS=(`echo $USIDS | sed 's/\s/\n/g'`)                                                  # Split the string of user IDs on the spaces and convert it to an array
                                                                                             # !!! The splitting steps work only for strings if there are no spaces in between 
                                                                                             # Example: S1: "ID1" "ID_2" "ID 3" that would lead to an array with the entries "ID1" "ID_2" "ID" "3"   
                                                                                             # "ID 3" would be split into two parts which is not desired. So be carefull if you use for example the VM names !!! 

    LENGTH=${#VMIDS[@]}                                                                      # Get the length of the array of the VM IDs to get to know how long to loop over the different arrays
    LENGTH=$(expr $LENGTH - 1)                                                               # Subtract 1 from the array length because the array starts with 0
    for i in $( seq 0 $LENGTH ); do                                                          # Iterate over the different array entries all first entries belong to one instance all second entries belong to the
                                                                                             # second instance ... 
      DATE=$(date '+%Y-%m-%d %H:%M:%S')                                                      # Set the date yyyy-mm-dd hh:mm:ss
      VMID=${VMIDS[$i]//\"/}                                                                 # Get a single VM ID without quotation marks ("")
      USID=${USIDS[$i]//\"/}                                                                 # Get a single user ID without quotation marks ("")
      HOST=${HOSTS[$i]//\"/}                                                                 # Get a single host name without quotation marks ("")
      PID=$(ssh -n root@$HOST VMID=$VMID ps aux | grep qemu | grep $VMID | awk '{print $2}') # Get the process ID from the ps request
      CPU=$(ssh -tt -n root@$HOST PID=$PID top -n 1 -b -p "$PID" | grep "$PID" | awk '{print $9}')     # Get the percentaged CPU usage from the top command
      MEM=$(ssh -tt -n root@$HOST PID=$PID top -n 1 -b -p "$PID" | grep "$PID" | awk '{print $10}')     # Get the percentaged memory usage from the top command
      
      printf "%s %s %s %s %s %s %s %s\n" "$DATE" "$project" "$USID" "$VMID" "$HOST" "$CPU" "$MEM" "$PID" >> /root/openstack_hypervisor_usage/usage_info_hypervisor_"$project_wo_spaces".txt # Direct all gathered information
                                                                                                                                                                                # to the corresponding usage file 
    done
  else
    echo "The file /root/openstack_hypervisor_usage/usage_info_hypervisor_'$project_wo_spaces'.txt does not exist. Maybe it is currently rebuild." # Message if hypervisor information file is missing
  fi
done </root/openstack_hypervisor_usage/actual_openstack_projects.txt
else 
  echo "The file /root/openstack_hypervisor_usage/actual_openstack_projects.txt does not exist. Maybe it is currently rebuild."          # Message if project name file is missing
fi

