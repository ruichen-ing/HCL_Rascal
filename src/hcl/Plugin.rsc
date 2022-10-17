module hcl::Plugin
import hcl::Check;
import hcl::Parser;  
import hcl::CST2AST;
import IO;
import ParseTree;
import util::IDE;
import Prelude;

/*
* This function is defined to test the functionality of the whole assignment. It receives a file path as a parameter and returns true if the program satisfies the specification or false otherwise.
* First, it calls the parser (Parser.rsc). Then, it transforms the resulting parse tree of the previous program and calls the function cst2ast (CST2AST.rsc), responsible for transforming a parse tree into an abstract syntax tree.
* Finally, the resulting AST is used to evaluate the well-formedness of the ccl program using the check function (Check.rsc).
*/
bool checkWellformedness(loc fil) {
	// Parsing
	&T resource = parseHCL(fil);
	// Transform the parse tree into an abstract syntax tree
	&T ast = cst2ast(resource);
	// Check the well-formedness of the program
	try
		return checkHardwareConfiguration(ast);
	catch exception(str desc, loc l):{ 
		print(l);
		print(":");
		println(desc);
		return false;
	}
}

/*
* This is the main function of the project. This function enables the editor's syntax highlighting.
* After calling this function from the terminal, all files with extension .hcl will be parsed using the parser defined in module hcl::Parser.
* If there are syntactic errors in the program, no highlighting will be shown in the editor.
*/
void main() {
	registerLanguage("HCL - DSLD", "hcl", Tree(str _, loc path) {
		return parseHCL(path);
  	});

	// test program demonstrating the correct parsing
	loc dir = |project://DSLD2022-hcl/examples/correct_example.hcl|;	//computer 1, 2
	println("--------------------------------------------");
  	checkWellformedness(dir);
  	println("--------------------------------------------");
  	
  	// For the file with multiple errors: every time only the first found error is reported.
  	
  	// error: One of the three computer components(storage, processing, display) is missed. e.g., Only instances of processing and display are defined, but storage is missing
	dir = |project://DSLD2022-hcl/examples/error_complete.hcl|;			//computer 3
  	checkWellformedness(dir);
  	println("--------------------------------------------");
  	
  	// error: One of units of a computer component is missed. e.g., In the definition of a processing, the unit 'l1' is missing.
	dir = |project://DSLD2022-hcl/examples/error_complete_2.hcl|;		//computer 4
  	checkWellformedness(dir);
  	println("--------------------------------------------");
  	
  	// error: The selected component is not defined in the file. e.g., A storage component 'HDD512' is selected to configure the computer, but 'HDD512' is not defined.
	dir = |project://DSLD2022-hcl/examples/error_undef_label.hcl|;		//computer 5
  	checkWellformedness(dir);
  	println("--------------------------------------------");
  	
  	// error: There are components with the same name. e.g., Two processing components having the duplicated name 'naive_CPU'.
	dir = |project://DSLD2022-hcl/examples/error_uniq_label.hcl|;		//computer 6
  	checkWellformedness(dir);
	println("--------------------------------------------");
	
	// error: The total storage size is more than 8192 GiB.
	dir = |project://DSLD2022-hcl/examples/error_storage.hcl|;			//computer 7
  	checkWellformedness(dir);
	println("--------------------------------------------");
	
	// error: The size of L1 or L2 or L3 CPU exceeds its maximum allowed size. e.g. The size of a L2 is more than 8 MiB.
	dir = |project://DSLD2022-hcl/examples/error_cache_size.hcl|;		//computer 8
  	checkWellformedness(dir);
	println("--------------------------------------------");
	
	// error: The sizes of L1, L2, L3 does not fulfill the order L1 < L2 < L3.
	dir = |project://DSLD2022-hcl/examples/error_cache_order.hcl|;		//computer 9
  	checkWellformedness(dir);
  	println("--------------------------------------------");
  	
  	// error: There are components with different labels but the same configuration. If there are two components with the same label and configuration, then the 'duplicated label' exception will first be raised.
	dir = |project://DSLD2022-hcl/examples/error_dup.hcl|;				//computer 10
  	checkWellformedness(dir);
  	
  	// The display type is validated by Syntax.rsc. 
  	// The primitive data type supported by the language is validated by Syntax.rsc.
  	// The data type of core, memory and storage’s size is validated by Syntax.rsc.
}

