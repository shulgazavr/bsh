#!/bin/bash

# Предотвращение повторного запуска скрипта
lockfile=./lockfile.tmp
if [ -e "$lockfile" ]; then
    exit 1
else
    echo "$$" > lockfile.tmp
fi


# Путь к лог-файлу
log_file="access.log"
e_mail="test_mail@test_mail.lc"

# Получение значения временя предыдущего часа
# и создание промежуточного файла со всеми записямси за предыдущий час
#cur_date=$(date -d "-1 hour" +%d/%b/%Y:%H)
#grep "$cur_date" "$log_file" > fl.tmp



#--------------------------------
# Данная часть скрипта создана для демонстрации работоспособности. 
# Т.к. лог-файл не изменяется, то время указанно конкретное.

tst_cur_date="14/Aug/2019:06"
grep "$tst_cur_date" "$log_file" > tst_fl.tmp
#--------------------------------

# Поиск и подсчёт количества запросов с каждого ip и запись результата в файл
awk '{ print $1 }' tst_fl.tmp | sort | uniq -c | sort -nr > IP_addresses.txt

# Поиск и подсчёт количества запрашиваемых страниц и запись результата в файл
awk '{ print $7 }' tst_fl.tmp | sort | uniq -c | sort -nr > URLs.txt

# Список всех кодов HTTP ответа с указанием их количества и запись результата в файл
awk '{ print $9 }' tst_fl.tmp | sort | uniq -c | sort -nr > HTTP_codes.txt 

# Ошибки веб-сервера/приложения
egrep "[0-9] 5[0-9][0-9]" HTTP_codes.txt > 5xx_codes.txt

# Формирование и отправка письма:
echo "Статистика за $tst_cur_date" | mail -s "Данные во вложении" -A IP_addresses.txt -A URLs.txt -A HTTP_codes.txt -A 5xx_codes.txt "$e_mail"

# Удаляем временные файлы
rm -f *.tmp
rm -f "$lockfile"
rm -f *.txt
