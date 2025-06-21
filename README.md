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

```bash
nano manager_socat.sh
```

Copia el siguiente código en el archivo:

```bash
#!/bin/bash
SERVICES_DIR="/etc/systemd/system"
USER_HOME="/home/sedax"
USER_NAME="sedax"

function crear_servicio() {
  read -rp "Puerto local a escuchar: " local_port
  read -rp "IP destino: " dest_ip
  read -rp "Puerto destino: " dest_port
  
  if [[ -z "$local_port" || -z "$dest_ip" || -z "$dest_port" ]]; then
    echo "No puedes dejar campos vacíos."
    return
  fi
  
  local script_name="socat_${local_port}.sh"
  local service_name="socat-${local_port}.service"
  local script_path="${USER_HOME}/${script_name}"
  local service_path="${SERVICES_DIR}/${service_name}"
  
  echo "#!/bin/bash" > "$script_path"
  echo "exec socat TCP-LISTEN:${local_port},fork TCP:${dest_ip}:${dest_port}" >> "$script_path"
  chmod +x "$script_path"
  echo "Script creado en $script_path"
  
  cat <<EOF | sudo tee "$service_path" > /dev/null
[Unit]
Description=Socat redirect port ${local_port} to ${dest_ip}:${dest_port}
After=network.target

[Service]
ExecStart=${script_path}
Restart=always
User=${USER_NAME}
WorkingDirectory=${USER_HOME}
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF
  
  echo "Servicio creado en $service_path"
  sudo systemctl daemon-reload
  sudo systemctl enable "$service_name"
  sudo systemctl start "$service_name"
  echo "Servicio $service_name iniciado y habilitado."
}

function listar_servicios() {
  echo "Servicios socat instalados:"
  ls "${SERVICES_DIR}"/socat-*.service 2>/dev/null | xargs -n1 basename || echo "No hay servicios socat instalados."
}

function controlar_servicio() {
  listar_servicios
  read -rp "Nombre del servicio a gestionar (ejemplo: socat-8450.service): " svc
  
  if [[ -z "$svc" ]]; then
    echo "No se ingresó servicio."
    return
  fi
  
  echo "Acciones:"
  echo "1) Iniciar"
  echo "2) Detener"
  echo "3) Reiniciar"
  echo "4) Eliminar"
  read -rp "Elige acción (1-4): " action
  
  case "$action" in
    1)
      sudo systemctl start "$svc"
      ;;
    2)
      sudo systemctl stop "$svc"
      ;;
    3)
      sudo systemctl restart "$svc"
      ;;
    4)
      sudo systemctl stop "$svc"
      sudo systemctl disable "$svc"
      sudo rm "${SERVICES_DIR}/${svc}"
      local port=$(echo "$svc" | grep -oP '(?<=socat-)[0-9]+(?=\.service)')
      if [[ -n "$port" ]]; then
        sudo rm "${USER_HOME}/socat_${port}.sh"
      fi
      sudo systemctl daemon-reload
      echo "Servicio $svc y script asociados eliminados."
      ;;
    *)
      echo "Opción no válida."
      ;;
  esac
}

function menu() {
  while true; do
    echo "====== Gestión de servicios socat ======"
    echo "1) Crear nuevo servicio"
    echo "2) Listar servicios instalados"
    echo "3) Controlar servicio (iniciar, detener, reiniciar, eliminar)"
    echo "4) Salir"
    read -rp "Elige una opción: " opt
    
    case "$opt" in
      1) crear_servicio ;;
      2) listar_servicios ;;
      3) controlar_servicio ;;
      4) exit 0 ;;
      *) echo "Opción inválida, intenta de nuevo." ;;
    esac
    echo
  done
}

menu
```

## Configuración y Ejecución

```bash
chmod +x manager_socat.sh
./manager_socat.sh
```

## Personalización

Si tu usuario no es `sedax`, cambia estas líneas al inicio del script:

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