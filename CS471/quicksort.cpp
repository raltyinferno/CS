//Kai Davids Schell

#include <iostream>
#include <algorithm>
#include <vector>
#include <random>
#include <stdlib.h>
#include <time.h>

using std::cout;
using std::sort;
using std::is_sorted;
using std::vector;
using std::swap;
using std::endl;

int partition(vector<int> vect, int lo, int hi)
{
	int pivot = vect[hi];
	int i = lo -1;
	for(int j=lo;j <hi-1; ++j)
	{
		if (vect[j] <pivot)
		{
			++i;
			swap(vect[i],vect[j]);
		}
	}
	if (vect[hi]<vect[i+1])
		swap(vect[i+1],vect[hi]);
	return i+1;
}

void quicksort( vector<int> vect,int lo, int hi)
{
	if (vect[lo] < vect[hi])
	{
		int p = partition(vect, lo, hi);
		quicksort(vect, lo, p-1);
		quicksort(vect, p+1, hi);
	}
}

int main()
{
	const int NUM = 10;
	srand(time(NULL));	
	vector<int> numbers(NUM);
	
	for(auto & n : numbers )
		n = rand();
	for(auto n : numbers)
		cout << n << endl;
	
	cout << "-----------------------" <<endl;
	quicksort(numbers, 0, NUM-1);
	cout << " ****************************" << endl;

	for(auto n : numbers)
		cout << n << endl;
	
	cout << "is sorted: " <<is_sorted(numbers.begin(), numbers.end()) <<endl;
}