#!/bin/bash
# update-bluegreen.sh - Actualización sin downtime

echo "🚀 INICIANDO BLUE-GREEN DEPLOYMENT"

# 1. Crear nuevo ASG con versión actualizada
echo "📦 Creando ASG VERDE con SO actualizado..."
aws autoscaling create-auto-scaling-group \
    --auto-scaling-group-name WebServer-Green \
    --launch-template LaunchTemplateName=WebServer-v2 \
    --min-size 2 --max-size 5 --desired-capacity 2 \
    --vpc-zone-identifier "subnet-abc,subnet-def"

# 2. Esperar que los servidores estén listos
echo "⏳ Esperando 60 segundos para inicialización..."
sleep 60

# 3. Añadir servidores VERDES al Load Balancer
echo "🔄 Añadiendo servidores VERDES al Load Balancer..."
aws elbv2 register-targets \
    --target-group-arn arn:aws:elasticloadbalancing:us-east-1:XXX:targetgroup/WebTG/XXX \
    --targets Id=$(aws ec2 describe-instances --filters "Name=tag:aws:autoscaling:groupName,Values=WebServer-Green" --query 'Reservations[*].Instances[*].InstanceId' --output text)

# 4. Verificar health checks
echo "🏥 Verificando health checks..."
sleep 30
HEALTHY=$(aws elbv2 describe-target-health --target-group-arn arn:aws:elasticloadbalancing:us-east-1:XXX:targetgroup/WebTG/XXX --query 'TargetHealthDescriptions[?TargetHealth.State==`healthy`]' --output text | wc -l)

if [ $HEALTHY -ge 2 ]; then
    echo "✅ Todos los servidores VERDES están saludables"
    
    # 5. Eliminar servidores AZULES
    echo "🗑️ Eliminando servidores AZULES..."
    aws autoscaling delete-auto-scaling-group \
        --auto-scaling-group-name WebServer-Blue \
        --force-delete
    
    echo "✅ ¡Actualización completada con éxito!"
else
    echo "❌ ERROR: Servidores VERDES no están saludables"
    echo "🔄 HACIENDO ROLLBACK..."
    
    # Rollback: eliminar VERDES
    aws autoscaling delete-auto-scaling-group \
        --auto-scaling-group-name WebServer-Green \
        --force-delete
    
    echo "✅ Rollback completado, servicios en AZULES"
    exit 1
fi