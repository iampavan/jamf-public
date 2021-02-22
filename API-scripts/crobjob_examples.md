# To display the contents of the crontab file of the currently logged in user:
$ crontab -l

# To Enter into crontab :
$ crontab -e

# Run a job every day (It will run at 09:00):
0 9 * * * update_EA_mobile_device.sh

# Run a job every 2 hours:
0 */2 * * * update_EA_mobile_device.sh