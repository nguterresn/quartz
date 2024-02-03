#include <stdio.h>
#include "test_lib.h"

int add(int a, int b)
{
	return a + b;
}

int main()
{
	int a, b;

	printf("Enter number a: ");
	scanf("%d", &a);
	printf("Enter number b: ");
	scanf("%d", &b);

	printf("Mux result -> %d", mux(a, b)); // Uses `mux` method
}
