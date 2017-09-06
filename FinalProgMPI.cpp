#include <iostream>
#include <vector>
#include <string>
#include <algorithm>
#include <fstream>
#include <cmath>
#include <chrono>
#include <mpi.h>
#include <stdlib.h>

using std::cout;
using std::endl;

/* Store a 2D array as a row major 1D array */
template <class T>
class array2D {
	int wid,ht;
	std::vector<T> data; /* wid * ht elements */
public:
	array2D(int w,int h) :wid(w), ht(h), data(w*h) {}

	// Return array size
	inline int nx() const {return wid;}
	inline int ny() const {return ht;}
	
	// Manipulate array elements
	T &operator() (int x,int y) {return data[y*wid+x];}
	T operator() (int x,int y) const {return data[y*wid+x];}

	// Swap our data with this array
	void swap(array2D<T> &other) {
		std::swap(wid,other.wid);
		std::swap(ht ,other.ht );
		std::swap(data,other.data);
	}
};

/* Dump a 2D array to a PPM file */
template <class T>
void write(const array2D<T> &arr,const char *name) {
	std::ofstream f(name,std::ios_base::binary);
	f<<"P5\n"; // grayscale
	f<<arr.nx()<<" "<<arr.ny()<<"\n"; // dimensions
	f<<"255\n"; // byte data
	for (int y=0;y<arr.ny();y++)
	for (int x=0;x<arr.nx();x++)
	{
		float v=arr(x,y)*255.99;
		unsigned char c=(unsigned char)v;
		if (v<0) c=0;
		if (v>255) c=255;
		f.write((char *)&c,1);
	}
}



void exit_MPI()
{
	MPI_Finalize();
}

int main(int argc,char *argv[])
{
	MPI_Init(&argc,&argv);
	atexit(exit_MPI);
	
	int rank, size;
	MPI_Comm_size(MPI_COMM_WORLD, &size);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);

	if(rank ==0)
		cout << " declaring stuff" <<endl;
	
	int w=1000, h=1000;
	array2D<float> cur(w,h);
	array2D<float> next(w,h);


	// Make initial conditions
	for (int y=0;y<cur.ny();y++)
	for (int x=0;x<cur.nx();x++)
	{
		cur(x,y)=fmod(0.01*sqrt(x*x+y*y),1.0);
		// subtle: need boundary conditions for next array
		next(x,y)=cur(x,y);
	}

	// Run a few iterations of blurring
	enum {nblur=100};
	
	int range = cur.ny();
	if(size>0)  
		range = w/size;
		int pad = w-range*size;//takes care of loss from int division rank 0 processes the extra
	if (rank ==0)
		cout <<"the range is "<< range << "the size is " <<size <<endl;
	

	
	std::chrono::time_point<std::chrono::high_resolution_clock> starter, ender;
	starter=std::chrono::high_resolution_clock::now();
	int start = rank*range+pad, end = rank*range+range+pad;
	if (rank == 0)
	{
		cout <<"range,start"<< range << ", " << end-start <<endl;
		for (int blur=0;blur<nblur;blur++)
		{
			
			for (int y=(rank*range+1);y<end+range;++y)
			for (int x=1;x<cur.nx()-1;x++)
			{
				next(x,y)=0.25*(cur(x-1,y)+cur(x+1,y)+cur(x,y-1)+cur(x,y+1));

			} 

			cur.swap(next);
		}
	}
	else if (rank == size-1)
	{
		for (int blur=0;blur<nblur;blur++)
		{
			
			for (int y=(start-range);y<(end-1);++y)
			for (int x=1;x<cur.nx()-1;x++)
			{
				next(x,y)=0.25*(cur(x-1,y)+cur(x+1,y)+cur(x,y-1)+cur(x,y+1));

			} 

			cur.swap(next);
		}
	}
	else
	{
		for (int blur=0;blur<nblur;blur++)
		{
			
			for (int y=(start-range);y<(end+range);++y)
			for (int x=1;x<cur.nx()-1;x++)
			{
				next(x,y)=0.25*(cur(x-1,y)+cur(x+1,y)+cur(x,y-1)+cur(x,y+1));

			} 

			cur.swap(next);
		}
	}

	int tag = 5;
	float storage[w*range];
	if(rank == 0)
	{
		MPI_Status stat;
		for(int sender = 1;sender <size;++sender)
		{
			MPI_Recv(&storage[0],w*range,MPI_FLOAT,sender,tag,MPI_COMM_WORLD, &stat);
			if(sender == size-1)
			{
				int i = 0;
				for (int y=(sender*range+pad);y<((sender*range)+range+pad-1);++y)
				for (int x=1;x<cur.nx()-1;x++)
				{
					cur(x,y)= storage[i];
					++i;
				}
			}
			else
			{
				int i = 0;
				for (int y=(sender*range+pad);y<((sender*range)+range+pad);++y)
				for (int x=1;x<cur.nx()-1;x++)
				{
					cur(x,y)= storage[i];
					++i;
				}
			}
			
		}
		ender=std::chrono::high_resolution_clock::now();;
		std::chrono::duration<double> elapsed = ender-starter;
		std::cout<<"Performance: "<<elapsed.count()/((w-2)*(h-2)*nblur)*1.0e9<<" ns/pixel\n";
		write(cur,"MPI_out.ppm");
	}
	else
	{
		if(rank == size-1)
		{
			int i = 0;
			for (int y=(rank*range+pad);y<((rank*range)+range+pad-1);++y)
			for (int x=1;x<cur.nx()-1;x++)
			{
				storage[i]= cur(x,y);
				++i;
			}
		}
		else
		{
			int i = 0;
			for (int y=(rank*range+pad);y<((rank*range)+range+pad);++y)
			for (int x=1;x<cur.nx()-1;x++)
			{
				storage[i]= cur(x,y);
				++i;
			}
		}
		MPI_Send(&storage[0],w*range,MPI_FLOAT,0,tag, MPI_COMM_WORLD);

	}




	end=std::chrono::high_resolution_clock::now();;
	std::chrono::duration<double> elapsed = end-start;
	cout<<"Performance: "<<elapsed.count()/((w-2)*(h-2)*nblur)*1.0e9<<" ns/pixel\n";


	// Dump final image (good for debugging)
	


	int rank, size;
	MPI_Comm_size(MPI_COMM_WORLD, &size);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);

	//foo(rank,size);
	if(rank ==0)
		cout << " declaring stuff" <<endl;
	
	int w=1000, h=1000;
	array2D<float> cur(w,h);
	array2D<float> next(w,h);


	// Make initial conditions
	for (int y=0;y<cur.ny();y++)
	for (int x=0;x<cur.nx();x++)
	{
		cur(x,y)=fmod(0.01*sqrt(x*x+y*y),1.0);
		// subtle: need boundary conditions for next array
		next(x,y)=cur(x,y);
	}

	// Run a few iterations of blurring
	enum {nblur=100};
	
	int range = cur.ny();
	if(size>0)  
		range = w/size;
	

	
	std::chrono::time_point<std::chrono::high_resolution_clock> start, end;
	start=std::chrono::high_resolution_clock::now();
	if(rank ==0)
		cout << " starting blurring" <<endl;
	
	if (rank == 0)
	{
		for (int blur=0;blur<nblur;blur++)
		{
			
			for (int y=(rank*range+1);y<((rank*range)+range);++y)
			for (int x=1;x<cur.nx()-1;x++)
			{
				next(x,y)=0.25*(cur(x-1,y)+cur(x+1,y)+cur(x,y-1)+cur(x,y+1));

			} 

			cur.swap(next);
		}
	}
	else if (rank == size)
	{
		for (int blur=0;blur<nblur;blur++)
		{
			
			for (int y=(rank*range-1);y<((rank*range)+range-1);++y)
			for (int x=1;x<cur.nx()-1;x++)
			{
				next(x,y)=0.25*(cur(x-1,y)+cur(x+1,y)+cur(x,y-1)+cur(x,y+1));

			} 

			cur.swap(next);
		}
	}
	else
	{
		for (int blur=0;blur<nblur;blur++)
		{
			
			for (int y=(rank*range);y<((rank*range)+range+1);++y)
			for (int x=1;x<cur.nx()-1;x++)
			{
				next(x,y)=0.25*(cur(x-1,y)+cur(x+1,y)+cur(x,y-1)+cur(x,y+1));

			} 

			cur.swap(next);
		}
	}
	if(rank ==0)
		cout << " blurring done" <<endl;
	int tag = 5;
	float storage[w*range];
	if(rank == 0 && size >1)
	{
		if(rank ==0)
		cout << " preparing to receive" <<endl;
		MPI_Status stat;
		for(int sender = 1;sender <size;++sender)
		{
			MPI_Recv(&storage[0],w*range,MPI_FLOAT,sender,tag,MPI_COMM_WORLD, &stat);
			if(sender == size)
			{
				int i = 0;
				for (int y=(sender*range);y<((sender*range)+range-1);++y)
				for (int x=1;x<cur.nx()-1;x++)
				{
					cur(x,y)= storage[i];
					++i;
				}
			}
			else
			{
				int i = 0;
				for (int y=(sender*range);y<((sender*range)+range);++y)
				for (int x=1;x<cur.nx()-1;x++)
				{
					cur(x,y)= storage[i];
					++i;
				}
			}
			
		}
		cout << " done receiving" <<endl;
		end=std::chrono::high_resolution_clock::now();;
		std::chrono::duration<double> elapsed = end-start;
		std::cout<<"Performance: "<<elapsed.count()/((w-2)*(h-2)*nblur)*1.0e9<<" ns/pixel\n";
		write(cur,"MPI_out.ppm");
	}
	else if (rank != 0 && size > 1)
	{
		if(rank == size)
		{
			int i = 0;
			for (int y=(rank*range);y<((rank*range)+range-1);++y)
			for (int x=1;x<cur.nx()-1;x++)
			{
				storage[i]= cur(x,y);
				++i;
			}
		}
		else
		{
			int i = 0;
			for (int y=(rank*range);y<((rank*range)+range);++y)
			for (int x=1;x<cur.nx()-1;x++)
			{
				storage[i]= cur(x,y);
				++i;
			}
		}
		
		
		cout << "rank:" <<rank <<"sending" <<endl;
		MPI_Send(&storage[0],w*range,MPI_FLOAT,0,tag, MPI_COMM_WORLD);
		cout << "rank:" <<rank <<"done sending" <<endl;
	}
	if(rank ==0)
		cout << " receiving done" <<endl;

	

	// Dump final image (good for debugging)
	
	return 0;
}