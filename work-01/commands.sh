 curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
 yc version
 exec -l $SHELL
 yc version
 yc init
 yc version && yc config profile list && yc config get cloud-id && yc config get folder-id && yc config get compute-default-zone
 yc config list
 yc resource-manager folder list
 yc compute instance list
 yc vpc network list
 sudo apt install -y jq
 yc iam service-account get --name chavykin-06-sa >/dev/null 2>&1 || yc iam service-account create --name chavykin-06-sa
 export FOLDER_ID=$(yc config get folder-id)
 export SA_ID=$(yc iam service-account get --name chavykin-06-sa --format json | jq -r .id)
 echo "$FOLDER_ID $SA_ID"
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
 yc vpc subnet list
 yc compute instance create \\n--name "$PREFIX-web-1" \\n--zone "$ZONE" \\n--platform standard-v3 \\n--cores=2 \\n--core-fraction=20 \\n--memory=2 \\n--preemptible \\n--create-boot-disk image-folder-id=standard-images,image-family=ubuntu-2404-lts,type=network-hdd,size="$DISK_SIZE" \\n--network-interface subnet-name="$PREFIX-subnet",nat-ip-version=ipv4 \\n--ssh-key ~/.ssh/id_ed25519.pub \\n--labels created-by=cli
 yc compute instance list
 yc compute instance get "$PREFIX-web-1"
 yc compute instance get "$PREFIX-web-1" --format json \\n| jq -r '.network_interfaces[0].primary_v4_address.one_to_one_nat.address'
 export VM_IP=$(yc compute instance get "$PREFIX-web-1" --format json \\n| jq -r '.network_interfaces[0].primary_v4_address.one_to_one_nat.address')
 ssh yc_user@"$VM_IP"
 ssh -i ~/.ssh/id_ed25519 yc_user@"$VM_IP"
 ssh $(whoami)@"$VM_IP"
 cat ~/.ssh/id_ed25519.pub
 ssh -v -i ~/.ssh/id_ed25519 skrat@"$VM_IP"
 ssh ubuntu@"$VM_IP"
 ssh yc-user@"$VM_IP"
 sudo apt update
 sudo apt install -y nginx
 systemctl status nginx
 set +H
 sudo sed -i "s|Welcome to nginx!|netlab on $(hostname)|g" /var/www/html/index.nginx-debian.html
 exit
 yc compute instance list
 ssh yc-user@"$VM_IP"
 sudo hostnamectl set-hostname "chavykin-06-web-1"
 hostname
 set +H
 sudo sed -i "s|Welcome to nginx!|netlab on $(hostname)|g" /var/www/html/index.nginx-debian.html
 sudo sed -i "s|netlab on fv45laj80jtdbn6sfn9p|netlab on $(hostname)|g" /var/www/html/index.nginx-debian.html
 exit
 yc compute instance list --format json \\n | jq -r '.[] | "\(.name)\t\(.status)\t\(.network_interfaces[0].primary_v4_address.one_to_one_nat.address // "нет")"'
 yc compute instance list --format json | jq -r '.[] | select(.status != "RUNNING") | .name'
 yc compute instance delete "$PREFIX-web-1"
 yc vpc subnet delete "$PREFIX-subnet"
 yc vpc subnet delete "$PREFIX-net"
 yc vpc network list
 yc vpc network delete "$PREFIX-net"
 yc compute instance list && yc vpc network list && yc compute disk list
 history 50 | awk '{$1=""; print $0}' > commands.sh\n
