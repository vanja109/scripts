# create.sh
Скрипт позволяет создать почтовые ящики по указанному шаблону. Берет данные из .csv файла, расположенного в той же директории. При необходимости можно в файле добавить дополнительные переменные, указав их для перебора при объявлении цикла на 5 строке и в сам цикл, изменив шаблон. 
Указать в 10 строке имя файла .CSV, из которого будут браться данные для подстановки в шаблон.
Запустить скрипт командой `bash create.sh`

# mboxcleanup.sh
Скрипт позволяет удалять почтовые ящики, если они не обращались к серверу более 3 месяцев, таким образом не засоряя почтовый сервер. Данные по БД необходимо указать в переменных `DBUSER`, `DBPASS`, `DBNAME`. По необходимости можно увеличить или уменьшить время простоя почтового ящика, изменив переменную `EXP_DAYS`. Результат работы скрипта пишется в лог, путь к которому в переменной `LOG`. В `DOM` указываем домен почты, а в `MDIR` путь до места хранения.
В скрипте приведены следующие действия:
1. Выбираем `userid`, у которых столбец `last_access` в таблице `last_login` меньше, чем максимально допустимое время простоя (не подключался более 3 месяцев).
2. Удаляем записи в таблицах `alias`, `mailbox`, `quota2`, `last_login`. Каждое действие пишем в лог-файл.
3. Удаляем (и при необходимости архивируем) директорию с письмами из ящика, хранящуюся на сервере.
4. Для каждого выбранного в пункте 1 почтовом ящике повторяем пункты 2 и 3.
