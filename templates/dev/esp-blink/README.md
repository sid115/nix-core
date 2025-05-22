# ESP32 blink template

Set `BLINK_GPIO` to your LED pin in [`main/main.c`](./main/main.c).

## Clean the build directory

```bash
idf.py fullclean
```

## Set the build target

```bash
idf.py set-target esp32s3
```

## Open configuration menu

```bash
idf.py menuconfig
```

## Build the project

```bash
idf.py all
```

## Flash the binary

```bash
idf.py flash
```
