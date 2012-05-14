int main() {
	if (1) {
		if (0) {
			int a = 1;
			printf(a);
		} else {
			int b = 2;
			printf(b);
			if(1){
				printf(b);
			} else {
				printf(a);
			}
		}
	} else {
		int c = 3;
		printf(c);
	}
}
