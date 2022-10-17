module hcl::Parser

import ParseTree;  
import hcl::Syntax;  

/*
 * Define the parser for the HCL language. The name of the function must be parseHCL.
 * This function receives as a parameter the path of the file to parse represented as a loc, and returns a parse tree that represents the parsed program.
 */
  
public start[Program] parseHCL(loc fil){
	return parse(#start[Program], fil);
}