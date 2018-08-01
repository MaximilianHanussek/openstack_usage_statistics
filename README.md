# openstack_usage_statistics
Scripts how to get and generate statistics from an OpenStack cloud
To run them permanently a cronjob would be a sufficient possibility.

Example:
One cron job daily to get the instances.
A second cron job which checks the load of every instance every 2 minutes for example.

To generate some plots you will find two R Scripts.

## OpenStack KPIs
The script `openstack_usage_evaluation_kpis.R` will generate plots from the `openstack usage` command output.
As first parameter the script gets the inputfile in .csv format and as a second parameter the outputpath including the filename.
You can run the script as following
<pre>Rscript --vanilla openstack_usage_evaluation_kpis.R /path/to/input/file.csv /path/to/output/file</pre>

## OpenStack Hypervisor usage
The script `openstack_usage_evaluation_hypervisor.R` will generate plots from the output of the hypervisor scripts.
As first parameter the script gets the inputfile path.

You can run the script as following
<pre>Rscript --vanilla openstack_usage_evaluation_hypervisor.R /path/to/input/file</pre>


