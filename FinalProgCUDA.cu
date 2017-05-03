#include <iostream>
#include <vector>
#include <string>
#include <algorithm>
#include <fstream>
#include <cmath>
#include <chrono>

#include "cuda_runtime.h"
#include "device_launch_parameters.h"

using std::cout;
using std::endl;

/* Store a 2D array as a row major 1D array */
template <class T>
class array2D {
	int wid, ht;
	std::vector<T> data; /* wid * ht elements */
public:
	array2D(int w, int h) :wid(w), ht(h), data(w*h) {}

	// Return array size
	inline int nx() const { return wid; }
	inline int ny() const { return ht; }

	// Manipulate array elements
	 T &operator() (int x, int y) { return data[y*wid + x]; }
	 T operator() (int x, int y) const { return data[y*wid + x]; }

	// Swap our data with this array
	void swap(array2D<T> &other) {
		std::swap(wid, other.wid);
		std::swap(ht, other.ht);
		std::swap(data, other.data);
	}
};

/* Dump a 2D array to a PPM file */
template <class T>
void write(const array2D<T> &arr, const char *name) {
	std::ofstream f(name, std::ios_base::binary);
	f << "P5\n"; // grayscale
	f << arr.nx() << " " << arr.ny() << "\n"; // dimensions
	f << "255\n"; // byte data
	for (int y = 0;y<arr.ny();y++)
		for (int x = 0;x<arr.nx();x++)
		{
			float v = arr(x, y)*255.99;
			unsigned char c = (unsigned char)v;
			if (v<0) c = 0;
			if (v>255) c = 255;
			f.write((char *)&c, 1);
		}
}
__global__ void blur(float cur[1000][1000], float next[1000][1000])
{
	int y = threadIdx.x+1;
	int x = blockIdx.x+1;
	//array2D<float> cur = *curr, next = *nex;
	//for (int y=1;y<cur.ny()-1;y++)
	//for (int x=1;x<cur.nx()-1;x++)
	for (int iter = 0;iter < 100;++iter)
	{
		next[x - 1][y - 1] = 0.25*(cur[x - 1][y] + cur[x + 1][y] + cur[x][y - 1] + cur[x][y + 1]);

		float temp;
		temp = next[x - 1][y - 1];
		next[x - 1][y - 1] = cur[x - 1][y - 1];
		cur[x - 1][y - 1] = temp;
	}
	
	
}
void I_pity_the_foo() {
	cout << "foo begin" << endl;
	const int w = 1000, h = 1000;
	cout << "foo creating 2DArrays" << endl;
	array2D<float> cur(w, h);
	array2D<float> next(w, h);

	cout << "foo creating 2D arrays" << endl;
	float curr[w][h], nex[w][h], dest[w][h];
	float gpu_curr[w][h], gpu_next[w][h];

	// Make initial conditions
	cout << "foo initializing arrays" << endl;
	for (int y = 0;y<cur.ny();y++)
		for (int x = 0;x<cur.nx();x++)
		{
			cur(x, y) = fmod(0.01*sqrt(x*x + y*y), 1.0);
			// subtle: need boundary conditions for next array
			next(x, y) = cur(x, y);
			curr[x][y] = cur(x, y);
			nex[x][y] = cur(x, y);
		}
	

	// Run a few iterations of blurring
	enum { nblur = 100 };

	cout << "foo allocating and copying arrays to gpu" << endl;
	cudaMalloc((void**)&gpu_curr, w * h * sizeof(float));
	cudaMalloc((void**)&gpu_next, w * h * sizeof(float));
	cudaMemcpy(gpu_curr, curr, w * h * sizeof(float), cudaMemcpyHostToDevice);
	cudaMemcpy(gpu_next, nex, w * h * sizeof(float), cudaMemcpyHostToDevice);

	cout << "foo running blur on gpu" << endl;
	std::chrono::time_point<std::chrono::high_resolution_clock> start, end;
	start = std::chrono::high_resolution_clock::now();
	/* 	for (int blur=0;blur<nblur;blur++)
	{
	for (int y=1;y<cur.ny()-1;y++)
	for (int x=1;x<cur.nx()-1;x++)
	{
	next(x,y)=0.25*(cur(x-1,y)+cur(x+1,y)+cur(x,y-1)+cur(x,y+1));
	}
	cur.swap(next);
	} */
	blur<<<999, 999 >>>(gpu_curr, gpu_next);

	end = std::chrono::high_resolution_clock::now();;
	std::chrono::duration<double> elapsed = end - start;
	cout << "Performance: " << elapsed.count() / ((w - 2)*(h - 2)*nblur)*1.0e9 << " ns/pixel\n";

	cudaDeviceSynchronize();

	cout << "foo finished bluring, copying data back from gpu" << endl;
	cudaMemcpy(dest, gpu_curr, w*h*sizeof(float), cudaMemcpyDeviceToHost);

	cout << "foo cleaning up gpu resources" << endl;
	cudaFree(gpu_curr);
	cudaFree(gpu_next);
	cudaDeviceReset();
	
	cout << "foo writing blurred data back to 2DArray class" << endl;
	for (int y = 0;y<cur.ny();y++)
		for (int x = 0;x<cur.nx();x++)
		{
			cur(x, y) = dest[x][y];
		}
	// Dump final image (good for debugging)
	write(cur, "out.ppm");
	cout << "foo complete" << endl;
}


int main()
{
	cout << "pre foo" << endl;
	try {
		I_pity_the_foo();
	}
	catch (const std::exception & e)
	{
		cout << e.what() << endl;
	}
	cout << "post foo" << endl;
	return 0;
}