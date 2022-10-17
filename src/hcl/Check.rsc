module hcl::Check

import Prelude;
import hcl::AST;

/*
 * -Implement a well-formedness checker for the HCL language. For this you must use the AST. 
 * - Hint: Map regular CST arguments (e.g., *, +, ?) to lists 
 * - Hint: Map lexical nodes to Rascal primitive types (bool, int, str)
 * - Hint: Use switch to do case distinction with concrete patterns
 */

 /*
 * Create a function called checkHardwareConfiguration(...), which is responsible for calling all the required functions that check the program's well-formedness as described in the PDF (Section 3.2.) 
 * This function takes as a parameter the program's AST and returns true if the program is well-formed or false otherwise.
 */
 
/*
* Define a function per each verification defined in the PDF (Section 3.2.)
*/

data EXP = exception(str desc, loc l);

/*
* Execute a well-formedness check for each computer defined in .hcl file
* If there are multiple errors in a .hcl file, every time the first found error is reported.
*/
bool checkHardwareConfiguration(AProgram program) {
	computers = program.computers;
	bool check = true;
	for(AComputer ac <- computers){
		bool isSucceeded = true;
		println("Checking hardware configuration for \'<ac.c_name>\'...");
		isSucceeded = checkCompleteness(ac)
					&& checkSelectedLabels(ac)
					&& checkLabels(ac)
					&& checkStorageSize(ac)
					&& checkCaches(ac)
					&& checkDuplicates(ac);
		if(isSucceeded){
			println("Well-formedness check for \'<ac.c_name>\' succeeded!");
		}else{
			println("Well-formedness check for \'<ac.c_name>\' failed!");
		}
		println();
		check = check && isSucceeded;
	}
	return check;
}

/*
* Check the completeness of the definition and declaration of the components.
* - There must be at least one instance for each one of the three computer components: storage, processing, display.
* - Each storage must contain at least one storage unit. Empty storage is mot allowed.
* - Each processing must contain exactly one unit of the following components: core, speed, l1, l2 and l3.
* - Each display must contain exactly one unit of the following components: diagonal, type.
* - It is allowed the categories of the selected items do not cover all the three types(storage, processing, display).   
*/
bool checkCompleteness(AComputer computer){
	set[str] hasElement = {};
	set[str] hasComponent = {};
	set[str] fullComponent = {"storage", "processing", "display"};
	set[str] fullProcessingElements = {"core", "speed", "l1", "l2", "l3"};
	set[str] fullDisplayElements = { "diagonal", "type"};
	list[str] diff = [];
	for(AComp c <- computer.comps){
		hasElement = {};
		switch(c) {
			case storageConf(str _, list[AS_comp] s_comps, src = loc ls): {
				hasComponent += "storage";
				if(isEmpty(s_comps) == true){
					throw exception("Missing component \'storage\' in the storage \'<c.s_name>\'.", ls);
				}
			}
			case processingConf(str _, list[AP_comp] _, src = loc lp): {
				hasComponent += "processing";
				for(AP_comp pc <- c.p_comps){
					switch(pc) {
						case coresConf(int _):
							hasElement += "core";
						case speedConf(num _): 
							hasElement += "speed";
						case l1_Conf(int _, str _):
							hasElement += "l1";
						case l2_Conf(int _, str _):
							hasElement += "l2";
						case l3_Conf(int _, str _):
							hasElement += "l3";
					}
				}
				diff = toList(fullProcessingElements -  hasElement);
				if(isEmpty(diff) == false){
					throw exception("Missing component \'<diff[0]>\' in the processing \'<c.p_name>\'.", lp);
				}
			}
			case displayConf(str _, list[AD_comp] _, src = loc ld): {
				hasComponent += "display";
				for(AD_comp dc <- c.d_comps){
					switch(dc) {
						case diagonalConf(int _):
							hasElement += "diagonal";
						case typeConf(str _):
							hasElement += "type";
					}
				}
				diff = toList(fullDisplayElements -  hasElement);
				if(isEmpty(diff) == false){
					throw exception("Missing component \'<diff[0]>\' in the display \'<c.d_name>\'.", ld);
				}			
			}
		}
	}
	diff = toList(fullComponent - hasComponent);
	if(isEmpty(diff) == false){
		throw exception("Missing component \'<diff[0]>\'.", computer.src);
	}
	return true;
}

/*
 * Check if the declared selected components are defined
 * It is allowed a component to be selected/declared before it is defined.
 */
bool checkSelectedLabels(AComputer computer){
	list[str] compNames = [];
	set[str] selectedNames = {};
	map[str, loc] selectedLoc = ();
	for(AComp c <- computer.comps){
		switch(c) {
			case storageConf(str name, list[AS_comp] _):
				compNames += name;
			case processingConf(str name, list[AP_comp] _):
				compNames += name;
			case displayConf(str name, list[AD_comp] _):
				compNames += name;
			case selectedConf(str name, src = loc l): {
				selectedNames += name;
				selectedLoc += (name: l);
			}
		}
	}
	list[str] selected = toList(selectedNames);
	for(str name <- selected){
		if(name notin compNames){
			throw exception("Component \'<name>\' is not defined.", selectedLoc[name]);
		}
	}
	return true;
}

/*
 * Check if all labels are unique
 */
bool checkLabels(AComputer computer){
	list[tuple[str, loc]] label_loc = getLabelList(computer);
	list[str] labels = [];
	for(tuple[str, loc] pair <- label_loc){
		labels += pair[0];
	}
	labels_dup = dup(labels);
	if(size(labels) == size(labels_dup)) {
		return true;
	}
	for(str ld <- labels_dup){
		int count = 0;
		for(str l <- labels){
			if(l == ld) count += 1;
		}
		if(count > 1){
			int index = indexOf(labels, ld);
		 	tuple[str, loc] temp = label_loc[index];
		 	throw exception("Duplicated label \'<temp[0]>\'.", temp[1]);
		 }
	}
	return false;
}

/*
 * Check if the total storage size of the selected components is greater than zero and less than or equal to 8192 GiB
 */
bool checkStorageSize(AComputer computer){
    list[str] selected = [];
    list[AComp] comps = computer.comps;
    int total_storage = 0;
    map[str, int] storConf = ();
	for (AComp comp <- comps) {
		switch (comp) {
			case storageConf(str name,  list[AS_comp] comps, src = loc l): {
				int sum = 0;
				for (AS_comp sc <- comps) {
					sum += sc.disk_size;
					if (sc.disk_size > 1024 || sc.disk_size < 32) {
						throw exception("Invalid storage size for \'<name>\'. Storage size must be in the range from 32 to 1024 GB.", l);
					}
				}
				storConf = storConf + (name: sum);
			}
			case selectedConf(str s):
				selected = selected + [s];
		}
	};
	for (str select <- selected) {
		if (select in storConf) {
			total_storage += storConf[select];
		}
	};
	if (total_storage <= 8192)
		return true;
	else
    	throw exception("Storage size can not exceed 8192 GiB.", computer.src);
}

/*
 * Check if the maximum size for L1, L2, L3 is 128 KiB, 8 MiB, 32 MiB repectively and whether L1 < L2 < L3
 */
bool checkCaches(AComputer computer){
    list[AComp] comps = computer.comps;
    list[AComp] procConfKeys = [];
	for (AComp comp <- comps) {
		switch (comp) {
			case processingConf(str _, list[AP_comp] p_comps):{
				procConfKeys = procConfKeys + [comp];
			}
		}
	};
	for (AComp comp <- procConfKeys){
		list[AP_comp] conf = comp.p_comps;
		int l1_val = 0;
		int l2_val = 0;
		int l3_val = 0;
		for (AP_comp p_comp <- conf) {
			switch (p_comp) {
				case l1_Conf(int size, str cu): {
					if (cu == "KiB") {
						l1_val = size;
					} else {
						l1_val = size * 1024;
					}
					if (l1_val > 128) {
						throw exception("The maximum L1 size is 128 KiB.", p_comp.src);
					}
				}
				case l2_Conf(int size, str cu): {
					if (cu == "KiB") {
						l2_val = size;
					} else {
						l2_val = size * 1024;
					}
					if (l2_val > (8 * 1024)) {
						throw exception("The maximum L2 size is 8 MiB.", p_comp.src);
					}
				}
				case l3_Conf(int size, str cu): {
					if (cu == "KiB") {
						l3_val = size;
					} else {
						l3_val = size * 1024;
					}
					if (l3_val > (32 * 1024)) {
						throw exception("The maximum L3 size is 32 MiB.", p_comp.src);
					}
				}
			}
		}
		if ((l1_val > l2_val) || (l2_val > l3_val)) {
			throw exception("Cache sizes must satisfy L1 \< L2 \< L3.", comp.src);
		}
	};
    return true;
}

/*
 * Check if there are duplicate components with the same configuration and different labels
 */
bool checkDuplicates(AComputer computer){
	// Transform each data to set, then remove duplicates.
	list[AComp] comps = computer.comps;
	list[set[value]] s_comps = [];
	list[set[value]] p_comps = [];
	list[set[value]] d_comps = [];
	for (AComp comp <- comps) {
		switch(comp) {
			case storageConf(str _, list[AS_comp] _): {
				set[set[value]] new = {};
				for (AS_comp attr <- comp.s_comp){
					inner_new = {};
					for (value inner_attr <- attr) {
						inner_new += {inner_attr};
					}
					new += {inner_new};
				}
				s_comps += [new]; 
			}
			case processingConf(str _, list[AP_comp] _): {
				set[set[value]] new = {};
				for (AP_comp attr <- comp.p_comps){
					inner_new = {};
					for (value inner_attr <- attr) {
						inner_new += {inner_attr};
					}
					new += {inner_new};
				}
				p_comps += [new];
			}
			case displayConf(str _, list[AD_comp] _): {
				set[set[value]] new = {};
				for (AD_comp attr <- comp.d_comps){
					inner_new = {};
					for (value inner_attr <- attr) {
						inner_new += {inner_attr};
					}
					new += {inner_new};
				}
				d_comps += [new];
			}
		}
	}
	if (size(s_comps) != size(dup(s_comps))) {
		throw exception("Duplicate storage configuration exists.", computer.src);
	}
	if (size(p_comps) != size(dup(p_comps))) {
		throw exception("Duplicate processing configuration exists.", computer.src);
	}
	if (size(d_comps) != size(dup(d_comps))) {
		throw exception("Duplicate display configuration exists.", computer.src);
	}
	return true;
}

/*
 * helper function: get labels of all components defined within a computer instance
 */
list[tuple[str, loc]] getLabelList(AComputer computer){
	list[tuple[str, loc]] labels = [];
	for(AComp c <- computer.comps){
		switch(c) {
			case storageConf(str name, list[AS_comp] _, src = loc l):
				labels += <name, l>;
			case processingConf(str name, list[AP_comp] _, src = loc l):
				labels += <name, l>;
			case displayConf(str name, list[AD_comp] _, src = loc l):
				labels += <name, l>;
		}
	}
	return labels;
}

