#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present DiegroSan
#

. /etc/profile

LOGSDIR="/emuelec/logs"
LOGFILE="$LOGSDIR/ikemen.log"
SHARED="/usr/share/ikemen_go"
CONFIGDIRHOME="/tmp/ikemen"

# Language log Configuration by DiegroSan
config_file="/storage/.config/emuelec/configs/emuelec.conf"

language_value=$(grep '^system.language=' "$config_file" | cut -d'=' -f2)

if [ "$language_value" = "pt_BR" ]; then
    MESSAGE_001="Erro: Nenhum arquivo foi passado como argumento."
    MESSAGE_002="Nome do jogo:"
    MESSAGE_003="Diretório de Temporário:"
    MESSAGE_004="Diretório do arquivo:"
    MESSAGE_005="Aliando dependências do Ikemen_Go:"
    MESSAGE_006="Links simbólicos criados com sucesso."
    MESSAGE_007="Erro ao criar links simbólicos."
    MESSAGE_008="Verificação dos arquivos do Ikemen_Go"
    MESSAGE_009="Usando Ikemen_Go de B"
    MESSAGE_010="Usando Ikemen_Go de A"
    MESSAGE_011="Falha ao copiar $file"
    MESSAGE_012="Falha ao copiar diretório external"
    MESSAGE_013="Falha ao copiar arquivos de fonte"
    MESSAGE_014="Arquivo de configuração não encontrado:"
    MESSAGE_015="Sem permissão de escrita em:"
    MESSAGE_016="Executável Ikemen_Go não encontrado ou sem permissão de execução"
elif [ "$language_value" = "es_ES" ]; then
    MESSAGE_001="Error: No se pasó ningún archivo como argumento."
    MESSAGE_002="Nombre del juego:"
    MESSAGE_003="Directorio temporal:"
    MESSAGE_004="Directorio del archivo:"
    MESSAGE_005="Alineando dependencias do Ikemen_Go:"
    MESSAGE_006="Enlaces simbólicos creados con éxito."
    MESSAGE_007="Error al crear enlaces simbólicos."
    MESSAGE_008="Verificación de los archivos de Ikemen_Go"
    MESSAGE_009="Usando Ikemen_Go de B"
    MESSAGE_010="Usando Ikemen_Go de A"
    MESSAGE_011="Error al copiar $file"
    MESSAGE_012="Error al copiar el directorio external"
    MESSAGE_013="Error al copiar archivos de fuente"
    MESSAGE_014="Archivo de configuración no encontrado:"
    MESSAGE_015="Sin permiso de escritura en:"
    MESSAGE_016="Ejecutable Ikemen_Go no encontrado o sin permiso de ejecución"
elif [ "$language_value" = "zh_CN" ]; then
    MESSAGE_001="错误：没有文件作为参数传递。"
    MESSAGE_002="游戏名称："
    MESSAGE_003="临时目录："
    MESSAGE_004="文件目录："
    MESSAGE_005="对齐文件依赖关系："
    MESSAGE_006="符号链接创建成功。"
    MESSAGE_007="创建符号链接时出错。"
    MESSAGE_008="验证Ikemen_Go文件"
    MESSAGE_009="使用 B 中的 Ikemen_Go"
    MESSAGE_010="使用 A 中的 Ikemen_Go"
    MESSAGE_011="复制失败 $file"
    MESSAGE_012="复制external目录失败"
    MESSAGE_013="复制字体文件失败"
    MESSAGE_014="未找到配置文件："
    MESSAGE_015="没有写入权限："
    MESSAGE_016="找不到Ikemen_Go可执行文件或没有执行权限"
else
    MESSAGE_001="Error: No file was passed as an argument."
    MESSAGE_002="Game name:"
    MESSAGE_003="Temp Directory:"
    MESSAGE_004="File directory:"
    MESSAGE_005="Aligning Ikemen_Go dependencies:"
    MESSAGE_006="Symbolic links created successfully."
    MESSAGE_007="Error creating symbolic links."
    MESSAGE_008="Verifying Ikemen_Go files"
    MESSAGE_009="Using Ikemen_Go from B"
    MESSAGE_010="Using Ikemen_Go from A"
    MESSAGE_011="Failed to copy $file"
    MESSAGE_012="Failed to copy external directory"
    MESSAGE_013="Failed to copy font files"
    MESSAGE_014="Configuration file not found:"
    MESSAGE_015="No write permission in:"
    MESSAGE_016="Ikemen_Go executable not found or no execution permission"
fi

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOGFILE"
}

if [ ! -f "$config_file" ]; then
    log "$MESSAGE_014 $config_file"
    exit 1
fi

mkdir -p "$CONFIGDIRHOME"
mkdir -p "$LOGSDIR"
rm -f "$LOGFILE"

killall gptokeyb 2>/dev/null

[ -z "$1" ] && { log "$MESSAGE_001"; exit 1; }

OB="$1"
GAME=$(basename "${OB%.*}")
CONFIGDIR="$CONFIGDIRHOME/$GAME"
IKEMEN=$(dirname "$OB")

log "$MESSAGE_002 $GAME"
log "$MESSAGE_003 $CONFIGDIR"

if [ ! -w "$CONFIGDIRHOME" ]; then
    log "$MESSAGE_015 $CONFIGDIRHOME"
    exit 1
fi

rm -rf "$CONFIGDIRHOME"/*
mkdir -p "$CONFIGDIR"

log "$MESSAGE_004 $IKEMEN"

# Required files
files=(
    "action.zss"
    "common.const"
    "functions.zss"
    "system.base.def"
    "common.air"
    "common1.cns.zss"
    "guardbreak.zss"
    "tag.zss"
    "common.cmd"
    "dizzy.zss"
    "score.zss"
    "training.zss"
)

# Create data directory if it doesn't exist
mkdir -p "$IKEMEN/data"
# Create save directory
mkdir -p "$IKEMEN/save"

# Check and copy required files
for file in "${files[@]}"; do
    if [ ! -f "$IKEMEN/data/$file" ]; then
        cp "$SHARED/data/$file" "$IKEMEN/data/$file" 2>/dev/null || log "$MESSAGE_011"
    fi
done

# Handle external directory
if [ ! -d "$IKEMEN/external" ]; then
    cp -r "$SHARED/external" "$IKEMEN/" 2>/dev/null || log "$MESSAGE_012"
fi

# Handle font directory
mkdir -p "$IKEMEN/font"
cp -r "$SHARED/font/"* "$IKEMEN/font/" 2>/dev/null || log "$MESSAGE_013"

log "$MESSAGE_005 $IKEMEN"

# Create symbolic links
ln -sf "$IKEMEN"/* "$CONFIGDIR/"

# Link appropriate Ikemen_Go binary
if [ -f "/emuelec/bin/Ikemen_Go" ]; then
    ln -sf "/emuelec/bin/Ikemen_Go" "$CONFIGDIR/Ikemen_Go"
    log "$MESSAGE_009"
else
    ln -sf "/usr/bin/Ikemen_Go" "$CONFIGDIR/Ikemen_Go"
    log "$MESSAGE_010"
fi

if [ $? -eq 0 ]; then
    log "$MESSAGE_006"
else
    log "$MESSAGE_007"
    exit 1
fi

if [ ! -x "$CONFIGDIR/Ikemen_Go" ]; then
    log "$MESSAGE_016"
    exit 1
fi

cd "$CONFIGDIR" || exit 1

# Verifying included the game assets
log "$MESSAGE_008"
./Ikemen_Go -audit >> "$LOGFILE" 2>&1

exec nice -n -20 ./Ikemen_Go


