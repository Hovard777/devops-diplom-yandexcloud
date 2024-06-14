#!/bin/bash
#Объявление переменных
sa_name="diplom"
storage_name="ifebres-tfstate"
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
