PNAME = hello-world

BUILD_DIR = build
INCLUDE_DIR = include
SRC_DIR = src

CC = gcc
CFLAGS = -I$(INCLUDE_DIR) -Wall -Wextra -g
USE_BEAR ?= 0
ifeq ($(USE_BEAR), 1)
	BUILD_CMD = bear --output $(BUILD_DIR)/compile_commands.json -- $(CC)
else
	BUILD_CMD = $(CC)
endif

TARGET = $(BUILD_DIR)/$(PNAME)
SRCS = $(wildcard $(SRC_DIR)/*.c)
OBJS = $(patsubst $(SRC_DIR)/%.c, $(BUILD_DIR)/%.o, $(SRCS))

# Default target
all: $(TARGET)

# Build the executable
$(TARGET): $(OBJS)
	$(BUILD_CMD) $(OBJS) -o $@

# Compile source files into object files
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c | $(BUILD_DIR)
	$(BUILD_CMD) $(CFLAGS) -c $< -o $@

# Create the build directory
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Run the executable
run: $(TARGET)
	@$(TARGET)

# Clean built files
clean:
	rm -rf $(BUILD_DIR)

# Clean then build
rebuild: clean all

# Display help information
help:
	@echo "Makefile Usage:"
	@echo ""
	@echo "  make          - Builds the executable (default)"
	@echo "  make all      - Same as 'make'"
	@echo "  make run      - Builds the executable if needed and then runs it"
	@echo "  make clean    - Removes the build directory and all built files"
	@echo "  make rebuild  - Performs a clean first, then builds the project"
	@echo "  make help     - Displays this help message"

.PHONY: all clean run rebuild help
