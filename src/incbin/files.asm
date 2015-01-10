FILEID_UNTITLED_SPLASH_BANK			equ			0
FILEID_UNTITLED_SPLASH_MAP			equ			1
FILEID_UNTITLED_SPLASH_PALETTE		equ			2

FileIDMap:
				dc.w	_data_untitled_splash_bank_pos
				dc.w	_data_untitled_splash_bank_length

				dc.w	_data_untitled_splash_map_pos
				dc.w	_data_untitled_splash_map_length

				dc.w	_data_untitled_splash_palette_pos
				dc.w	_data_untitled_splash_palette_length
				
				;dc.w	_data_untitled_splash_bank/_chunksize,((_data_untitled_splash_bank_end-_data_untitled_splash_bank)+(_chunksize-1))/_chunksize
				;dc.w	_data_untitled_splash_map/_chunksize,((_data_untitled_splash_map_end-_data_untitled_splash_map)+(_chunksize-1))/_chunksize
				;dc.w	_data_untitled_splash_palette/_chunksize,((_data_untitled_splash_palette_end-_data_untitled_splash_palette)+(_chunksize-1))/_chunksize
