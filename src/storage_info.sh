#!/bin/bash

# Comando para obter informações de armazenamento
total_storage=$(df -h --output=size / | awk 'NR==2')
available_storage=$(df -h --output=avail / | awk 'NR==2')

# Saída das informações
echo "$total_storage$available_storage"
