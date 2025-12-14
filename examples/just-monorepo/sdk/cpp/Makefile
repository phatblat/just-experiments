CXX = g++
CXXFLAGS = -std=c++17 -Wall -Wextra
TARGET = sdk-cpp
SRC = src/main.cpp
BUILD_DIR = build

.PHONY: all clean test

all: $(BUILD_DIR)/$(TARGET)

$(BUILD_DIR)/$(TARGET): $(SRC)
	@mkdir -p $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) $(SRC) -o $(BUILD_DIR)/$(TARGET)

clean:
	rm -rf $(BUILD_DIR)

test:
	@echo "Running C++ tests..."
	@echo "Tests passed (no tests defined yet)"
