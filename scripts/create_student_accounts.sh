for gp in group1 group2 group3 group4
do
   sudo useradd -m -s /bin/bash "$gp"
   echo "$gp:group123" | sudo chpasswd
   echo "YOU ARE LOGGED IN AS $gp" | sudo tee /home/$gp/README.txt
   sudo chown $gp:$gp /home/$gp/README.txt

done

#Now each group just logs in with:

#username: groupX (e.g group1)

#password: group123


#NOTES
#Avoid failure if the user already exists
sudo useradd -m -s /bin/bash "$gp" 2>/dev/null || echo "User $gp already exists"

#Force password change on first login
sudo chage -d 0 "$gp"

