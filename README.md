# Лабораторна робота №1 

Проєкт — веб-застосунок **Task Tracker** з автоматизованим розгортанням на віртуальній машині через Vagrant.

---
### Лебедєва Софія ІМ-44
---

## Варіант індивідуального завдання

**Номер варіанту:** N = 13

| Параметр | Формула | Значення | Опис |
|----------|---------|----------|------|
| V2 | (13 % 2) + 1 | **2** | Файл конфігурації `/etc/mywebapp/config.json`, БД — PostgreSQL |
| V3 | (13 % 3) + 1 | **2** | Тип застосунку — Task Tracker |
| V5 | (13 % 5) + 1 | **4** | Порт застосунку — `8000` |

---

## Структура репозиторію

```
deployment-course/
├── config/
│   └── config.json              # Конфігурація застосунку (копіюється в /etc/mywebapp/)
├── nginx/
│   └── mywebapp.conf            # Конфігурація nginx (reverse proxy)
├── scripts/
│   ├── install.sh               # Скрипт автоматичного розгортання
│   └── migrate.sh               # Скрипт міграції БД
├── src/
│   └── mywebapp/                # Вихідний код C# застосунку (.NET 10)
├── Vagrantfile                  # Опис віртуальної машини
└── README.md                    # Документація
```

---

## Документація по веб-застосунку
## Стек

C# (.NET 10), ASP.NET Core, EF Core, PostgreSQL, nginx, systemd, Vagrant.

### API Endpoints

| Метод | Шлях | Опис |
|-------|------|------|
| `GET` | `/` | HTML-сторінка зі списком ендпоінтів |
| `GET` | `/tasks` | Отримати список усіх задач |
| `POST` | `/tasks` | Створити нову задачу. Body: `{"title": "..."}` |
| `POST` | `/tasks/{id}/done` | Позначити задачу як виконану |
| `GET` | `/health/alive` | Health check (тільки внутрішньо) |
| `GET` | `/health/ready` | Health check з перевіркою БД (тільки внутрішньо) |

Ендпоінти `/health/*` доступні тільки локально на ВМ — nginx закриває їх ззовні.

#### Приклад використання

Створити задачу:
```bash
curl -X POST http://localhost:8080/tasks \
     -H "Content-Type: application/json" \
     -d '{"title": "Створити задачу"}'
```

Відповідь:
```json
{
  "id": 1,
  "title": "Створити задачу",
  "status": "pending",
  "created_at": "2026-04-28T22:05:18Z"
}
```

Позначити виконаною:
```bash
curl -X POST http://localhost:8080/tasks/1/done
```

---

## Документація по розгортанню

### Базовий образ ВМ

Використовується офіційний образ **Ubuntu 24.04 LTS** від проекту [Bento](https://github.com/chef/bento) (`bento/ubuntu-24.04`). Vagrant завантажує його автоматично при першому запуску.

### Вимоги до ресурсів ВМ

| Ресурс | Значення |
|--------|----------|
| CPU | 2 ядра |
| RAM | 2048 MB |


### Передумови на хост-машині (Windows/macOS/Linux)

1. **VirtualBox** — [virtualbox.org](https://www.virtualbox.org)
2. **Vagrant** — [vagrantup.com](https://www.vagrantup.com)
3. **Git** — для клонування репозиторію


### Як завантажити та запустити автоматизацію

```bash
# 1. Клонувати репозиторій
git clone https://github.com/Sofi-fi-fi/deployment-course.git
cd deployment-course

# 2. Запустити розгортання 
vagrant up
```

### Як увійти на ВМ

```bash
vagrant ssh
```

Після першого розгортання користувач `vagrant` блокується. Для входу використовуйте інших користувачів через `sudo` або через консоль VirtualBox:

| Користувач | Пароль | Призначення |
|------------|--------|-------------|
| `student` | `student` | Адміністративний (sudo). Зміна пароля при першому вході. |
| `teacher` | `12345678` | Перевірка роботи (sudo). Зміна пароля при першому вході. |
| `app` | — | Системний, запускається застосунком |
| `operator` | `12345678` | Обмежений sudo для управління сервісом mywebapp і nginx. Зміна пароля при першому вході. |

### Корисні команди Vagrant

```bash
vagrant up          # Створити та запустити ВМ
vagrant ssh         # Підключитися по SSH
vagrant halt        # Зупинити ВМ (без видалення)
vagrant reload      # Перезапустити ВМ (застосувати зміни Vagrantfile)
vagrant provision   # Повторно запустити install.sh без перестворення ВМ
vagrant destroy -f  # Видалити ВМ повністю
```

## Інструкція з тестування

### 1. Перевірка веб-застосунку через браузер на хості

Відкрити в браузері: **http://localhost:8080**

Має відобразитися HTML-сторінка зі списком API-ендпоінтів.

### 2. Перевірка списку задач

Відкрити: **http://localhost:8080/tasks**

Має відобразитися пуста таблиця (або список задач якщо створювали раніше).

### 3. Створення задачі

```powershell
curl.exe -X POST http://localhost:8080/tasks `
     -H "Content-Type: application/json" `
     -d '{\"title\": \"Створити задачу\"}'
```

### 4. Перевірка що health-ендпоінти закриті ззовні

Відкрити в браузері:
- http://localhost:8080/health/alive — має повернути `404`
- http://localhost:8080/health/ready — має повернути `404`

### 5. Перевірка статусу сервісів на ВМ

```bash
vagrant ssh
sudo systemctl status mywebapp
sudo systemctl status nginx
sudo systemctl status postgresql
```

Усі три сервіси повинні бути `active (running)`.

### 6. Перевірка користувачів та їх прав

```bash
# Усі створені користувачі
getent passwd student teacher app operator

# Хто в групі sudo
getent group sudo

# Sudo-правила оператора
sudo cat /etc/sudoers.d/operator

# Чи заблокований vagrant
sudo passwd -S vagrant
```

### 7. Перевірка файлу gradebook

```bash
sudo cat /home/student/gradebook
# Має вивести: 13
```

### 8. Перевірка обмеженого sudo для operator

```bash
sudo -u operator sudo -l
```

Має показати дозволені команди (управління mywebapp і reload nginx).

---