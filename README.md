# 🚀 Arquitectura Cloud en AWS con Terraform - Prueba Técnica

Este proyecto despliega una infraestructura completa, segura, escalable y de alta disponibilidad en **Amazon Web Services (AWS)** utilizando **Terraform**. 

La arquitectura implementa una topología de red dividida en **3 niveles de subredes** (Pública, Privada e Intranet/Database), un **Application Load Balancer (ALB)**, un **Auto Scaling Group (ASG)** para cómputo elástico y una base de datos relacional **Amazon RDS (MySQL)**.

---

## 📐 Diagrama de Arquitectura

El flujo de tráfico y el aislamiento de componentes siguen el estándar de la industria:

```text
                       [ Internet ]
                            │
                            ▼
                  [ Internet Gateway ]
                            │
                            ▼
              ┌───────────────────────────┐
              │      Subred Pública       │
              │  ┌─────────────────────┐  │
              │  │ Application LB (ALB)│  │ ◄── Puerto 80 / 443
              │  └──────────┬──────────┘  │
              │             │             │
              │  ┌──────────▼──────────┐  │
              │  │    NAT Gateway      │  │ (Salida a Internet para parches/updates)
              │  └──────────┬──────────┘  │
              └─────────────┼─────────────┘
                            │
                            ▼
              ┌───────────────────────────┐
              │      Subred Privada       │
              │  ┌─────────────────────┐  │
              │  │ Auto Scaling Group  │  │ (Instancias EC2 + Nginx)
              │  │  [EC2]  [EC2]  [EC2]│  │ ◄── Sin IPs Públicas
              │  └──────────┬──────────┘  │
              └─────────────┼─────────────┘
                            │
                            ▼ (Puerto 3306)
              ┌───────────────────────────┐
              │      Subred Intranet      │
              │  ┌─────────────────────┐  │
              │  │  Amazon RDS (MySQL) │  │ ◄── 100% Aislada de Internet
              │  └─────────────────────┘  │
              └───────────────────────────┘
🧱 Componentes de la Arquitectura y Justificación1. Red y Conectividad (VPC & Gateways)VPC (/16): Proporciona un entorno virtual dedicado y aislado dentro de AWS.Internet Gateway (IGW): Permite la comunicación bidireccional entre los recursos alojados en la Subred Pública e Internet (necesario para el Load Balancer).NAT Gateway: Aloja en la subred pública y permite que las instancias de la Subred Privada tengan salida hacia Internet únicamente para descargar paquetes, parches de seguridad o dependencias, bloqueando cualquier conexión entrante originada desde el exterior.2. Capa de Subredes (Nivel de Aislamiento)Se implementó una estrategia de 3 tipos de subredes distribuidas en múltiples Zonas de Disponibilidad (AZs) para garantizar la Alta Disponibilidad (HA):SubredTipo de AccesoRecurso AlojadoJustificación de DiseñoPúblicaDirecto a Internet (vía IGW)Application Load Balancer (ALB) & NAT GatewayEs la primera línea de contacto con el usuario final. Filtra el tráfico antes de enviarlo a la capa de cómputo.PrivadaSalida vía NAT / Sin Ingress públicoAuto Scaling Group (EC2)Garantiza que las máquinas web no estén expuestas directamente a Internet. Tienen salida para actualizar software sin riesgo de ataques externos directos.Intranet (DB)Aislamiento Total (Sin ruta 0.0.0.0/0)Amazon RDS (MySQL)Máxima seguridad para los datos. La base de datos solo escucha tráfico en el puerto 3306 proveniente de la VPC.💡 ¿Por qué es buena esta división en 3 niveles?Defensa en Profundidad: Si un atacante compromete el Load Balancer, no tiene acceso directo a la máquina de la aplicación ni a la base de datos.Cumplimiento y Seguridad: Almacenar la base de datos en un nivel aislado de red cumple con estándares de cumplimiento como PCI-DSS o ISO 27001.Alta Disponibilidad: Al desplegar estas subredes a lo largo de varias Zonas de Disponibilidad, la aplicación tolera caídas a nivel de data center.3. Capa de Cómputo y EscalabilidadApplication Load Balancer (ALB): Recibe las solicitudes HTTP/HTTPS en el puerto 80 y distribuye el tráfico equitativamente entre las instancias saludables del Auto Scaling Group mediante Health Checks.Auto Scaling Group (ASG): * Administra la elasticidad del clúster de servidores web.Política de Auto Escalado: Ajusta automáticamente la capacidad (mínimo 1, deseado 1-2, máximo 3) monitoreando el consumo de CPU mediante métricas de Amazon CloudWatch.User Data Automatizado: En la inicialización, cada máquina ejecuta un script Bash (install.sh) que instala y configura Nginx sirviendo una página personalizada ("hola litethinking").4. Capa de Datos (Persistencia)Amazon RDS (MySQL 8.0):Agrupado dentro de un DB Subnet Group asociado a las subredes de Intranet.Security Group restringido: Solo acepta tráfico en el puerto 3306 proveniente del bloque CIDR privado de la VPC.Configurado en clase db.t3.micro y almacenamiento de 20 GB, optimizando el costo para operar bajo la Capa Gratuita (Free Tier).🛡️ Seguridad y Reglas de Tráfico (Security Groups)SG Load Balancer:Ingress: Puerto 80 (HTTP) desde 0.0.0.0/0.Egress: Todo el tráfico saliente (-1) hacia la VPC.SG Instancias EC2 (ASG):Ingress: Puerto 80 proveniente del Security Group del ALB o rango de la VPC.Egress: Todo el tráfico saliente (-1) para resolver consultas DNS y salir por el NAT Gateway.SG Base de Datos (RDS):Ingress: Puerto 3306 (MySQL) restringido únicamente al bloque CIDR interno (10.0.0.0/16).Egress: Respuesta de tráfico de red local.🛠️ Requisitos Previos e InstalaciónTener configurado el AWS CLI con credenciales válidas.Terraform instalado (v1.0+).Comandos para Desplegar:Bash# 1. Inicializar los módulos de Terraform
terraform init

# 2. Validar la sintaxis y plan de ejecución
terraform plan

# 3. Desplegar la infraestructura completa
terraform apply --auto-approve
Comandos para Limpiar Recurso (Destrucción):Para evitar cobros innecesarios en la cuenta de AWS tras realizar las pruebas:Bashterraform destroy --auto-approve
📌 Conclusiones de la SoluciónEsta infraestructura es altamente resiliente, segura y elástica:Resiliente: Soporta fallos de instancias o zonas gracias al ASG y ALB.Segura: Aplica el principio de menor privilegio a nivel de red con subredes privadas/intranet y reglas de Security Groups acotadas.Mantenible: Todo el código está modularizado en Terraform para facilitar la reutilización y el aprovisionamiento automatizado (Infraestructura como Código - IaC).
