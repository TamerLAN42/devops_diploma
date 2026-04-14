# Momo Store aka Пельменная №2

<img width="900" alt="image" src="https://user-images.githubusercontent.com/9394918/167876466-2c530828-d658-4efe-9064-825626cc6db5.png">

## Frontend

```bash
npm install
NODE_ENV=production VUE_APP_API_URL=http://localhost:8081 npm run serve
```

## Backend

```bash
go run ./cmd/api
go test -v ./... 
```

## Terraform configuration

Для создания ресурсов необходимо указать переменные окружения проекта:
- AWS_ACCESS_KEY_ID - ID статичного ключа сервисного аккаунта с ролью editor для доступа к бакету хранения состояния tfstate
- AWS_SECRET_ACCESS_KEY - Секретный ключ для тех-же целей ^^^
- TERRAFORMRC_B64 - Закодированный в Base64 конфиг terraformrc с указанием зеркала для загрузки провайдера yandex cloud
- TF_KEY_B64 - Закодированный в Base64 json авторизованного ключа для сервисного аккаунта с ролью admin. Через него производится создание и настройка ресурсов. Роль admin здесь нужна для создания служебных (кластерных )сервисных аккаунтов и назначения им ролей
- TF_VAR_cloud_id - ID облака yandex cloud
- TF_VAR_folder_id - ID каталога yandex cloud

При изменении манифестов ресурсов, описанных в репозитории, автоматически запустится пайп по применению изменеий.  
Destroy-пайп запускается отдельно, и требует успешно завершённого пайпа создания кластера. Простыми словами - чтобы что-то удалить, надо что-то создать.

## K8s configuration

### Конфигурация доступов

Нужны 2 сервисных аккаунта - для конфигурации кластера, и для деплоя самого приложения.

Первый - admin-user
```bash
kubectl create serviceaccount admin-user -n kube-system

kubectl create clusterrolebinding admin-binding \
  --clusterrole=cluster-admin \
  --serviceaccount=kube-system:admin-user

kubectl create token admin-user -n kube-system
```

Второй - momo-user с собственным namespace для приложения.
```bash
kubectl create namespace momo-app

kubectl create serviceaccount momo-user -n momo-app

kubectl create rolebinding momo-admin-binding \
  --clusterrole=admin \
  --serviceaccount=momo-app:momo-user \
  -n momo-app

kubectl create token momo-user -n momo-app
```

Полученные токены используем для создания kubeconfig, кодируем конфиги в B64 и раскладываем в переменные окружения проекта ADMIN_KUBECONFIG_B64 и KUBE_CONFIG_B64 соответственно.

### Установка ingress-контроллера

Запускается вручную в веб-интерфейсе gitlab.  

Модульный пайплайн kuber подключит репозиторий ingress-nginx и установит helm-чарт в кластер.  

Повторным запуском пайплайна можно обновить контроллер до последней версии.