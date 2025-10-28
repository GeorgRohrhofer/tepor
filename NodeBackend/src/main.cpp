#include <algorithm>
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
    return 0;
}
