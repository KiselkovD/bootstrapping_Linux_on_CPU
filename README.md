# bootstrapping_Linux_on_CPU

## Текущий план

### Упрощенно

| **Verilog_CPU_32**  | on Verilog |
|---------------------|------------|
| **assemble (base)** | (working on) Verilog_CPU   | 

| compile ...            | writen on ...              | формат |
|------------------------|----------------------------|---|
| **assemble (RISC-V)**  | assemble (base)            | .hex автокод |
| **Forth**              | assemble (RISC-V)          | .hex автокод |
| **TCC**                | Forth                      |   |
| **GCC**            | TCC                        |   |
| **GNU/Linux**          | C                          |   |

### Полноценно
<table>
  <tr><th colspan="3"> план действий </th></tr>
  <tr>
    <td colspan="2">запустить что-то на верилог</td>
    <td> + </td>
  </tr>
  <tr>
    <td colspan="2">вывести .hex используя блок памяти, счетчик и часы</td>
    <td> - </td>
  </tr>
  <tr>
    <td colspan="2">реализовать LMC</td>
    <td> - </td>
  </tr>
  <tr>
    <td colspan="2">реализовать автокодер (а лучше assembler)</td>
    <td> - </td>
  </tr>
  <tr>
    <td colspan="2">написать assemble_RISC-V.asm</td>
    <td> - </td>
  </tr>
  <tr>
    <td colspan="2">RISC.hex скормить LMC</td>
    <td> - </td>
  </tr>
  <tr>
    <td>форт.с в форт.asm</td>
    <td rowspan="3">TCC.c в TCC.asm</td>
    <td> - </td>
  </tr>
  <tr>
    <td>скормить форт.asm</td>
    <td> - </td>
  </tr>
  <tr>
    <td>TCC.c в TCC.fth</td>
    <td> - </td>
  </tr>
  <tr>
    <td>скормить TCC.fth</td>
    <td>скормить TCC.asm</td>
    <td> - </td>
  </tr>
  <tr>
    <td colspan="2">скормить gcc.c</td>
    <td> - </td>
  </tr>
  <tr>
    <td colspan="2">скормить tiny core linux</td>
    <td> - </td>
  </tr> 
</table>



## Вариации середины: 

### Tiny C Compiler (TCC)
большинство стандартных функций C, может использоваться как интерпретатор.

### Минималистичные интерпретаторы и компиляторы
- **TinyCC**: Компактный компилятор C, известный своей высокой скоростью.
- **LCC**: Легкий компилятор C, оптимизированный для простоты.
- **Picol**: Минималистичный интерпретатор Tcl.
- **Forth**: Язык программирования с компактными реализациями.
- **The Super Tiny Interpreter**: Интерпретатор для подмножества JavaScript.

## Разбор шагов:

### Verilog_CPU
можно сделать на основе [Little Man Computer](https://habr.com/ru/articles/412057/)

### Assemble (base)
[ Минимальный набор команд ](##Основные-команды-RISC-V) 
для создания остального ассемблера:
- Арифметические операции: ADD, SUB, MUL, DIV.
- Логические операции: AND, OR, XOR, NOT.
- Перемещение данных: MOV (реализуется через ADD с нулевым регистром).
- Загрузка и сохранение: LW (load word), SW (store word).
- Управляющие команды: BEQ (branch if equal), BNE (branch if not equal), J (jump).

### Assemble (RISC-V)
- [ RISC-V wiki ](https://en.wikipedia.org/wiki/RISC-V)
### TCC
- [ исходный код TCC ](https://www.iro.umontreal.ca/~felipe/IFT2030-Automne2002/Complements/tinyc.c)
- [ инструмент для перевода в assemble и оценки насколько все плохо ](https://godbolt.org/)

### GNU/Linux
- компактный дистрибутив [ Tiny core linux ](http://tinycorelinux.net/12.x/x86/release/src/)
	- **tinycore-12.x.tar.gz** - основной архив с исходным кодом Tiny Core Linux.
	- **tce-12.x.tar.gz** - архив, содержащий необходимые библиотеки и компоненты для работы системы.
	- **build-tools.tar.gz** - инструменты для сборки, которые могут понадобиться для компиляции пакетов.
- Micro Core Linux еще меньше Tiny core
- простая сборка из оптимальных версий
	- [ Linux 2.6.32 ](https://cdn.kernel.org/pub/linux/kernel/v2.6/linux-2.6.32.tar.xz)
	- [ BusyBox 1.30.x ](https://busybox.net/downloads/busybox-1.30.1.tar.bz2)
		- [ BusyBox набор утилит ](##BusyBox)
- первый исторический [Linux](https://github.com/zavg/linux-0.01)

## Шаги для сборки минимального дистрибутива Linux (при обычной установке из Linux)

### 1. инструменты для сборки
```bash
sudo apt update
sudo apt install --yes make build-essential bc bison flex libssl-dev libelf-dev wget cpio fdisk extlinux dosfstools qemu-system-x86
```

### 2.структура каталогов
```bash
mkdir -p ~/simple-linux/build/sources
mkdir -p ~/simple-linux/build/downloads
mkdir -p ~/simple-linux/build/out
```

### 3. исходный код
Linux 2.6.32 и BusyBox 1.30.x:
```bash
cd ~/simple-linux/build/downloads
wget https://cdn.kernel.org/pub/linux/kernel/v2.6/linux-2.6.32.tar.xz
wget https://busybox.net/downloads/busybox-1.30.1.tar.bz2
```

### 4. Распаковка
```bash
tar -xvf linux-2.6.32.tar.xz -C ../sources
tar -xjvf busybox-1.30.1.tar.bz2 -C ../sources
```

### 5. Сборка BusyBox
```bash
cd ../sources/busybox-1.30.1
make defconfig
make LDFLAGS=-static
cp busybox ../../out/
```

### 6. Сборка ядра Linux
```bash
cd ../linux-2.6.32
make defconfig
make -j8 || exit
cp arch/x86/boot/bzImage ~/simple-linux/build/out/vmlinuz-2.6.32
```

### 7. Создание начального образа (initramfs)

#### Создание файла init:
```bash
cd ~/simple-linux/build/out/
echo '#!/bin/sh' > init
echo 'mount -t proc proc /proc' >> init
echo 'mount -t sysfs sys /sys' >> init
echo 'exec /bin/busybox sh' >> init
chmod +x init
```

#### Подготовка корневой файловой системы:
```bash
mkdir rootfs
cp busybox rootfs/
cp init rootfs/
```

#### Создание образа файловой системы:
```bash
cd rootfs
find . | cpio -o --format=newc | gzip > ../initramfs.gz
```

### 8. Настройка загрузчика
 `extlinux` или другой загрузчик.


Инструменты сборки, такие как `make`, `build-essential`, `bc`, `bison`, `flex`, `libssl-dev`, `libelf-dev`, `wget`, `cpio`, `fdisk`, `extlinux`, `dosfstools` и `qemu-system-x86`, играют важную роль в процессе создания дистрибутива Linux. Давайте рассмотрим каждый из этих инструментов и их необходимость.

### Инструменты сборки

1. **make**: 
   - Это утилита для автоматизации сборки программ. Она читает файлы Makefile, чтобы определить, какие части программы нужно компилировать и в каком порядке.

2. **build-essential**: 
   - Это метапакет, который включает в себя основные инструменты для разработки, такие как компиляторы (например, gcc) и другие необходимые утилиты. Он необходим для сборки большинства программ.

3. **wget**: 
   - Это утилита для загрузки файлов из интернета. Она необходима для скачивания исходного кода и других ресурсов.

4. **cpio**: 
   - Это утилита для создания и извлечения архивов. Она может использоваться для создания начальных образов файловой системы (initramfs).

### Необходимость инструментов

- минимум для базовой сборки `make`, `build-essential`, `wget` и для архивов (`cpio`).
- шифрование или сетевые протоколы - библиотеки OpenSSL (`libssl-dev`).
- генерация парсеров `bison` и `flex`
- загрузочные образы или работать с разделами диска: `extlinux` и `fdisk`

### другие

1. **libelf-dev**: 
   - Это библиотеки для работы с ELF (Executable and Linkable Format) файлами. Они могут быть полезны при работе с ядром Linux и другими низкоуровневыми компонентами.

2. **dosfstools**: 
    - Набор инструментов для работы с файловыми системами FAT, которые могут понадобиться при создании загрузочных USB-накопителей или образов.

3. **qemu-system-x86**: 
    - Эмулятор и виртуализатор, который позволяет запускать операционные системы на виртуальных машинах. Он полезен для тестирования вашего дистрибутива без необходимости установки его на физическое оборудование.

4. **bc**: 
   - Это калькулятор с плавающей запятой, который иногда используется в скриптах сборки для выполнения математических операций
   
   ---
   ---
# Доп информация

### mount 

Linux действительно имеет доступ к памяти через различные файловые системы, включая FAT. Система управляет этим доступом с помощью механизма монтирования и внутренней таблицы монтирования, что позволяет эффективно управлять данными на разных устройствах и разделах без необходимости изменять сами ссылки или структуру данных в файловых системах.
 
## BusyBox
набор утилит командной строки
### Командные оболочки
- **ash** – командная оболочка.
- **bash** – командная оболочка.
- **sh** – интерпретатор команд.

### Работа с файлами и каталогами
- **cat** – конкатенация файлов.
- **cp** – копировать.
- **cut** – выбор заданных полей из файла.
- **ln** – создать ссылку на файл или каталог.
- **mkdir** – создание каталога.
- **more** – постраничный просмотр текстовых файлов.
- **mv** – переместить файл.
- **pwd** – вывести рабочий каталог.
- **rm** – удаление файлов или каталогов.
- **rmdir** – удаление пустых каталогов.
- **touch** – обновить дату последнего изменения файла.
- **ls** – вывести список файлов или каталогов.
- **tar** – работа с архивами формата tar.
- **dd** – копирование файла с конвертированием и форматированием.

### Управление правами и владельцами
- **chmod** – смена прав доступа.
- **chown** – смена владельца.

### Системные утилиты
- **date** – текущее дата/время.
- **df** – статистика использования файловой системы.
- **dmesg** – вывод буфера сообщений ядра.
- **uname** – информация о системе.
- **mdu** – статистика использования дискового пространства (иногда используется в альтернативных дистрибутивах).
  
### Процессы и задачи
- **kill** – завершить процесс.
- **ps** – информация о процессах.
- **pidof** – вывести список PID всех процессов по имени.
- **crond** – планировщик заданий.
- **login** – начать новый сеанс в системе.
- **sleep** – пауза на N секунд.
- **usleep** – пауза на N микросекунд.

### Сетевые утилиты
- **ping** – отправить пакеты ICMP ECHO_REQUEST сетевым узлам.
- **netstat** – информация о сетевых настройках и подключениях.
- **nc** – утилита для установления TCP и UDP соединений.
- **ntpc / ntpsync** – клиент синхронизации времени по протоколу NTP.

### Обработка текста
- **awk** – язык обработки строк по шаблонам.
- **sed** – преобразование текстовых потоков.
- **grep** – поиск по шаблону в файлах или стандартном вводе.
  - **egrep** – grep с поддержкой расширенных регулярных выражений.
  - **fgrep** – grep с оптимизированным поиском фиксированной строки.

### Архивирование и сжатие
- **gzip / gunzip** – упаковать/распаковать в gzip.
- **zcat** – распаковать в стандартный вывод.

### Другие утилиты
- **wc** – счет строк, слов, символов.
- **sync** – записать все буферизированные блоки файловой системы на диск.
- **mount / umount** – монтирование/отмонтирование файловых систем.
- **watch** – исполнять программу периодически.
- **tee** – ветвление канала (вывод в несколько мест).
  
### Утилиты для работы с системными данными
- **diff** – утилита сравнения файлов. 
- **echo** – вывод строки. 
- **crond / atd / anacron (если доступны)**– планировщики задач.

### Дополнительные утилиты
- **tftp** – обмен файлами по протоколу TFTP. 
- **rstats** – авторские права BusyBox. 
- **sort** – сортировка. 
- **vi** – редактировать файл. 
- **wget** – утилита закачки файлов. 
- **nvram** – работа с энергозависимой памятью (если доступно).

## Основные команды RISC-V

1. **Арифметические и логические инструкции**:
   - **R-type**: операции с регистрами, такие как `add`, `sub`, `and`, `or`, `xor`.
   - Пример: `add rd, rs1, rs2` — складывает значения в регистрах `rs1` и `rs2`, результат записывается в `rd`.

2. **Инструкции загрузки и сохранения**:
   - **I-type**: используются для загрузки данных из памяти в регистры и наоборот.
   - Примеры: 
     - `lw rd, offset(rs1)` — загружает слово из памяти по адресу, вычисляемому как сумма значения в `rs1` и смещения.
     - `sw rs2, offset(rs1)` — сохраняет слово из регистра `rs2` в память по адресу, вычисляемому так же.

3. **Управляющие инструкции**:
   - **B-type**: условные переходы, такие как `beq` (branch if equal), `bne` (branch if not equal).
   - Пример: `beq rs1, rs2, label` — если значения в `rs1` и `rs2` равны, переход к метке.

4. **Инструкции для немедленных значений**:
   - **I-type**: операции с немедленными значениями.
   - Пример: `li rd, immediate` — загружает немедленное значение в регистр.

5. **Инструкции для установки верхнего значения регистра**:
   - **U-type**: загружают 20-битное значение в верхние 20 бит регистра.
   - Пример: `lui rd, immediate` — загружает немедленное значение в верхние 20 бит регистра.

6. **Инструкции безусловного перехода**:
   - **J-type**: используются для безусловных переходов.
   - Пример: `jal rd, label` — переходит к метке и сохраняет адрес следующей инструкции в регистр `rd`.
   
## О компонентах компьютера (чипсет)

| Модуль                          | Описание                                                                 | Связи с другими модулями                       |
|---------------------------------|-------------------------------------------------------------------------|------------------------------------------------|
| **Центральный процессор (ЦП)**  | Основной вычислительный элемент, выполняющий инструкции и обрабатывающий данные. | Связан с северным мостом через высокоскоростную шину (например, QPI). |
| **Северный мост (GMCH)**        | Обеспечивает связь между ЦП, оперативной памятью и графической картой. | Связан с ЦП, оперативной памятью и южным мостом. |
| **Оперативная память (RAM)**    | Временное хранилище данных для выполнения программ.                     | Подключена к северному мосту через контроллер памяти. |
| **Видеокарта**                  | Обрабатывает графику и выводит изображение на экран.                   | Подключена к северному мосту через шину PCI Express. |
| **Южный мост (ICH)**            | Управляет медленными компонентами, такими как HDD и USB-устройства.    | Связан с северным мостом и различными периферийными устройствами. |
| **Жесткий диск (HDD)**          | Постоянное хранилище данных для операционной системы и файлов.         | Подключен к южному мосту через интерфейс SATA или PATA. |
| **Контроллер USB**              | Обеспечивает подключение USB-устройств.                                 | Встроен в южный мост и соединен с внешними USB-портами. |
| **Система питания (VRM)**       | Регулирует напряжение для ЦП и других компонентов.                      | Связана с материнской платой и компонентами, требующими питания. |
| **BIOS**                        | Начальная система ввода-вывода, управляющая загрузкой компьютера.      | Взаимодействует с южным мостом через шину LPC. |
| **Слоты расширения (PCI/PCIe)** | Позволяют подключать дополнительные карты, такие как звуковые или сетевые адаптеры. | Подключены к южному мосту для передачи данных. |

## О памяти компьютера (адресное пространство)

| Компонент                    | Описание                                                      |
|------------------------------|---------------------------------------------------------------|
| Системная память (RAM)       | Оперативная память для хранения данных и выполнения программ. |
| Видеопамять (совместимость)  | Используется графическим контроллером для хранения изобр/графики.|
| Жесткий диск (HDD/SSD)       | Область для доступа к жесткому диску и хранения данных.       |
| Стандартная память           | Зарезервированная область для системных нужд.                 |
| Область расширения           | Место для ПЗУ BIOS внешних устройств.                         |
| Расширенная системная BIOS   | Область для управления режимами работы системы.               |
| Регистры процессора          | (Не отображаются в адресном пространстве) Внутренние ячейки для данных и управления выполнением команд. |

<!--Разрыв доверенности при интерпретации-->
