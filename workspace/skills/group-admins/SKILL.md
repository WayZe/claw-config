---
name: group-admins
description: Use when the user asks who the administrators of the current Telegram group are, or wants to see the list of group admins (кто админы, список админов, who are admins). Returns names, usernames and roles.
user-invocable: true
---

# Telegram Group Admins

Выполни, когда пользователь спрашивает, кто является администратором текущей группы Telegram, или просит показать список админов.

## Шаги

1. Определи `chat_id` текущей группы. Он есть в ключе сессии (формат `agent:main:telegram:group:<chat_id>`), например `-1002665577371`. Если не уверен — спроси пользователя.
2. Прочитай токен бота из конфига: `cat ~/.openclaw/openclaw.json`, поле `channels.telegram.botToken`.
3. Выполни запрос к Telegram API:
   ```bash
   curl -s "https://api.telegram.org/bot<ТОКЕН>/getChatAdministrators?chat_id=<CHAT_ID>"
   ```
4. Отформатируй ответ: для каждого админа укажи имя, username (если есть) и роль (creator — владелец группы, administrator — администратор).
5. Ответь пользователю списком на русском языке, отсортировав владельца первым.

## Формат ответа

- 👑 Владелец: Имя (@username) — роль creator
- 🛡 Администраторы: Имя (@username) — роль administrator

Если запрос к API вернул ошибку — перескажи текст ошибки и предложи проверить токен/chat_id.
