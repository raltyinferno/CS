//Kai Davids Schell
//bureaucracy.cpp
//Source file for derived classes for bureaucracy

#include "bureaucracy.h"

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

class LordOfPaperwork: public Bureaucrat
{
public:
	LordOfPaperwork(string nam, Bureaucrat * worker):name(nam), next(worker)
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
		cout << "I'm afraid you've filled out form C-" << rand_num() <<" incorrectly, you'll have to go back and fix that, have a nice day." << endl;
		next->handle(req);
	}


	string name,request;
	Bureaucrat *next;
};

class ViceChairmanToTheLordOfPaperwork: public Bureaucrat
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

	string name,request;
	Bureaucrat *next;

};

class AideOfTheViceChairmanToTheLordOfPaperwork: public Bureaucrat
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

	string name,request;
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

	string name,request;
	Bureaucrat *next;
};