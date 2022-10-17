computer my_computer_5 {
	storage SSD512 {
		storage: SSD of 512 GiB
	},
	storage SSD128 {
		storage: SSD of 128 GiB
	},
	storage HDD128 {
		storage: HDD of 128 GiB
	},
	processing naive_CPU {
		cores: 4,
		speed: 1.25 Ghz,
		L1: 64 KiB,
		L2: 4 MiB,
		L3: 15 MiB
	},
	processing advanced_CPU {
		L2: 4 MiB,
		cores: 4,
		L1: 64 KiB,
		speed: 2 Ghz,
		L3: 15 MiB
	},
	display high_display {
		diagonal: 30 inch,
		type: 5K
	},
	SSD512,
	HDD512,
	naive_CPU,
	high_display
}