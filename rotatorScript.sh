#!/usr/bin/env bash
        #date=$(date '+%Y.%m.%d-%H:%M:%S')
        date=$(date '+%Y.%m.%d')
        mkdir -p /home/ec2-user/logs
        touch /home/ec2-user/logs/$date.log

        echo "---------------------New Run Starts here $(date)----------------" >> /home/ec2-user/logs/$date.log
        INSTANCE=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
        OLD_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

        echo "This is the INSTANCE ID "$INSTANCE >> /home/ec2-user/logs/$date.log
        echo "THis is the existing IP "$OLD_IP >> /home/ec2-user/logs/$date.log

        #Gets Allocation ID for the current IP, trims "" and trims , in the end
        ALLOCATION_ID=$(aws ec2 describe-addresses | grep -i AllocationId | cut -f 2 -d ":" | sed 's/"//g' | tr -d ",")

        echo "This is the current Allocation ID  ".$ALLOCATION_ID >> /home/ec2-user/logs/$date.log

        echo "Here are the current addresses" >> /home/ec2-user/logs/$date.log
        echo $(aws ec2 describe-addresses) | python -m json.tool >> /home/ec2-user/logs/$date.log

        # Gets new IP and then trims the ""
        NEW_IP=$(aws ec2 allocate-address --query PublicIp | tr -d '"')

        echo "here is the new IP" >> /home/ec2-user/logs/$date.log
        echo $NEW_IP >> /home/ec2-user/logs/$date.log

        echo "Checking for current addresses again" >> /home/ec2-user/logs/$date.log
        echo $(aws ec2 describe-addresses) |  python -m json.tool >> /home/ec2-user/logs/$date.log

        echo ''
        echo "Old IP: $OLD_IP"
        echo "New IP: $NEW_IP"
        echo ''
        echo 'Associating new IP...'

        # Associating the new IP address to the existing instance

        echo "Associating new IP address" >> /home/ec2-user/logs/$date.log

        echo $(aws ec2 associate-address --instance-id $INSTANCE --public-ip $NEW_IP) >> /home/ec2-user/logs/$date.log

        echo "
Getting IPs addresses again" >> /home/ec2-user/logs/$date.log
        echo $(aws ec2 describe-addresses) |  python -m json.tool >> /home/ec2-user/logs/$date.log

        # Releasing the old IP
        echo 'Releasing old IP...'
        echo "Releasing old IP" >> /home/ec2-user/logs/$date.log
        echo $(aws ec2 release-address  --allocation-id $ALLOCATION_ID)>> /home/ec2-user/logs/$date.log
        echo "Getting IPs addresses again" >> /home/ec2-user/logs/$date.log
        echo $(aws ec2 describe-addresses) |  python -m json.tool >> /home/ec2-user/logs/$date.log