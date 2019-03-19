HostName=
Organization=
GUID=$(cat /proc/sys/kernel/random/uuid)

systemctl stop remotely-agent
rm -r -f /usr/local/bin/Remotely
rm -f /etc/systemd/system/remotely-agent.service
systemctl daemon-reload

if [ "$1" = "--uninstall" ]; then
	exit
fi

apt-get install unzip

mkdir -p /usr/local/bin/Remotely/
cd /usr/local/bin/Remotely/

if [ "$1" = "--path" ]; then
    echo  "Copying install files..."
	cp $2 /usr/local/bin/Remotely/Remotely-Linux.zip
else
    echo  "Downloading client..."
	wget $HostName/Downloads/Remotely-Linux.zip
fi

unzip ./Remotely-Linux.zip
chmod +x ./Remotely_Agent

cat > ./ConnectionInfo.json << EOL
{
	"DeviceID":"$GUID", 
	"Host":"$HostName",
	"OrganizationID": "$Organization",
	"ServerVerificationToken":""
}
EOL


echo Creating service...

cat > /etc/systemd/system/remotely-agent.service << EOL
[Unit]
Description=The Remotely agent used for remote access.

[Service]
WorkingDirectory=/usr/local/bin/Remotely/
ExecStart=/usr/local/bin/Remotely/Remotely_Agent
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOL

systemctl enable remotely-agent
systemctl start remotely-agent

echo Install complete.