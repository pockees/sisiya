#include<iostream>
#include"trim.hpp"

using namespace std;

int main(int argc,char **argv)
{
	if(argc != 2) {
		cerr << "Usage : " << argv[0] << " string" << endl;
		return 1;
	}
	string s=trim(string(argv[1]));
	cout << "Original	string=[" << argv[1] << "]" << endl;
	cout << "Trimed		string=[" << s << "]" << endl;
	return 0;
}
