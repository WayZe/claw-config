#!/usr/bin/env bash
#
# weekly-cleanup.sh — еженедельная чистка диска на VDS-сервере OpenClaw-бота
# (v815382.hosted-by-vdsina.com, Ubuntu, 1 ядро, 956MB RAM, диск 9.8G).
# Запускается из cron пользователя root. Неинтерактивный, идемпотентный,
# повторный запуск безопасен.
#
# Что чистит:
#   - системный журнал: journalctl --vacuum-size=50M
#   - кэш apt-пакетов: apt-get clean
#   - кэш nvm: /root/.nvm/.cache
#   - входящие медиа бота старше 14 дней: /root/.openclaw/media/inbound
#     (плюс опустевшие подкаталоги)
#   - dangling docker-образы: docker image prune -f (с timeout 60)
#
# Что НЕ трогает:
#   - запущенные docker-контейнеры и их тома
#   - состояние бота: /root/.openclaw/state
#   - workspace бота (личность, память, skills)
#
# Лог работы: /var/log/weekly-cleanup.log
# (самоограничение: при размере >1 МБ оставляются последние 512 КБ).

set -u

LOG="/var/log/weekly-cleanup.log"

{
    echo "=== weekly-cleanup started: $(date '+%Y-%m-%d %H:%M:%S') ==="
    echo "Free space before: $(df --output=avail -h / | tail -1)"

    echo "--- journalctl vacuum to 50M ---"
    journalctl --vacuum-size=50M

    echo "--- apt-get clean ---"
    apt-get clean

    echo "--- nvm cache ---"
    rm -rf /root/.nvm/.cache

    echo "--- openclaw inbound media older than 14 days ---"
    find /root/.openclaw/media/inbound -type f -mtime +14 -delete 2>/dev/null || true
    find /root/.openclaw/media/inbound -mindepth 1 -type d -empty -delete 2>/dev/null || true

    echo "--- docker dangling image prune (timeout 60s) ---"
    timeout 60 docker image prune -f 2>/dev/null || true

    echo "Free space after: $(df --output=avail -h / | tail -1)"
    echo "=== weekly-cleanup finished: $(date '+%Y-%m-%d %H:%M:%S') ==="
} >> "$LOG" 2>&1

# Самоограничение лога: при размере больше 1 МБ оставить последние 512 КБ.
# Выполняется после закрытия перенаправления выше, чтобы не писать
# в уже переименованный inode.
LOG_SIZE="$(stat -c%s "$LOG" 2>/dev/null || echo 0)"
if [ "$LOG_SIZE" -gt 1048576 ]; then
    tail -c 524288 "$LOG" > "$LOG.tmp" && mv "$LOG.tmp" "$LOG"
fi

exit 0
