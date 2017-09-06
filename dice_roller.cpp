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
	int min_stat;
	vector<int> stats(6);
	char rep;
	cout << "Enter your minimum for stats" <<endl;
	cin >> min_stat;
	do{
 	while(!high_enough)
	{
		++iter;
		high_enough = true;
		for (auto num : stats)
		{
			stats[num] = roll();
			if (stats[num]<min_stat)
				high_enough = false;
		}
		
	}
	sort(stats.begin(),stats.end());
	high_enough = false;
	cout << "After " << iter << " iterations, your scores are: ";
	for (auto n : stats)
	{
		cout << stats[n] << " ";
	}
	cout << endl;
	cout << "Roll again for same min?(y/n):" <<endl;
	cin >> rep;
	iter = 0;
	}while(rep != 'n');
	return 0;
}