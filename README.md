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
