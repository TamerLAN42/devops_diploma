# Сети
resource "yandex_vpc_network" "k8s" {
  name = "k8s-network"
}

resource "yandex_vpc_subnet" "a" {
  name           = "subnet-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.k8s.id
  v4_cidr_blocks = ["10.1.0.0/24"]
}

# Сервисные аккаунты и роли
resource "yandex_iam_service_account" "k8s" {
  name = "k8s-cluster-sa"
}

resource "yandex_resourcemanager_folder_iam_member" "k8s_agent" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.k8s.id}"
}

resource "yandex_iam_service_account" "k8s_nodes" {
  name = "k8s-nodes-sa"
}

resource "yandex_resourcemanager_folder_iam_member" "k8s_nodes_puller" {
  folder_id = var.folder_id
  role      = "container-registry.images.puller"
  member    = "serviceAccount:${yandex_iam_service_account.k8s_nodes.id}"
}

# Кластер
resource "yandex_kubernetes_cluster" "cluster" {
  name        = "momo-cluster"
  network_id  = yandex_vpc_network.k8s.id
  
  master {
    version   = "1.33"
    public_ip = true  
	zonal {
		zone      = yandex_vpc_subnet.a.zone
		subnet_id = yandex_vpc_subnet.a.id
	}
  }
  
  service_account_id = yandex_iam_service_account.k8s.id
  node_service_account_id = yandex_iam_service_account.k8s_nodes.id
  depends_on = [yandex_iam_service_account.k8s, yandex_iam_service_account.k8s_nodes, yandex_resourcemanager_folder_iam_member.k8s_agent, yandex_resourcemanager_folder_iam_member.k8s_nodes_puller]
}

# Группа нод
resource "yandex_kubernetes_node_group" "main" {
  cluster_id = yandex_kubernetes_cluster.cluster.id
  name       = "main-nodes"
  
  instance_template {
    platform_id = "standard-v2"
    resources {
      cores  = 2
      memory = 4
    }
    
    boot_disk {
      type = "network-hdd"
      size = 64
    }
    
    network_interface {
      subnet_ids = [yandex_vpc_subnet.a.id]
      nat        = true
    }
  }
  
  scale_policy {
    fixed_scale {
      size = 1
    }
  }
}