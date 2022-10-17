module hcl::Syntax

extend lang::std::Layout;

/*
 * Define a concrete syntax for HCL. The langauge's specification is available in the PDF (Section 3)
 */
start syntax Program = Computer* computers;

syntax Computer = "computer" Str c_name "{" {Comp ","}* !>> "," "}";    // Allow multiple computers to be defined in a single .hcl file

syntax Comp 
	= storageConf: "storage" Str s_name "{" {S_comp ","}* !>> "," "}"
	| processingConf: "processing" Str p_name "{" {P_comp ","}* !>> "," "}"
	| displayConf: "display" Str d_name "{" {D_comp ","}* !>> "," "}"
	| selectedConf: Str selected;

syntax S_comp = "storage"":" Disk_type disk_type "of" Int disk_size "GiB";

syntax Disk_type = "SSD" | "HDD";

syntax P_comp 
	= coresConf: "cores"":" Int n_core
	| speedConf: "speed"":" UnsignedReal speed "Ghz"
	| l1_Conf: "L1"":" Int l1 CPU_unit cu1
	| l2_Conf: "L2"":" Int l2 CPU_unit cu2 
	| l3_Conf: "L3"":" Int l3 CPU_unit cu3;

syntax CPU_unit = "KiB" | "MiB";

syntax D_comp 
	= diagonalConf: "diagonal"":" Int diag_size "inch" 
	| typeConf: "type"":" Display_type dp_type;

syntax Display_type = "HD" | "Full-HD" | "4K" | "5K";

lexical Str = [a-z A-Z 0-9 _ \-] !<< [a-z A-Z][a-z A-Z 0-9 _ \-]* !>> [a-z A-Z 0-9 _ \-];
lexical Int = [0-9] !<< [1-9][0-9]* !>> [0-9];
lexical UnsignedInt = [0] | ([1-9][0-9]*);
lexical SignedInt = [+\-]? UnsignedInt;
lexical UnsignedReal = UnsignedInt [.] [0-9] + ([eE] SignedInt)?
					 | UnsignedInt [eE] SignedInt 
					 | UnsignedInt;