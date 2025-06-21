#!/data/data/com.termux/files/usr/bin/bash

function crear_redireccion() {
  read -rp "Puerto local a escuchar: " local_port
  read -rp "IP destino: " dest_ip
  read -rp "Puerto destino: " dest_port

  if [[ -z "$local_port" || -z "$dest_ip" || -z "$dest_port" ]]; then
    echo "No puedes dejar campos vacíos."
    return
  fi

  echo "Levantando socat: TCP-LISTEN:${local_port} → TCP:${dest_ip}:${dest_port}"
  nohup socat TCP-LISTEN:${local_port},fork TCP:${dest_ip}:${dest_port} >/dev/null 2>&1 &
  echo "Redirección levantada en segundo plano (PID $!)"
}

function menu() {
  while true; do
    echo "====== Redirección con Socat (Termux) ======"
    echo "1) Crear nueva redirección temporal"
    echo "2) Salir"
    read -rp "Elige una opción: " opt

    case "$opt" in
      1) crear_redireccion ;;
      2) exit 0 ;;
      *) echo "Opción inválida, intenta de nuevo." ;;
    esac
    echo
  done
}

menu