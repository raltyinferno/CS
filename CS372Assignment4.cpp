//Kai Davids Schell
//5/2/16
//Assignment 4
//bureaucracy.cpp
//ACCURATE BUREAUCRACY SIMULATION

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
class Shredder : public Bureaucrat
{
public:
	//Shredder() {}
	void handle(string req)
	{
		cout << "*shredding sounds*" << endl;
	}
	virtual ~Shredder() {}
private:
	void approve()
	{}
	void decline()
	{}
	void transfer(string req)
	{}
};

class LordOfPaperwork : public Bureaucrat
{
public:
	LordOfPaperwork(string nam, Bureaucrat * worker) :name(nam), next(worker)
	{}
	void handle(string req)
	{
		request = req;
		cout << "Hello, my name is " << name << ", Lord of Paperwork! let me see what I can do for you today." << endl;
		int rand = rand_num();
		if (100 < rand && rand < 125)
			approve();
		else if (138 < rand && rand < 157)
			decline();
		else
			transfer(req);
	}
	virtual ~LordOfPaperwork() {}
private:
	void approve()
	{
		cout << "Very well, as the Lord of Paperwork I approve your request for: " << request << endl;
	}
	void decline()
	{
		cout << "As Lord of Paperwork I'm afraid I'm going to have to decline your request for: " << request << endl;
	}
	void transfer(string req)
	{
		cout << "I'm afraid you've filled out form C-" << rand_num() << " incorrectly, you'll have to go back and fix that, have a nice day." << endl;
		next->handle(req);
	}


	string name, request;
	Bureaucrat *next;
};

class ViceChairmanToTheLordOfPaperwork : public Bureaucrat
{
public:
	ViceChairmanToTheLordOfPaperwork(string nam, Bureaucrat * worker) :name(nam), next(worker)
	{}
	void handle(string req)
	{
		request = req;
		cout << "Hello, my name is " << name << ", Vice-Chairman to the Lord of Paperwork! let me see what I can do for you today." << endl;
		int rand = rand_num();
		if (44 < rand && rand < 63)
			approve();
		else if (122 < rand && rand < 155)
			decline();
		else
			transfer(req);
	}
	virtual ~ViceChairmanToTheLordOfPaperwork() {}
private:
	void approve()
	{
		cout << "Well I'm glad you came to me. Your request for " << request << " has been granted, have a nice day" << endl;
	}
	void decline()
	{
		cout << "You're wasting my time, I'm very important you know. Your request for " << request << " is denied" << endl;
	}
	void transfer(string req)
	{
		cout << "Let me forward you to the Lord of Paperwork" << endl;
		next->handle(req);
	}

	string name, request;
	Bureaucrat *next;

};

class AideOfTheViceChairmanToTheLordOfPaperwork : public Bureaucrat
{
public:
	AideOfTheViceChairmanToTheLordOfPaperwork(string nam, Bureaucrat * worker) :name(nam), next(worker)
	{}
	void handle(string req)
	{
		request = req;
		cout << "Hello, my name is " << name << ", Aide of the Vice-Chairman to the Lord of Paperwork! let me see what I can do for you today." << endl;
		int rand = rand_num();
		if (100 < rand && rand < 125)
			approve();
		else if (138 < rand && rand < 157)
			decline();
		else
			transfer(req);
	}
	virtual ~AideOfTheViceChairmanToTheLordOfPaperwork() {}
private:
	void approve()
	{
		cout << "Looks like everything is in order, your request for " << request << " is approved" << endl;
	}
	void decline()
	{
		cout << "REQUEST DENIED" << endl;
	}
	void transfer(string req)
	{
		cout << "Everything seems alright, but you'll need additional approval, I'm going to transfer you now" << endl;
		next->handle(req);
	}

	string name, request;
	Bureaucrat *next;
};

class AssistantToTheAideOfTheViceChairmanToTheLordOfPaperwork : public Bureaucrat
{
public:
	AssistantToTheAideOfTheViceChairmanToTheLordOfPaperwork(string nam, Bureaucrat * worker) :name(nam), next(worker)
	{}
	void handle(string req)
	{
		request = req;
		cout << "Hello, my name is " << name << ", Assistant to the Aide of the Vice-Chairman to the Lord of Paperwork!";
		cout << " let me see what I can do for you today." << endl;
		int rand = rand_num();
		if (12 < rand && rand < 20)
			approve();
		else if (172 < rand && rand < 196)
			decline();
		else
			transfer(req);
	}
	virtual ~AssistantToTheAideOfTheViceChairmanToTheLordOfPaperwork() {}
private:
	void approve()
	{
		cout << "Approved, carry on." << endl;
	}
	void decline()
	{
		cout << "Declined." << endl;
	}
	void transfer(string req)
	{
		cout << "Hmm, you're going to need the approval of my boss, let me transfer you" << endl;
		next->handle(req);
	}

	string name, request;
	Bureaucrat *next;
};
#endif // !1


int main()
{
	
	Shredder suggestionsBox;
	LordOfPaperwork Balthazor("Balthazor the Administrator", &suggestionsBox);
	ViceChairmanToTheLordOfPaperwork Trogdor("Trogdor the Taxinator", &Balthazor);
	AideOfTheViceChairmanToTheLordOfPaperwork Bob("BOB!!!!!!", &Trogdor);
	AssistantToTheAideOfTheViceChairmanToTheLordOfPaperwork Ezalor("Ezalor the Sortifier", &Bob);

	cout << "WELCOME TO THE ADMINISTRATIVE DEPARTMENT OF ADMINISTRATIVE MINISTRIES OFFICE" << endl;
	cout << "PLEASE ENTER YOUR REQUEST AND PRESS ENTER, THEN FILL OUT THE PROPER FORMS" << endl;
	string request;
	getline(cin, request);
	Ezalor.handle(request);
	


	return 0;
}