//Kai Davids Schell
//main.cpp
//useage file for bureaucracy

#include "bureaucracy.h"
#include "bureaucracy_classes.h"

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