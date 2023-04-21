#!/bin/bash

# Comando para obter a porcentagem de uso da CPU
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')

# Saída das informações
echo "$cpu_usage%"
