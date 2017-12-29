void DoInventory(int cmd);
void GoInDirection(int direction, int distance);

void PrintStr(char * str);

#define abs(a) ((a)<0?-(a):(a))

struct point{
	int x;
	int y;
};

int manhattanDistance(struct point a, struct point b){
	return abs(a.x-b.x)+abs(a.y-b.y);
}

int TestFunc(int a, int b){
	return a*a+b*b;
}

char str[] = "Hello World!\n";

void c_main(void){
	struct point a = { 1, 1 }, b = { 10, 5 };
	PrintStr(str);
	manhattanDistance(a,b);
	DoInventory(1);
	GoInDirection(0,10);
	GoInDirection(1,5);
}
