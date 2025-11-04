#include <iostream>
#include <ostream> 
#include <thread>
#include <chrono>

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
    this_thread::sleep_for(chrono::milliseconds(3000));
    d.stopContainer(containerName);
    return 0;
}
