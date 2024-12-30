#!/bin/sh

# ^c$var^ = fg color
# ^b$var^ = bg color

interval=0

# load colors
. ~/.config/chadwm/scripts/bar_themes/catppuccin

#cpu() {
#  cpu_val=$(grep -o "^[^ ]*" /proc/loadavg)
#
#  printf "^c$black^ ^b$green^ CPU"
#  printf "^c$white^ ^b$grey^ $cpu_val"
#}

cpu() {
  cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')

  printf "^c$black^ ^b$green^ CPU"
  printf "^c$white^ ^b$grey^ $cpu_usage%%"
}

pkg_updates() {
  updates=$({ timeout 20 eix --outdated 2>/dev/null || true; } | wc -l)
  if [ -z "$updates" ] || [ "$updates" -eq 0 ]; then
    printf "  ^c$green^    Fully Updated"
  else
    printf "  ^c$green^    $updates updates"
  fi
}

battery() {
  get_capacity="$(cat /sys/class/power_supply/BAT1/capacity)"
  printf "^c$blue^   $get_capacity"
}

brightness() {
  local red="#F38BA8"  # Catppuccin Mocha Red
  local brightness=$(ddcutil getvcp 10 --brief | awk '{print $4}')
  if [ -z "$brightness" ]; then
    printf "^c$red^  "
    printf "^c$red^Unavailable\n"
  else
    printf "^c$red^  "
    printf "^c$red^%.0f\n" "$brightness"
  fi
}

#mem() {
#  printf "^c$blue^^b$black^  "
#  printf "^c$blue^ $(free -h | awk '/^Mem/ { print $3 }' | sed s/i//g)"
#}

mem() {
  used_mem=$(free -h | awk '/^Mem/ {print $3}' | sed s/i//g)
  total_mem=$(free -h | awk '/^Mem/ {print $2}' | sed s/i//g)

  printf "^c$blue^^b$black^  "
  printf "^c$blue^ $used_mem / $total_mem"
}

ethernet() {
	case "$(cat /sys/class/net/en*/operstate 2>/dev/null)" in
	up) printf "^c$black^ ^b$blue^ 󰤨 ^d^%s" " ^c$blue^Connected" ;;
	down) printf "^c$black^ ^b$blue^ 󰤭 ^d^%s" " ^c$blue^Disconnected" ;;
	esac
}

clock() {
	printf "^c$black^ ^b$darkblue^ 󱑆 "
	printf "^c$black^^b$blue^ $(date '+%a %b %d - %H:%M') "
}

while true; do

  [ $interval = 0 ] || [ $(($interval % 3600)) = 0 ] && updates=$(pkg_updates)
  interval=$((interval + 1))

  sleep 1 && xsetroot -name "$updates $(brightness) $(cpu) $(mem) $(ethernet) $(clock)"
done
