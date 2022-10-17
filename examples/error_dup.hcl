computer my_computer_10 {
	storage SSD512 {
		storage: SSD of 512 GiB,
		storage: SSD of 512 GiB
	},
	processing advanced_CPU {
		L2: 4 MiB,
		cores: 4,
		L1: 64 KiB,
		speed: 2 Ghz,
		L3: 15 MiB
	},
	processing dup_advanced_CPU {
		cores: 4,
		L1: 64 KiB,
		L2: 4 MiB,
		speed: 2 Ghz,
		L3: 15 MiB
	},
	display high_display {
		diagonal: 30 inch,
		type: 5K
	},
	SSD512,
	high_display,
	advanced_CPU
}