Cómo acceder a nginx-app a través del Ingress Controller
Configuración actual
Basándome en tus archivos, tu configuración está bien estructurada. Aquí te explico cómo funciona:

1. Acceso a la aplicación
Para acceder a tu aplicación nginx, necesitas:

```
echo "127.0.0.1 test.local" | sudo tee -a /etc/hosts
```

Configurar el host en tu máquina local:
Acceder a través del NodePort del Ingress Controller:
    HTTP: http://test.local:32080
    HTTPS: https://test.local:32443
2. Diagrama de la configuración

```mermaid
graph TB
    Client[Cliente/Navegador] --> Host[Host: test.local:32080]
    Host --> NodePort[NodePort Service<br/>Puerto 32080/32443]
    NodePort --> IngressController[NGINX Ingress Controller<br/>Pod]
    IngressController --> IngressRule[Ingress Rule<br/>host: test.local]
    IngressRule --> ClusterIP[nginx-service<br/>ClusterIP:80]
    ClusterIP --> Pod1[nginx-app Pod 1<br/>:80]
    ClusterIP --> Pod2[nginx-app Pod 2<br/>:80]
    Pod1 --> ConfigMap[nginx-html ConfigMap]
    Pod2 --> ConfigMap

    subgraph "Kubernetes Cluster"
        subgraph "nginx-app-ns Namespace"
            IngressRule
            ClusterIP
            Pod1
            Pod2
            ConfigMap
        end
        subgraph "ingress-nginx Namespace"
            IngressController
        end
        NodePort
    end

    style Client fill:#e1f5fe
    style NodePort fill:#f3e5f5
    style IngressController fill:#fff3e0
    style ClusterIP fill:#e8f5e8
    style Pod1 fill:#fff8e1
    style Pod2 fill:#fff8e1
```

3. Cómo funciona la red en Kubernetes
Conceptos clave:
Pod Network: Cada Pod tiene su propia IP dentro del cluster
Service Network: Los Services proporcionan IPs estables para grupos de Pods
Node Network: La red física de los nodos del cluster
Tipos de Services:
ClusterIP (por defecto): Solo accesible dentro del cluster
NodePort: Expone el servicio en un puerto de cada nodo
LoadBalancer: Para clusters en cloud con load balancer externo
Flujo de red en tu configuración:

```mermaid
sequenceDiagram
    participant C as Cliente
    participant N as Nodo (NodePort)
    participant IC as Ingress Controller
    participant S as nginx-service
    participant P as nginx Pod

    C->>N: HTTP a test.local:32080
    N->>IC: Reenvía a Ingress Controller
    IC->>IC: Analiza Host header (test.local)
    IC->>IC: Aplica reglas de Ingress
    IC->>S: Proxy a nginx-service:80
    S->>P: Load balancing a Pod
    P->>S: Respuesta HTTP
    S->>IC: Respuesta
    IC->>N: Respuesta
    N->>C: Respuesta final
```
4. Componentes de red involucrados:
Ingress Controller (NGINX):

Actúa como proxy reverso
Lee las reglas de Ingress
Enruta tráfico basándose en host/path
Service (ClusterIP):

Proporciona load balancing
IP estable para los Pods
DNS interno: nginx-service.nginx-app-ns.svc.cluster.local
Pods:

Ejecutan la aplicación nginx
Cada uno tiene su IP única
Se registran automáticamente en el Service
5. Verificación
Esta configuración te permite acceder a tu aplicación nginx a través de un nombre de host limpio, mientras el Ingress Controller maneja el enrutamiento interno del cluster.