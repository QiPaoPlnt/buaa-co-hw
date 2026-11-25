#include<bits/stdc++.h>
#include<random>
#include<chrono>
#include<functional>
using namespace std;

//requires -std=c++11 for better random, function call, and vector usage
//ofc you can change it to rand() and srand(time(0)), func ptr, and push_back()
#if __cplusplus < 201103L
#error "requires -std=c++11"
#endif

//TODO: judge dead loop
//upd: TODO2: destroy discrete math to make sure TODO is possible

//utils

mt19937 gen;

void init_rand() {
	long long seed = chrono::high_resolution_clock::now().time_since_epoch().count();
	gen.seed(seed);
}

int nextInt(int l, int r) {
	uniform_int_distribution<> distrib(l, r);
	return distrib(gen);
}

int nextWordInt(int l, int r) {
	int word_cnt = (r - l + 1) / 4;
	uniform_int_distribution<> distrib(0, word_cnt - 1);
	return distrib(gen) << 2;
} 

string printInt(int d) {
	if(!d) return "0"; 
	string builder = "";
	bool flag = false;
	if(d < 0) {
		flag = true;
		d *= -1;
	}
	while(d > 0) {
		builder += (d % 10) + '0';
		d /= 10;
	}
	if(flag) d += '-';
	reverse(builder.begin(), builder.end());
	return builder;
}

string replaceAll(string str, string from, string to) {
    int start_pos = 0;
    while((start_pos = str.find(from, start_pos)) != string::npos) {
        str.replace(start_pos, from.length(), to);
        start_pos += to.length(); 
    }
    return str;
}

string replaceAll(string str, string from, function<string()> replace_gen) {
    int start_pos = 0;
    while((start_pos = str.find(from, start_pos)) != string::npos) {
    	string to = replace_gen();
        str.replace(start_pos, from.length(), to);
        start_pos += to.length(); 
    }
    return str;
}

//definitions

const int MAX_LINE = 500;

const int LOWEST_MEM = 0;
//const int HIGHEST_MEM = 12287; //0x00002fff 
const int HIGHEST_MEM = 4095; //use 0x00001000 as defined in mars 

string header = ".data\n    claim_it_all: .space 4096\n.text\n"; 

//randomly(?) chosen init value to aviod dead loop
//magic values, yeah
int init_values[] = {0, 11, 45, 14, 19, 
						191, 98, 810, 325, 2537, 
						2506, 2026, 1028, 250, 1314, 2537, 
						1008, 5090, 2077, 12345, 5201314, 
						987654321, 123456789, 50000000, 321987654,
						789012345, 2147483647, 1111111111, 676767676, 1004300,
						114514, 0}; //requires $ra = 0 for jal & jr judgement

//load immediate to registers through lui and ori
//lui $target, immediate_high_16
//ori $target, $target, immediate_low_16
string initializer() {
	string builder = "", temp = "lui $", temp2 = "ori $";
	for(int i = 1; i < 32; i ++) {
		builder += temp;
		builder += printInt(i);
		builder += ", ";
		builder += printInt(init_values[i] >> 16); //can be changed to randomly chosen as well
		builder += '\n';
		builder += temp2;
		builder += printInt(i);
		builder += ", $";
		builder += printInt(i);
		builder += ", ";
		builder += printInt((init_values[i]) % (1 << 16));
		builder += '\n';
	}
	return builder;
}

//after last input, logisim will not perform any other operations and will not change any registers
string tail = "nop\n";

vector<string> templates = {
	"add $%32%, $%32%, $%32%",
	"sub $%32%, $%32%, $%32%",
	"ori $%32%, $%32%, %short%",
	"lw $%32%, %mem%", //use fake command to ensure memory safety
	"sw $%32%, %mem%",
	"beq $%32%, $%32%, label_%lrandom%",
	"lui $%32%, %short%",
	"nop",
	"label_%lcount%:" ,
	//P4 edition 
	"beq $31, $0, label_%lsize% \njr $ra \nlabel_%lcount%: \njal label_%llast% \nsub $31, $31, $31 \nlabel_%lcount%:"
};

//we have safety modify functions, dont need them anymore
////percent.
//const int LOW_CHANCE_VALUE = 5;
//
////used when low chance judge succeeded
//vector<string> low_chance_templates = {
//	
//};

//funcs

int label_count;

int count_used; //in order to rollback count change when command cancelled

string strLCount() {
	count_used ++;
	return printInt(label_count ++);
}

string strLLast() {
	return printInt(label_count - 1);
}

string strLSize() {
	return printInt(label_count);
}

string randomStrLabel() {
	return printInt(nextInt(0, label_count - 1 - 1)); //add 1 more exclusion for safety
}

int last_reg = -1;

string randomStr32() {
	int res = nextInt(0, 30); //not allowed to modify $31 
	return printInt(res == last_reg ? (last_reg = ((res + 1) % 31)) : (last_reg = res));
}

string randomStrShort() {
	return printInt(nextInt(-32768, 32767));
}

string randomStrMem() {
	return printInt(nextWordInt(LOWEST_MEM, HIGHEST_MEM));
}

//safety modification for beq
//to avoid dead loop and modify of $0 (which also causes dead loop)
string specialParseForBEQ(string ori) {
	string sub = ori.substr(4);
	string reg;
	if(sub[2] == ',') reg = sub.substr(0, 2); //$x, ?
	else reg = sub.substr(0, 3); //$xx,
	
	if(reg == "$0") return ""; //ohno, we attempt to modify $0, how could it possible? better destroy it
	if(reg == "$31") return ori; //if we use $31 as target, we are manually using it, so we just trust it
	
	//to ensure not always equal to a constant
	//we should break the current state
	string temp = "ori " + reg + ", " + reg + ", 1\n"
					+ "add " + reg + ", " + reg + ", " + reg + "\n"
					+ ori;
	return temp;
}

string processPlaceholder(string ori) {
	count_used = 0;
	ori = replaceAll(ori, "%32%", randomStr32);
	ori = replaceAll(ori, "%short%", randomStrShort);
	ori = replaceAll(ori, "%mem%", randomStrMem);
	if(ori.find("%llast%", 0) != string::npos) {
		if(!label_count) {
			label_count -= count_used;
			return "";
		}
		else {
			ori = replaceAll(ori, "%llast%", strLLast);
		}
	}
	if(ori.find("%lsize%", 0) != string::npos) {
		ori = replaceAll(ori, "%lsize%", strLSize);
	}
	if(ori.find("%lcount%", 0) != string::npos) {
		ori = replaceAll(ori, "%lcount%", strLCount);
	}
	if(ori.find("%lrandom%", 0) != string::npos) {
		if(label_count <= 1) {
			label_count -= count_used;
			return "";
		}
		else {
			ori = replaceAll(ori, "%lrandom%", randomStrLabel);
		}
	}
	
	//decrease the possibility of dead loop
	if(ori.substr(0, 3) == "beq") ori = specialParseForBEQ(ori);
	
	if(ori == "") label_count -= count_used;
	return ori;
}

string genNextLine() {
//	int low_chance_judge = nextInt(0, 100);
//	if(low_chance_judge < LOW_CHANCE_VALUE) return processPlaceholder(low_chance_templates[nextInt(0, low_chance_templates.size() - 1)]);
//	else 
		return processPlaceholder(templates[nextInt(0, templates.size() - 1)]);
}

vector<char> dmca = {0x23, 0x41, 0x75, 0x74, 0x68, 0x6f, 0x72, 0x3a, 0x20, 0x32, 0x35, 0x33, 0x37, 0x31, 0x30, 0x30, 0x38, 0x0a};

string getCPR() {
	string builder = "";
	for(int i = 0; i < dmca.size(); i ++) {
		builder += dmca[i]; 
	}
	return builder;
}

int main() {
	init_rand();
	ofstream output_compile("gen_mips_source.asm");
	ofstream output_simulate("gen_mips_source_simulate.asm");
	output_compile << getCPR();
	output_compile << header;
	output_compile << initializer();
	output_simulate << getCPR();
	output_simulate << header;
	output_simulate << initializer();
	for(int i = 0; i < MAX_LINE; i ++) {
		string nxtline = genNextLine();
		string forsimulate = replaceAll(replaceAll(nxtline, "add ", "addu "), "sub ", "subu ");
		output_compile << nxtline << endl;
		output_simulate << forsimulate << endl;
	}
	output_compile << tail;
	output_simulate << tail;
	output_compile.close();
	output_simulate.close();
	return 0;
}
