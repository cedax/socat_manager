# Socat Manager

Un script bash para gestionar servicios socat que permiten redireccionar puertos TCP de forma automática y persistente usando systemd.

## Instalación de Tailscale

Tailscale es una VPN de malla que permite crear conexiones seguras entre dispositivos. Es útil para conectar servicios de forma segura a través de internet.

```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
tailscale status
```

**¿Qué hace cada comando?**
- `curl -fsSL https://tailscale.com/install.sh | sh`: Descarga e instala Tailscale
- `sudo tailscale up`: Inicia Tailscale y te pedirá autenticarte
- `tailscale status`: Muestra el estado de la conexión y las IPs asignadas

Una vez instalado, podrás usar las IPs de Tailscale (generalmente 100.x.x.x) para conectar servicios de forma segura entre diferentes dispositivos.

## Instalación del Script Socat Manager

## Configuración y Ejecución

```bash
chmod +x manager_socat.sh
./manager_socat.sh
```

## Personalización

Cambia tu usuario ya que el codigo usa el de `sedax`, cambia estas líneas al inicio del script:

```bash
USER_HOME="/home/tu_usuario"
USER_NAME="tu_usuario"
```

## Requisitos

- **socat**: Para redirección de puertos
- **systemd**: Para gestión de servicios
- **Permisos sudo**: Para crear servicios del sistema

### Instalar socat

```bash
# Ubuntu/Debian
sudo apt update && sudo apt install socat

# CentOS/RHEL/Fedora
sudo yum install socat
```

## Uso con Tailscale

Una vez que tengas Tailscale configurado, podrás usar las IPs de Tailscale como IP destino en el script. Por ejemplo:

- **Puerto local**: `8080`
- **IP destino**: `100.64.1.2` (IP de Tailscale de otro dispositivo)  
- **Puerto destino**: `80`

Esto creará un túnel seguro que redirige el puerto 8080 local hacia el puerto 80 de otro dispositivo en tu red Tailscale.