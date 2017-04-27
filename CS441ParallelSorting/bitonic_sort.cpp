//Kai Davids Schell
//Bitonic Sort

#include <vector>
#include <iostream>
#include <thread>
#include <chrono>
#include <cmath>
#include <ctime>
#include <chrono>
#include <algorithm>

using std::thread;
using std::vector;
using std::cout;
using std::endl;

void comp_swap(vector<int> & vec, int x, int y, bool direction)
{
	if(direction==(vec[x]>vec[y]))
		std::swap(vec[x],vec[y]);
}

void merge(vector<int> & vect, int start, int size, bool direction)
{
	if (size > 1)
	{
		int offset = size / 2;
		for (int i = start; i < start + offset; ++i)
			comp_swap(vect, i, i + offset, direction);
		merge(vect, start, offset, direction);
		merge(vect, start + offset, offset, direction);
	}
}

void pre_sort(vector<int> & vect, int start, int size, bool direction)
{
	if (size > 1)
	{
		int offset = size / 2;
		pre_sort(vect, start, offset, true);
		pre_sort(vect, start + offset, offset, false);
		merge(vect, start, size, direction);
	}
}

void bit_sort(vector<int> & vect, int size)
{
	pre_sort(vect, 0, size, true);
}

int main()
{
	srand(std::time(0));
	size_t size=pow(2,15);
	vector<int> numbers(size); 
	for(int i=0;i<size;++i)
	{
		numbers[i]=std::rand();
	}
	vector<int> numbers2(numbers);
	
	std::chrono::time_point<std::chrono::high_resolution_clock> start, end;//timing
	std::chrono::duration<double> elapsed_seconds;//timing
	start=std::chrono::high_resolution_clock::now();//timing
	
		std::sort(numbers.begin(),numbers.end()); //sorting
	
	end=std::chrono::high_resolution_clock::now();//timing
	elapsed_seconds = end-start;//timing
	std::cout << elapsed_seconds.count() <<"s\n";

		start = std::chrono::high_resolution_clock::now();//timing

	bit_sort(numbers2, size); //sorting

	end = std::chrono::high_resolution_clock::now();//timing
	elapsed_seconds = end - start;//timing
	std::cout << elapsed_seconds.count() << "s\n";
/* 	for (auto i : numbers)
		cout << i << endl;
	return 0; */
}