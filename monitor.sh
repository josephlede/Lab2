#!/bin/bash
variables="$#"
comando="$1"
comando_base=$(echo "$comando" | awk '{print $1}')
intervalo="$2"

if [ $variables -eq 0 ]; then
  echo "Uso: ./monitor.sh <comando> [intervalo]"
  exit 1
fi
if [ $variables -eq 1 ]; then
  intervalo="2"
  echo "Cantidad de argumentos correcta"
fi
if [ $variables -eq 2 ]; then
  echo "Cantidad de argumentos correcta"
fi
if [ $variables -gt 2 ]; then
  echo "Uso: ./monitor.sh <comando> [intervalo]"
  exit 2
fi

if command -v "$comando_base" >/dev/null 2>&1 ; then
  $comando > /dev/null 2>&1 &
  pid="$!"
 
else 
  echo "Error: comando '$comando_base' no encontrado"
  exit 3
fi
inicio_epoch=$(date +%s)   


grafica_generada() {
  
  if [ -s "datos_$pid.dat" ]; then
    gnuplot << EOF
    set terminal png
    set output "monitor_$pid.png"
    set title "Monitor de $comando_base (PID $pid)"
    set xlabel "Tiempo (s)"
    set ylabel "CPU (%)"
    set y2label "Memoria RSS (KB)"
    set ytics nomirror
    set y2tics
    plot "datos_$pid.dat" using 1:2 with lines title "CPU", \
         "datos_$pid.dat" using 1:3 with lines title "RSS" axes x1y2
EOF
    echo "Gráfica generada: monitor_$pid.png"
  else
    echo "No hay datos para generar gráfica."
  fi
}
trap 'echo "Interrupción recibida. Terminando proceso $pid..."; kill -SIGTERM $pid; sleep 1; grafica_generada; exit' SIGINT

while kill -0 $pid 2>/dev/null; do
  sleep $intervalo

  
  datos=$(ps -p $pid -o %cpu,%mem,rss --no-headers 2>/dev/null)
  if [ -z "$datos" ]; then
    
    break
  fi

  cpu=$(echo $datos | awk '{print $1}')
  rss=$(echo $datos | awk '{print $3}')   # en KB

  ahora=$(date +%s)
  transcurrido=$((ahora - inicio_epoch))

  echo "$transcurrido $cpu $rss" >> "datos_$pid.dat"
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo "$timestamp $cpu $rss" >> "monitor_$pid.log"
done
echo "El proceso $pid ha terminado. Generando gráfica..."
grafica_generada

exit 0
