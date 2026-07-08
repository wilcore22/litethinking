#!/bin/bash
# Prevenir preguntas interactivas durante la instalación
export DEBIAN_FRONTEND=noninteractive

# Actualizar el repositorio de paquetes e instalar Nginx
apt-get update -y
apt-get install nginx -y

# Asegurar que el servicio de Nginx inicie y se mantenga activo
systemctl enable nginx
systemctl start nginx

# Generar el archivo index.html con tu mensaje personalizado
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
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
        .card {
            background: white;
            padding: 40px;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            text-align: center;
        }
        h1 {
            color: #2c3e50;
            margin: 0;
        }
    </style>
</head>
<body>
    <div class="card">
        <h1>hola litethinking</h1>
    </div>
</body>
</html>
EOF