# Сборка образа с настроенным Wireguard VPN

### Предварительно
Для предварительной настройки конфигов и ключей нужна ВМ с установленной Ubunto 20.04 (или на любой другой вкус), и установленным там Wireguard.
```bash
sudo cat >> wg0.conf << EOF
[Interface]
Address = 172.29.30.1/24
SaveConfig = true
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
wg genkey | tee wg-client-private.key | wg pubkey > wg-client-public.key
```

```bash
export YC_FOLDER_ID=$(yc config get folder-id)
export YC_TOKEN=$(yc iam create-token)
```
