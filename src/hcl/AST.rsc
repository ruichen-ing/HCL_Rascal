module hcl::AST

/*
 * Define the Abstract Syntax for HCL
 *
 * - make sure there is an almost one-to-one correspondence with the grammar in Syntax.rsc
 */
 
data AProgram(loc src = |tmp:///|)
	= program(list[AComputer] computers);

data AComputer(loc src = |tmp:///|)
	= computer(str c_name, list[AComp] comps);
	
data AComp(loc src = |tmp:///|)
	= storageConf(str s_name, list[AS_comp] s_comp)
	| processingConf(str p_name, list[AP_comp] p_comps)
	| displayConf(str d_name, list[AD_comp] d_comps)
	| selectedConf(str selected);

data AS_comp(loc src = |tmp:///|)
	= storage(str disk_type, int disk_size);

data AP_comp(loc src = |tmp:///|)
	= coresConf(int n_core)
	| speedConf(num speed)
	| l1_Conf(int l1, str cu1)
	| l2_Conf(int l2, str cu2)
	| l3_Conf(int l3, str cu3);

data AD_comp(loc src = |tmp:///|)
	= diagonalConf(int diag_size)
	| typeConf(str dp_type);