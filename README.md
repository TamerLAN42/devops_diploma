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

## K8s configuration

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