;	_align_on_chunk
	cnop		0,_chunk_size

_data_untitled_splash_bank:
	incbin	"../src/incbin/untitled_splash_bank.bin"
_data_untitled_splash_bank_pos				equ _data_untitled_splash_bank/_chunk_size
_data_untitled_splash_bank_length			equ ((_data_untitled_splash_bank_end-_data_untitled_splash_bank)+(_chunk_size-1))/_chunk_size
_data_untitled_splash_bank_end:

;	_align_on_chunk
	cnop		0,_chunk_size

_data_untitled_splash_map:
	incbin	"../src/incbin/untitled_splash_map.bin"
_data_untitled_splash_map_pos				equ _data_untitled_splash_map/_chunk_size
_data_untitled_splash_map_length			equ ((_data_untitled_splash_map_end-_data_untitled_splash_map)+(_chunk_size-1))/_chunk_size
_data_untitled_splash_map_end:

;	_align_on_chunk
	cnop		0,_chunk_size

_data_untitled_splash_palette:
	incbin	"../src/incbin/untitled_splash_palette.bin"
_data_untitled_splash_palette_pos				equ _data_untitled_splash_palette/_chunk_size
_data_untitled_splash_palette_length			equ ((_data_untitled_splash_palette_end-_data_untitled_splash_palette)+(_chunk_size-1))/_chunk_size
_data_untitled_splash_palette_end:

;	_align_on_chunk
	cnop		0,_chunk_size

_data_untitled_splash_planar:
	incbin	"../src/incbin/untitled_splash_planar.bin"
_data_untitled_splash_planar_pos				equ _data_untitled_splash_planar/_chunk_size
_data_untitled_splash_planar_length			equ ((_data_untitled_splash_planar_end-_data_untitled_splash_planar)+(_chunk_size-1))/_chunk_size
_data_untitled_splash_planar_end:

