FILEID_TESTTILES_BANK                   equ 0
FILEID_TESTTILES_MAP                    equ 1
FILEID_TESTTILES_PALETTE                equ 2
FILEID_TESTTILES_PLANAR                 equ 3
FILEID_UNTITLED_SPLASH_BANK             equ 4
FILEID_UNTITLED_SPLASH_MAP              equ 5
FILEID_UNTITLED_SPLASH_PALETTE          equ 6
FILEID_UNTITLED_SPLASH_PLANAR           equ 7

FileIDMap:
	dc.w	_data_testtiles_bank_pos,_data_testtiles_bank_length
	dc.w	_data_testtiles_map_pos,_data_testtiles_map_length
	dc.w	_data_testtiles_palette_pos,_data_testtiles_palette_length
	dc.w	_data_testtiles_planar_pos,_data_testtiles_planar_length
	dc.w	_data_untitled_splash_bank_pos,_data_untitled_splash_bank_length
	dc.w	_data_untitled_splash_map_pos,_data_untitled_splash_map_length
	dc.w	_data_untitled_splash_palette_pos,_data_untitled_splash_palette_length
	dc.w	_data_untitled_splash_planar_pos,_data_untitled_splash_planar_length
