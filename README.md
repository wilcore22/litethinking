# 🚀 Arquitectura Cloud en AWS con Terraform

Este repositorio contiene la definición de infraestructura como código (IaC) con **Terraform** para desplegar una solución web resiliente, elástica y altamente segura en **Amazon Web Services (AWS)**.

La solución implementa una topología de red dividida en **3 niveles de subredes** (Pública, Privada e Intranet/Database), un **Application Load Balancer (ALB)**, un **Auto Scaling Group (ASG)** para cómputo elástico y una base de datos **Amazon RDS (MySQL)**.

---

## 📐 Diagrama de Arquitectura

```text
                               ┌────────────────────────────────┐
                               │       🌐 Internet Users        │
                               └───────────────┬────────────────┘
                                               │ (Puerto 80/443)
                                               ▼
                                 ┌───────────────────────────┐
                                 │     Internet Gateway      │
                                 └─────────────┬─────────────┘
                                               │
                                               ▼
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│ 🌐 SUBRED PÚBLICA                                                                          │
│                                                                                             │
│  ┌──────────────────────────┐                          ┌─────────────────────────────────┐  │
│  │ Application LB (ALB)     │                          │ NAT Gateway                     │  │
│  │ (Distribuye el tráfico)  │                          │ (Salida a Internet para parches)│  │
│  └──────────┬───────────────┘                          └────────────────┬────────────────┘  │
└─────────────┼───────────────────────────────────────────────────────────┼───────────────────┘
              │                                                           │
              ▼                                                           ▼
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│ 🔒 SUBRED PRIVADA                                                                           │
│                                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────────────────────┐  │
│  │ Auto Scaling Group (EC2 + Nginx)                                                      │  │
│  │                                                                                       │  │
│  │   ┌───────────────┐               ┌───────────────┐               ┌───────────────┐   │  │
│  │   │ Instancia EC2 │               │ Instancia EC2 │               │ Instancia EC2 │   │  │
│  │   └───────────────┘               └───────────────┘               └───────────────┘   │  │
│  └───────────────────────────────────────┬───────────────────────────────────────────────┘  │
└──────────────────────────────────────────┼──────────────────────────────────────────────────┘
                                           │
                                           ▼ (Puerto 3306 - MySQL)
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│ 🛡️ SUBRED INTRANET / DATABASE (100% AISLADA)                                                 │
│                                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────────────────────┐  │
│  │ Amazon RDS (MySQL 8.0)                                                                │  │
│  │ (Sin ruta hacia Internet / Acceso interno exclusivo)                                  │  │
│  └───────────────────────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────────────────────┘


🧩 Componentes y Justificación Técnica
1. Componentes de Red
VPC (/16): Proporciona un entorno virtual dedicado y aislado dentro de AWS.

Internet Gateway (IGW): Permite la comunicación bidireccional entre la Subred Pública e Internet.

NAT Gateway: Permite que las instancias de la Subred Privada descarguen actualizaciones de software o parches desde Internet, sin quedar expuestas a conexiones entrantes 
desde el exterior.

2. Capa de Subredes (Aislamiento en 3 Niveles)
La red se distribuye en múltiples Zonas de Disponibilidad (AZs) para asegurar la Alta Disponibilidad (HA):


💡 Beneficios del Diseño en 3 Niveles:
Defensa en Profundidad: Múltiples barreras de seguridad antes de llegar a la capa de datos.

Elasticidad y Resiliencia: Soporta caídas de servidor o de zona de disponibilidad sin interrumpir el servicio.

Cumplimiento de Seguridad: Sigue las mejores prácticas de arquitectura de AWS (Well-Architected Framework).



3. Cómputo y Alta Disponibilidad
Application Load Balancer (ALB): Punto de entrada público. Evalúa la salud de las instancias mediante Health Checks continuos en el puerto 80.

Auto Scaling Group (ASG): Mantiene la cantidad óptima de instancias EC2.

Escalado Automático: Monitorea el uso de CPU vía Amazon CloudWatch para escalar dinámicamente de 1 a 3 instancias.

Aprovisionamiento Automático (user_data): Instala y configura automáticamente Nginx en cada máquina al crearse.


4. Capa de Datos (Persistencia)
Amazon RDS (MySQL 8.0):

Configurado en db.t3.micro con 20 GB SSD para optimizar el gasto y operar bajo la Capa Gratuita (Free Tier).

DB Subnet Group: Desplegado en las subredes de Intranet, garantizando aislamiento total.

Baja Latencia y Seguridad: Solo acepta solicitudes en el puerto 3306 provenientes del bloque CIDR interno de la VPC.

[ Internet ] ──(80/TCP)──> [ SG Load Balancer ]
                                     │
                                 (80/TCP)
                                     ▼
                            [ SG Instancias EC2 ]
                                     │
                                 (3306/TCP)
                                     ▼
                            [ SG Base de Datos ]
                            
                            
SG Load Balancer: Permite entrada HTTP (80) desde 0.0.0.0/0.

SG Instancias EC2: Permite entrada HTTP (80) únicamente desde el entorno de la VPC/ALB.

SG Base de Datos: Permite entrada MySQL (3306) únicamente desde el rango CIDR interno de la VPC (10.0.0.0/16).


🛠️ Guía de Uso y Despliegue
Requisitos Previos
Terraform v1.0 o superior.

AWS CLI configurado con credenciales activas.

Comandos de Ejecución
Inicializar módulos:

terraform init

Validar la infraestructura:

Bash
terraform plan
Desplegar en AWS:

Bash
terraform apply --auto-approve
Destruir recursos (Limpieza para evitar cobros):

Bash
terraform destroy --auto-approve


