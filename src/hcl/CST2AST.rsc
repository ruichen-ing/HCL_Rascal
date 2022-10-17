module hcl::CST2AST

import hcl::AST;
import hcl::Syntax;

import ParseTree;
import String;

/*
 * Implement a mapping from concrete syntax trees (CSTs) to abstract syntax trees (ASTs)
 * Hint: Use switch to do case distinction with concrete patterns
 * Map regular CST arguments (e.g., *, +, ?) to lists
 * Map lexical nodes to Rascal primitive types (bool, int, str)
 */
 
// Transforms a .hcl program to multiple of computers
AProgram cst2ast(start[Program] sp) {
	Program p = sp.top;
	AProgram result = program(toList(p.computers), src=p@\loc);  // Tree@\loc: Annotate a parse tree node with a source location
	return result;
}

list[AComputer] toList(Computer* computers){
	return [cst2ast(c) | (Computer c <- computers)];
}

AComputer cst2ast(Computer c){
	switch(c){
		case (Computer)`computer <Str c_name> { <{Comp ","}* comps>}`:
			return computer(
				"<c_name>",
				[cst2ast(c) | Comp c <- comps], 
				src=c@\loc);				
		default:
			throw "Unhandled computer: <c>";
	}
}

AComp cst2ast(Comp c){
	switch(c){
		case (Comp)`storage <Str s_name> { <{S_comp ","}* s_comps> }`:
			return storageConf("<s_name>", [cst2ast(sc) | sc <- s_comps], src=c@\loc);
		case (Comp)`processing <Str p_name> { <{P_comp ","}* p_comps> }`:
			return processingConf("<p_name>", [cst2ast(pc) | P_comp pc <- p_comps], src=c@\loc);
		case (Comp)`display <Str d_name> { <{D_comp ","}* d_comps> }`:
			return displayConf("<d_name>", [cst2ast(dc) | D_comp dc <- d_comps], src=c@\loc);
		case (Comp)`<Str selected>`:
			return selectedConf("<selected>", src=c@\loc);
		default:
			throw "Unhandled component: <c>";
	}
}

AS_comp cst2ast(S_comp sc){
	switch(sc){
		case (S_comp)`storage: <Disk_type disk_type> of <Int disk_size> GiB`:
			return storage("<disk_type>", toInt("<disk_size>"), src=sc@\loc); 
		default:
			throw "Unhandled storage component: <sc>";
	}
}

AP_comp cst2ast(P_comp pc){
	switch(pc){
		case (P_comp)`cores: <Int n_core>`:
			return coresConf(toInt("<n_core>"), src=pc@\loc);
		case (P_comp)`speed: <UnsignedReal speed> Ghz`:	
			return speedConf(toReal("<speed>"), src=pc@\loc);
		case (P_comp)`L1: <Int l1> <CPU_unit cu1>` :
			return l1_Conf(toInt("<l1>"), "<cu1>", src=pc@\loc);
		case (P_comp)`L2: <Int l2> <CPU_unit cu2>`:
			return l2_Conf(toInt("<l2>"), "<cu2>", src=pc@\loc);
		case (P_comp)`L3: <Int l3> <CPU_unit cu3>`:
			return l3_Conf(toInt("<l3>"), "<cu3>", src=pc@\loc);
		default:
			throw "Unhandled processing component: <pc>"; 
	}
}

AD_comp cst2ast(D_comp dc){
	switch(dc){
		case (D_comp)`diagonal: <Int diag_size> inch`:
			return diagonalConf(toInt("<diag_size>") ,src=dc@\loc);
		case (D_comp)`type: <Display_type dp_type>`:
			return typeConf("<dp_type>" ,src=dc@\loc);
		default:
			throw "Unhandled display component: <dc>";
	}
}
