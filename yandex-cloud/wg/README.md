# Сборка образа с настроенным Wireguard VPN

### Предварительно
Для предварительной настройки конфигов и ключей нужна ВМ с установленной Ubunto 20.04 (или на любой другой вкус), и установленным там Wireguard.
```bash
sudo cat >> /etc/wireguard/wg0.conf << EOF
[Interface]
Address = 172.29.30.1/24
PostUp = ufw route allow in on wg0 out on eth0
PostUp = iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE
PostUp = ip6tables -t nat -I POSTROUTING -o eth0 -j MASQUERADE
PreDown = ufw route delete allow in on wg0 out on eth0
PreDown = iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
PreDown = ip6tables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
ListenPort = 51820
EOF
wg genkey | sudo tee /etc/wireguard/private.key
sudo chmod go= /etc/wireguard/private.key
sudo cat /etc/wireguard/private.key | wg pubkey | sudo tee /etc/wireguard/public.key
echo -e "PrivateKey = $(sudo cat /etc/wireguard/private.key)\n" | sudo tee -a /etc/wireguard/wg0.conf
# peers
cd ~
WG_CL_NAME="wg-client"; wg genkey | tee ${WG_CL_NAME}-private.key | wg pubkey > ${WG_CL_NAME}-public.key
cat >> ${WG_CL_NAME}.conf << EOF
[Interface]
Address = 172.29.30.3/32
PrivateKey = $(cat ${WG_CL_NAME}-private.key)
DNS = 8.8.8.8

[Peer]
PublicKey = $(sudo cat /etc/wireguard/public.key)
AllowedIPs = 0.0.0.0/0
Endpoint = wg.example.com:51820
EOF

echo -e "\n[Peer]\nPublicKey = $(cat ${WG_CL_NAME}-public.key)\nAllowedIPs = 172.29.30.3/32" | sudo tee -a /etc/wireguard/wg0.conf
sudo systemctl restart wg-quick@wg0.service

sudo apt install qrencode
qrencode -t ansiutf8 < ${WG_CL_NAME}.conf

sudo tar czvf /tmp/wg.tgz /etc/wireguard

# на локальном компьютере
scp <remote_temporary_host>:/tmp/wg.tgz files/sensitive/
```

### Сборка образа
```bash
export YC_FOLDER_ID=$(yc config get folder-id)
export YC_TOKEN=$(yc iam create-token)
packer validate . && packer build .
```

### Ссылки
1. По мотивам [статьи](https://habr.com/ru/post/486452/)