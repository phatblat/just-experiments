#include <iostream>
#include <string>

int main(int argc, char* argv[]) {
    if (argc > 1) {
        std::cout << "Hello from C++ SDK! You said: " << argv[1] << std::endl;
    } else {
        std::cout << "Hello from C++ SDK!" << std::endl;
    }
    return 0;
}
