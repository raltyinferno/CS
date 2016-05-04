//Kai Davids Schell
//5/2/16
//Assignment 4
//bureaucracy.h
//Source file for base class of bureaucracy

#ifndef BUREAUCRACY_INCLUDED
#define BUREAUCRACY_INCLUDED

#include <string>
#include <iostream>
#include <utility>
#include <random>
#include <time.h>

using std::string;
using std::cout;
using std::cin;
using std::endl;
using std::pair;
using std::mt19937;
using std::normal_distribution;


class Bureaucrat
{
public:
	virtual void handle(string) = 0;
	virtual ~Bureaucrat() {}

	string get_name()
	{
		return name;
	}
	string name;
	string request;
	Bureaucrat * next;
	int rand_num()
	{
		mt19937 rand_gen;
		normal_distribution<double> rand_range(100, 99);
		rand_gen.seed(time(NULL));
		return rand_range(rand_gen);
	}
private:
	virtual void approve() = 0;
	virtual void decline() = 0;
	virtual void transfer(string) = 0;
};

#endif