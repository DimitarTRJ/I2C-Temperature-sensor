#include "xiomodule.h"

XIOModule_Config XIOModule_ConfigTable[] __attribute__ ((section (".drvcfg_sec"))) = {

	{
		"xlnx,iomodule-3.1", /* compatible */
		0x80000000,
		0xc0000000, /* reg */
		0x1, /* xlnx,intc-has-fast */
		0x0, /* xlnx,intc-base-vectors */
		0x11, /* xlnx,intc-addr-width */
		0x7fff, /* xlnx,intc-level-edge */
		0x1, /* xlnx,options */
		0x5f5e100, /* xlnx,clock-freq */
		0x2580, /* xlnx,uart-baudrate */
		{0,  0,  0,  0}, /* xlnx,pit-used */
		{32,  32,  32,  32}, /* xlnx,pit-size */
		{4294967295,  4294967295,  4294967295,  4294967295}, /* xlnx,pit-mask */
		{0,  0,  0,  0}, /* xlnx,pit-prescaler */
		{1,  1,  1,  1}, /* xlnx,pit-readable */
		{0,  0,  0,  0}, /* xlnx,gpo-init */
		{{0U}} /* Handler-table */
	},
	 {
		 NULL
	}
};