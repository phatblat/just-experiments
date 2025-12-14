#include <iostream>
#include <vector>
#include <string>

int main(int argc, char* argv[]) {
    if (argc > 1) {
        std::cout << "Hello from C++ SDK! Args: ";
        for (int i = 1; i < argc; ++i) {
            std::cout << argv[i];
            if (i < argc - 1) std::cout << " ";
        }
        std::cout << std::endl;
    } else {
        std::cout << "Hello from C++ SDK!" << std::endl;
    }
    std::cout << "Version: 1.0.0" << std::endl;
    return 0;
}
