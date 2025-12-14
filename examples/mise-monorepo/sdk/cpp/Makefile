.PHONY: all build clean test

CXX = g++
CXXFLAGS = -std=c++17 -Wall -Wextra
TARGET = sdk-cpp
TEST_TARGET = sdk-cpp-test

all: build

build:
	$(CXX) $(CXXFLAGS) -o $(TARGET) main.cpp

test: build
	@echo "Running C++ tests..."
	@./$(TARGET)
	@echo "C++ SDK test passed!"

clean:
	rm -f $(TARGET) $(TEST_TARGET) *.o

run: build
	./$(TARGET)
