#include <iostream>
#include <random>
#include <algorithm>
#include <vector>
#include <time.h>
#include <cstdlib>

using namespace std;



int roll()
{
	vector<int> scores;
	int score=0;
	for(int i=0;i<4;++i)
	{
		scores.push_back(rand()%6+1);
	}
	sort(scores.begin(),scores.end());
	for(int i=0;i<3;++i)
	{
		score+=scores[i+1];
	}
	return score;
}

int main()
{
	srand(time(NULL));
	bool high_enough = false;
	size_t iter= 0;
	int a,b,c,d,e,f,min_stat;
	char rep;
	cout << "Enter your minimum for stats" <<endl;
	cin >> min_stat;
	do{
 	while(!high_enough)
	{
		++iter;
		a = roll();
		b = roll();
		c = roll();
		d = roll();
		e = roll();
		f = roll();
		if(a >=min_stat && b >= min_stat && c >= min_stat && d>= min_stat && e >= min_stat && f >= min_stat)
			high_enough = true;
	}
	high_enough = false;
	cout << "After " << iter << " iterations, your scores are: ";
	cout << endl << a <<" "<< b << " "<< c <<" "<< d <<" "<< e <<" "<< f <<endl;
	cout << "Roll again for same min?(y/n):";
	cin >> rep;
	iter = 0;
	}while(rep != 'n');
	return 0;
}