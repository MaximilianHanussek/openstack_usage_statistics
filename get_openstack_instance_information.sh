[root@osm03 openstack_hypervisor_usage]# cat get_openstack_instance_information.sh 
#!/bin/bash
#title           :get_openstack_instance_information
#description     :This script will generate information of the current Openstack projects and their instances
#author		       :Maximilian Hanussek
#date            :2018-06-22
#version         :0.5
#usage		       :sh get_openstack_instance_information.sh
#notes           :Install OpenStack command line API tools 
#bash_version    :4.2.46(1)-release
#============================================================================================================

# Set the OpenStack admin credentials as environment variables
source /root/admin

# Delete old file of the listed OpenStack projects
rm -f /root/openstack_hypervisor_usage/actual_openstack_projects.txt
rm -f /root/openstack_hypervisor_usage/actual_openstack_projects.tmp


# Generate new file with all listed OpenStack projects
while read -r line;                                                               # Iterate through projects and get their name
  do
   if ! [[ "$line" == "service" || "$line" == "admin" || "$line" == "elixir-demo" ]];   # Exclude the projects "service", "admin", "elixir-demo" 
     then
      echo "$line"                                                                    # Print the projects on CL
      echo "$line" >> /root/openstack_hypervisor_usage/actual_openstack_projects.tmp  # Write project names into .tmp file
    fi
done < <(openstack project list -c Name -f value)                                 # Input of the while loop is the project list in value format

mv /root/openstack_hypervisor_usage/actual_openstack_projects.tmp /root/openstack_hypervisor_usage/actual_openstack_projects.txt # Rename .tmp file avoid conflicts with the following script

sleep 2;                                                                         # Wait 2 seconds to be sure file is written

while read -r projects; do                                                       # Iterate over the projects from before and get information about the instances
  projects_wo_spaces=$(echo "$projects" | tr -d "[:blank:]")
  rm -f /root/openstack_hypervisor_usage/instances_"$projects_wo_spaces".json              # Delete old file of instance information
  rm -f /root/openstack_hypervisor_usage/instances_"$projects_wo_spaces".tmp               # Delete old file of instance information

  for i in $(openstack server list --project "$projects" -c ID -f value );         # Iterate over all instances in the project
    do
      POWER=$(openstack server show -c OS-EXT-STS:power_state -f 'value' "$i");    # Check if the instance of the current iteration is running or shut down
      if [ "$POWER" = "Running" ]; then                                          # Check filter out the running ones
        openstack server show -c OS-EXT-SRV-ATTR:host -c name -c id -c project_id -c user_id -f json "$i" >> /root/openstack_hypervisor_usage/instances_"$projects_wo_spaces".tmp # Get instance information
        echo "$projects"                                                         # Print out which project is currently checked on the CL
      fi
  done
  mv /root/openstack_hypervisor_usage/instances_"$projects_wo_spaces".tmp /root/openstack_hypervisor_usage/instances_"$projects_wo_spaces".json # Rename .tmp file avoid conflicts with the following script
done </root/openstack_hypervisor_usage/actual_openstack_projects.txt

