#!/bin/bash
#Объявление переменных
sa_name="diplom"
storage_name="ifebres-tfstate"
ansible_user="ifebres"
#Export cloud_id
yc_cloud=$(yc config get cloud-id 2>/dev/null)
export YC_CLOUD_ID=$yc_cloud
#Export folder_id
yc_folder=$(yc config get folder-id 2>/dev/null)
export YC_FOLDER_ID=$yc_folder
#Создадим сервисный аккаунт diplom
yc iam service-account create $sa_name
#Добавим права доступа
yc iam service-account add-access-binding --name $sa_name --role editor --service-account-name $sa_name
#Добавим права на каталог
yc resource-manager folder --id $YC_FOLDER_ID add-access-binding --role editor --service-account-name $sa_name
#Генерируем access file
yc iam key create --service-account-name $sa_name -o ~/sa_file.json
#Генерируем access key
yc iam access-key create --service-account-name $sa_name --format json > ~/sa_key.json
access_key=$(cat ~/sa_key.json | jq -r .access_key.key_id)
secret_key=$(cat ~/sa_key.json | jq -r .secret)
# Создание S3 бакета
yc storage bucket create --name $storage_name
#Запускаем создание инфраструктуры
cd terraform
terraform init -reconfigure -backend-config="access_key=$access_key" -backend-config="secret_key=$secret_key" -backend-config="bucket=$storage_name"
#terraform plan
terraform apply --auto-approve
# Переход в директорию ansible
cd ../ansible
# Генерирование динамического inventory на основе вывода утилиты управления Яндекс.Облаком

VM_LIST_CMD=$(printenv VM_LIST_CMD || echo "yc compute instance list --format json") # получение списка инстансов

# Функция поиска инстансов по заданному патерну
fetch_instances() {
    local pattern=$1
    local instances=$(eval "$VM_LIST_CMD" | jq "[ .[] | select(.name | match(\"$pattern\")) ]")
    echo "$instances"
}

# Функция обновления инвентарного файла
update_inventory_file() {
    local host=$1
    local ansible_host=$2
    local ansible_user=$3
    local ip=$4
    sed -i "/${host}:/,/ansible_ssh_private_key_file=/s/ansible_host: .*/ansible_host: ${ansible_host}/" hosts.yaml
    sed -i "/${host}:/,/ansible_ssh_private_key_file=/s/ansible_user: .*/ansible_user: ${ansible_user}/" hosts.yaml
    sed -i "/${host}:/,/ansible_ssh_private_key_file=/s/ip: .*/ip: ${ip}/" hosts.yaml
}

# Поиск Kubernetes master instances
kube_master_instances=$(fetch_instances "master-*")

# Добавление master instances в инвентарник
for instance in $(echo "$kube_master_instances" | jq -r '.[] | @base64'); do
    _jq() {
        echo ${instance} | base64 --decode | jq -r ${1}
    }
    ansible_host=$(_jq '.network_interfaces[0].primary_v4_address.one_to_one_nat.address')
    ip=$(_jq '.network_interfaces[0].primary_v4_address.address')
    host=$(_jq '.name')
    echo "${host} ansible_host=${ansible_host}    ansible_user=${ansible_user}    ip:${ip}   ansible_ssh_private_key_file=~/.ssh/id_rsa"
    update_inventory_file ${host} ${ansible_host} ${ansible_user} ${ip}
done

# Поиск Kubernetes worker instances
kube_worker_instances=$(fetch_instances "worker-*")

# Добавление worker instances в инвентарник
for instance in $(echo "$kube_worker_instances" | jq -r '.[] | @base64'); do
    _jq() {
        echo ${instance} | base64 --decode | jq -r ${1}
    }
    ansible_host=$(_jq '.network_interfaces[0].primary_v4_address.one_to_one_nat.address')
    ip=$(_jq '.network_interfaces[0].primary_v4_address.address')
    host=$(_jq '.name')
    echo "${host} ansible_host=${ansible_host}    ansible_user=${ansible_user}    ip:${ip}   ansible_ssh_private_key_file=~/.ssh/id_rsa"
    update_inventory_file ${host} ${ansible_host} ${ansible_user} ${ip}
done

