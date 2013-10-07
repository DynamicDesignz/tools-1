#MAKE SURE ALL THE TXT FILES ARE CORRECT
#BEFORE RUNNING THIS SCRIPT

#if not 1 param
if [ $# -ne 1 ]
   then 
      set "eth0"
fi

#setting the net int down
ifconfig down $1

#cronjobs aka blowjob
crontab -r

#getting all the ip tables rules
./iptables.sh

#set static ip address
netconfig="/etc/network/interfaces"

cp $netconfig $netconfig.backup
cat netconfig.txt > $netconfig

#hosts
hosts="/etc/hosts"

cp $hosts $hosts.backup
echo "127.0.0.1       localhost" > $hosts
echo "127.0.1.1       `hostname`" >> $hosts
chattr +i $hosts
chmod 600 $hosts

#put the interface back up
ifconfig up $1

#upgradig everything
apt-get update &
apt-get upgrade -y &

#makes the jail
./jail_maker.sh -s /var/jail

#Make Sure No Non-Root Accounts Have UID Set To 0
echo "Accounts with UID = 0" >> info.txt
echo `awk -F: '($3 == "0") {print}' /etc/passwd` >> info.txt
echo ""

#echo the sudoers file
echo "What is in the sudoers file"
cat /etc/sudoers >> info.txt

#disable root login 
sshfile="/etc/ssh/sshd_config"
mv $sshfile $sshfile.backup
num=`cat $sshfile | grep "PermitRootLogin" -n | cut -f1 -d:`
sed '${num}d' $sshfile
echo "" >> $sshfile
echo "PermitRootLogin no" >> $sshfile
echo "" >> $sshfile

#all listening ports
echo "All the ports that you're listing on" >> info.txt
echo `lsof -nPi | grep -iF listen` >> info.txt
echo "" >> info.txt
