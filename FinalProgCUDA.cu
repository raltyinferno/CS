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
__global__ void blur(float *cur, float *next)
{
	int w =999;
	int y = threadIdx.x+1;
	int x = blockIdx.x+1;
	float temp;
	for (int iter = 0;iter < 100;++iter)
	{
		next[y*w+x] = 0.25*(cur[x - 1+w*y] + cur[x + 1+w*y] + cur[x+w*(y - 1)] + cur[x+w*(y + 1)]);

		temp = next[x+w*y];
		next[x+w*y] = cur[x+w*y];
		cur[x+w*y] = temp;
		
	}
	
	
}
void I_pity_the_foo() {
	//cout << "foo begin" << endl;
	const int w = 1000, h = 1000;
	//cout << "foo creating Array2Ds" << endl;
	array2D<float> cur(w, h);
	array2D<float> next(w, h);

	//cout << "foo creating 2D arrays" << endl;

	float host_curr[w*h], host_next[w*h];
	float * host_dest = new float[w*h];
	float *gp_curr = nullptr;
	float *gp_next = nullptr;

	// Make initial conditions
	//cout << "foo initializing arrays" << endl;
	for (int y = 0;y<cur.ny();y++)
		for (int x = 0;x<cur.nx();x++)
		{
			cur(x, y) = fmod(0.01*sqrt(x*x + y*y), 1.0);
			// subtle: need boundary conditions for next array
			next(x, y) = cur(x, y);
			host_curr[y*w+x]=cur(x,y);
			host_next[y*w+x]=cur(x,y);
		}
	

	// Run a few iterations of blurring
	enum { nblur = 100 };

	//cout << "foo allocating and copying arrays to gpu" << endl;


	//cout << "foo running blur on gpu" << endl;
	std::chrono::time_point<std::chrono::high_resolution_clock> start, end;
	start = std::chrono::high_resolution_clock::now();
	
	
	cudaMalloc((void**)&gp_curr, w * h * sizeof(float));
	cudaMalloc((void**)&gp_next, w * h * sizeof(float));
	cudaMemcpy(gp_curr, host_curr, w * h * sizeof(float), cudaMemcpyHostToDevice);
	cudaMemcpy(gp_next, host_next , w * h * sizeof(float), cudaMemcpyHostToDevice);
	blur<<<999, 999 >>>(gp_curr, gp_next);
	cudaDeviceSynchronize();
	cudaMemcpy(host_dest, gp_curr, w*h*sizeof(float), cudaMemcpyDeviceToHost);
	
	
	end = std::chrono::high_resolution_clock::now();;
	std::chrono::duration<double> elapsed = end - start;
	cout << "Performance: " << elapsed.count() / ((w - 2)*(h - 2)*nblur)*1.0e9 << " ns/pixel\n";

	

	//cout << "foo finished bluring, copying data back from gpu" << endl;


	//cout << "foo cleaning up gpu resources" << endl;
	cudaFree(gp_curr);
	cudaFree(gp_next);
	cudaDeviceReset();
	
	
	//cout << "foo writing blurred data back to 2DArray class" << endl;
	for (int y = 0;y<cur.ny();y++)
		for (int x = 1;x<cur.nx()-1;x++)
		{
			cur(x, y) = host_dest[x+w*y];
		}
		
	//cout << "foo writing image output" << endl;	
	// Dump final image (good for debugging)
	write(cur, "out.ppm");

	delete[] host_dest;

	//cout << "foo complete" << endl;
}


int main()
{
	//cout << "pre foo" << endl;
	try {
		I_pity_the_foo();
	}
	catch (const std::exception & e)
	{
		cout << e.what() << endl;
	}
	//cout << "post foo" << endl;
	return 0;
}