//Kai Davids Schell
//Threaded mergesort

#include <iostream>
#include <algorithm>
#include <vector>
#include <ctime>
#include <thread>
#include <chrono>
#include <cmath>

using std::thread;
using std::vector;
using std::cout;
using std::endl;


// Functions for dual parallelism
void sort_beg(vector<int> & vect)
{
	std::sort(vect.begin(), vect.begin()+vect.size()/2);
}
void sort_end(vector<int> & vect)
{
	std::sort(vect.end()-vect.size()/2, vect.end());
}

void sort_all_2(vector<int> & vect)
{
	thread t1(sort_beg, std::ref(vect)), t2(sort_end, std::ref(vect));
	t1.join();
	t2.join();
	std::inplace_merge(vect.begin(),vect.begin()+vect.size()/2,vect.end());
}

// Fucntions for quad parallelism
void sort_1(vector<int> & vect)
{
	std::sort(vect.begin(),vect.begin()+vect.size()/4);
}
void sort_2(vector<int> & vect)
{
	std::sort(vect.begin()+vect.size()/4, vect.begin()+vect.size()/2);
}
void sort_3(vector<int> & vect)
{
	std::sort(vect.begin()+vect.size()/2,vect.begin()+vect.size()*3/4);
}
void sort_4(vector<int> & vect)
{
	std::sort(vect.begin()+vect.size()*3/4, vect.end());
}

void sort_all_4( vector<int> & vect)
{
	vector<thread> threads;
	threads.emplace_back(thread(sort_1,std::ref(vect)));
	threads.emplace_back(thread(sort_2,std::ref(vect)));
	threads.emplace_back(thread(sort_3,std::ref(vect)));
	threads.emplace_back(thread(sort_4,std::ref(vect)));
	
	for(auto & t :threads)
		t.join();


	std::inplace_merge(vect.begin(),vect.begin()+vect.size()/4,vect.begin()+vect.size()/2);
	std::inplace_merge(vect.begin()+vect.size()/2, vect.begin()+vect.size()*3/4,vect.end());
	std::inplace_merge(vect.begin(), vect.begin()+vect.size()/2, vect.end());
}


int main()
{
	srand(std::time(0));
	int size=pow(2,15);
	vector<int> numbers(size); 
	for(int i=0;i<size;++i)
	{
		numbers[i]=std::rand();
	}
	vector<int> numbers2(numbers), numbers3(numbers);

	
	cout << "# of elements :"<<size <<endl;

	//Serial Sort
	std::chrono::time_point<std::chrono::high_resolution_clock> start, end;
	std::chrono::duration<double> elapsed_seconds;

	start=std::chrono::high_resolution_clock::now();
	
		std::sort(numbers.begin(),numbers.end());

	end=std::chrono::high_resolution_clock::now();
	elapsed_seconds = end-start;

	cout << "Serial Sort   :";
	std::cout << elapsed_seconds.count() <<"s\n";

	
	
	//2Parallel Sort
	start=std::chrono::high_resolution_clock::now();

		sort_all_2(numbers2);
	
	end=std::chrono::high_resolution_clock::now();
	elapsed_seconds = end-start;
	cout << "2Parallel Sort:";
	std::cout << elapsed_seconds.count() <<"s\n";

	
	
	//4Parallel Sort (Deadlocks occur for some reason at size< ~700)
	start=std::chrono::high_resolution_clock::now();

		sort_all_4(numbers3);

	end=std::chrono::high_resolution_clock::now();
	elapsed_seconds = end-start;
	cout << "4Parallel Sort:";	
	std::cout << elapsed_seconds.count() <<"s\n";

	return 0;
}