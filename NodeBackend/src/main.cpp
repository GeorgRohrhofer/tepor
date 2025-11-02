#include <iostream>
#include <ostream>

#include "dockerlib.h"

using namespace std;

int main()
{
    cout << "Hello World" << endl;
    Docker d = {};

    auto res = d.listContainers();

    for (auto s : res) {
        cout << s << endl; 
    }

    string containerName = d.startContainer("marctv/minecraft-papermc-server:1.21.10-91");
    cout << containerName << endl;
    return 0;
}
