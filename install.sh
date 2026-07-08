#!/bin/bash
# Esperar un par de segundos a que la red de AWS se estabilice por completo
sleep 15

# Forzar la actualización del sistema e instalación de Nginx sin preguntar nada
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install nginx -y

# Asegurar que Nginx esté activo y corriendo
systemctl enable nginx
systemctl start nginx

# Crear la página de LiteThinking
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
    <title>LiteThinking Test</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f9;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }
        h1 {
            color: #333;
            padding: 20px;
            background: white;
            border-radius: 8px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
    </style>
</head>
<body>
    <h1>hola litethinking</h1>
</body>
</html>
EOF