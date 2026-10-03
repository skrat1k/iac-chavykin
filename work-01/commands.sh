 curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
 yc init
 sudo apt install -y jq
 yc iam service-account get --name chavykin-06-sa >/dev/null 2>&1 || yc iam service-account create --name chavykin-06-sa
 export FOLDER_ID=$(yc config get folder-id)
 export SA_ID=$(yc iam service-account get --name chavykin-06-sa --format json | jq -r .id)
 yc resource-manager folder add-access-binding "$FOLDER_ID" --role editor --subject "serviceAccount:$SA_ID"
 set +H
 mkdir -p ~/.yc-keys
 if [ ! -s ~/.yc-keys/chavykin-06-key.json ]; then yc iam key create --service-account-name chavykin-06-sa --output ~/.yc-keys/chavykin-06-key.json; fi
 export PREFIX=chavykin-06
 export ZONE=ru-central1-d
 export CIDR=10.16.1.0/24
 export DISK_SIZE=25
 yc vpc network create --name "$PREFIX-net"
 yc vpc subnet create --name "$PREFIX-subnet" --network-name "$PREFIX-net" --zone "$ZONE" --range "$CIDR"
 yc compute instance create \\n--name "$PREFIX-web-1" \\n--zone "$ZONE" \\n--platform standard-v3 \\n--cores=2 \\n--core-fraction=20 \\n--memory=2 \\n--preemptible \\n--create-boot-disk image-folder-id=standard-images,image-family=ubuntu-2404-lts,type=network-hdd,size="$DISK_SIZE" \\n--network-interface subnet-name="$PREFIX-subnet",nat-ip-version=ipv4 \\n--ssh-key ~/.ssh/id_ed25519.pub \\n--labels created-by=cli
 yc compute instance get "$PREFIX-web-1" --format json \\n| jq -r '.network_interfaces[0].primary_v4_address.one_to_one_nat.address'
 export VM_IP=$(yc compute instance get "$PREFIX-web-1" --format json \\n| jq -r '.network_interfaces[0].primary_v4_address.one_to_one_nat.address')
 ssh yc-user@"$VM_IP"
 sudo apt update
 sudo apt install -y nginx
 systemctl status nginx
 set +H
 sudo sed -i "s|Welcome to nginx!|netlab on $(hostname)|g" /var/www/html/index.nginx-debian.html
 exit
 ssh yc-user@"$VM_IP"
 sudo hostnamectl set-hostname "chavykin-06-web-1"
 set +H
 sudo sed -i "s|Welcome to nginx!|netlab on $(hostname)|g" /var/www/html/index.nginx-debian.html
 sudo sed -i "s|netlab on fv45laj80jtdbn6sfn9p|netlab on $(hostname)|g" /var/www/html/index.nginx-debian.html
 exit
 yc compute instance delete "$PREFIX-web-1"
 yc vpc subnet delete "$PREFIX-subnet"
 yc vpc network delete "$PREFIX-net"
