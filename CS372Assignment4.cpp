//Kai Davids Schell
//5/2/16
//Assignment 4
//bureaucracy.cpp


class Bureaucrat
{
	virtual ~Bureaucrat() {}
};

class LordOfPaperwork: public Bureaucrat
{
public:
	LordOfPaperwork() {}
	virtual ~LordOfPaperwork() {}
};

class ViceChairmanToTheLordOfPaperwork: public Bureaucrat
{
public:
	ViceChairmanToTheLordOfPaperwork() {}

	virtual ~ViceChairmanToTheLordOfPaperwork() {}
};

class AideOfTheViceChairmanToTheLordOfPaperwork: public Bureaucrat
{
public:
	AideOfTheViceChairmanToTheLordOfPaperwork() {}
	virtual ~AideOfTheViceChairmanToTheLordOfPaperwork() {}
};

class AssistantToTheAideOfTheViceChairmanToTheLordOfPaperwork : public Bureaucrat
{
public:
	AssistantToTheAideOfTheViceChairmanToTheLordOfPaperwork() {}

	virtual ~AssistantToTheAideOfTheViceChairmanToTheLordOfPaperwork() {}
};