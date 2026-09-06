# claw-config — конфиг openclaw

Конфигурация Telegram-бота (openclaw) с сервера v815382.hosted-by-vdsina.com.

## Важно
- **Секретов здесь нет.** Ключи (GLM, DeepSeek, токен бота) живут на сервере в `/root/.openclaw/secrets.env` и подключены как env-переменные через SecretRef.
- Не кладите секреты в этот репозиторий.

## Как работает деплой
- Правки `openclaw.json` в main автоматически применяются на сервере (cron каждые 5 мин):
  pull → `openclaw config validate` → restart gateway → health-check.
- Некорректный конфиг откатывается автоматически, бот не падает.
- Правки конфига на сервере (бот/UI) коммитятся в main автоматически при следующем деплое.

## Доступ к Control UI (Tailscale)
- Gateway слушает только `127.0.0.1` (`gateway.bind: "loopback"`) — публичного доступа
  `http://89.124.98.153:18789` больше нет.
- UI доступен только из tailnet: **https://v815382.tail552026.ts.net**
  (Tailscale Serve, валидный HTTPS; вход по токену `GATEWAY_AUTH_TOKEN`).
- На вашем устройстве должен быть установлен и залогинен Tailscale (тот же аккаунт tailnet,
  что и у сервера). Сам сервер уже в tailnet (`tailscale up` выполнен).
- Аварийный доступ без Tailscale:
  `ssh -N -L 18789:127.0.0.1:18789 root@v815382.hosted-by-vdsina.com`, затем
  `http://localhost:18789`.
- Откат к публичному доступу: revert коммита со сменой bind (вернуть `"lan"` и старый origin) —
  деплой применит сам.
- Telegram-боту входящий порт не нужен: канал работает через long polling (только исходящие
  соединения), health-check деплоя тоже локальный.

## Восстановление на новом сервере
1. Установить openclaw: `npm install -g --allow-scripts=openclaw,@google/genai,protobufjs,tree-sitter-bash openclaw@latest`
2. Клонировать репозиторий в `/root/.openclaw`
3. Создать `/root/.openclaw/secrets.env`:
   ```
   GLM_API_KEY=...
   DEEPSEEK_API_KEY=...
   TELEGRAM_BOT_TOKEN=...
   GATEWAY_AUTH_TOKEN=...
   BRAVE_API_KEY=...
   ```
4. В systemd-юнит добавить `EnvironmentFile=/root/.openclaw/secrets.env`
5. `systemctl enable --now openclaw-gateway`
6. Установить Tailscale и войти в тот же tailnet, что и раньше:
   `curl -fsSL https://tailscale.com/install.sh | sh && tailscale up`.
   MagicDNS-имя нового сервера вписать в `gateway.controlUi.allowedOrigins` в `openclaw.json`.
