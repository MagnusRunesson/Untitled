

; herotest_sprite_chunky.bin

	cnop		0,_chunk_size
_data_herotest_sprite_chunky:
	incbin	"../src/incbin/herotest_sprite_chunky.bin"
_data_herotest_sprite_chunky_pos        equ _data_herotest_sprite_chunky/_chunk_size
_data_herotest_sprite_chunky_length     equ ((_data_herotest_sprite_chunky_end-_data_herotest_sprite_chunky)+(_chunk_size-1))/_chunk_size
_data_herotest_sprite_chunky_end:


; herotest_sprite_amiga.bin

	cnop		0,_chunk_size
_data_herotest_sprite_amiga:
	incbin	"../src/incbin/herotest_sprite_amiga.bin"
_data_herotest_sprite_amiga_pos         equ _data_herotest_sprite_amiga/_chunk_size
_data_herotest_sprite_amiga_length      equ ((_data_herotest_sprite_amiga_end-_data_herotest_sprite_amiga)+(_chunk_size-1))/_chunk_size
_data_herotest_sprite_amiga_end:


; herotest_palette.bin

	cnop		0,_chunk_size
_data_herotest_palette:
	incbin	"../src/incbin/herotest_palette.bin"
_data_herotest_palette_pos              equ _data_herotest_palette/_chunk_size
_data_herotest_palette_length           equ ((_data_herotest_palette_end-_data_herotest_palette)+(_chunk_size-1))/_chunk_size
_data_herotest_palette_end:


; herotest_sprite.bin

	cnop		0,_chunk_size
_data_herotest_sprite:
	incbin	"../src/incbin/herotest_sprite.bin"
_data_herotest_sprite_pos               equ _data_herotest_sprite/_chunk_size
_data_herotest_sprite_length            equ ((_data_herotest_sprite_end-_data_herotest_sprite)+(_chunk_size-1))/_chunk_size
_data_herotest_sprite_end:


; herotest_big_sprite_chunky.bin

	cnop		0,_chunk_size
_data_herotest_big_sprite_chunky:
	incbin	"../src/incbin/herotest_big_sprite_chunky.bin"
_data_herotest_big_sprite_chunky_pos    equ _data_herotest_big_sprite_chunky/_chunk_size
_data_herotest_big_sprite_chunky_length equ ((_data_herotest_big_sprite_chunky_end-_data_herotest_big_sprite_chunky)+(_chunk_size-1))/_chunk_size
_data_herotest_big_sprite_chunky_end:


; herotest_big_sprite_amiga.bin

	cnop		0,_chunk_size
_data_herotest_big_sprite_amiga:
	incbin	"../src/incbin/herotest_big_sprite_amiga.bin"
_data_herotest_big_sprite_amiga_pos     equ _data_herotest_big_sprite_amiga/_chunk_size
_data_herotest_big_sprite_amiga_length  equ ((_data_herotest_big_sprite_amiga_end-_data_herotest_big_sprite_amiga)+(_chunk_size-1))/_chunk_size
_data_herotest_big_sprite_amiga_end:


; herotest_big_palette.bin

	cnop		0,_chunk_size
_data_herotest_big_palette:
	incbin	"../src/incbin/herotest_big_palette.bin"
_data_herotest_big_palette_pos          equ _data_herotest_big_palette/_chunk_size
_data_herotest_big_palette_length       equ ((_data_herotest_big_palette_end-_data_herotest_big_palette)+(_chunk_size-1))/_chunk_size
_data_herotest_big_palette_end:


; herotest_big_sprite.bin

	cnop		0,_chunk_size
_data_herotest_big_sprite:
	incbin	"../src/incbin/herotest_big_sprite.bin"
_data_herotest_big_sprite_pos           equ _data_herotest_big_sprite/_chunk_size
_data_herotest_big_sprite_length        equ ((_data_herotest_big_sprite_end-_data_herotest_big_sprite)+(_chunk_size-1))/_chunk_size
_data_herotest_big_sprite_end:


; testsprite_sprite_chunky.bin

	cnop		0,_chunk_size
_data_testsprite_sprite_chunky:
	incbin	"../src/incbin/testsprite_sprite_chunky.bin"
_data_testsprite_sprite_chunky_pos      equ _data_testsprite_sprite_chunky/_chunk_size
_data_testsprite_sprite_chunky_length   equ ((_data_testsprite_sprite_chunky_end-_data_testsprite_sprite_chunky)+(_chunk_size-1))/_chunk_size
_data_testsprite_sprite_chunky_end:


; testsprite_sprite_amiga.bin

	cnop		0,_chunk_size
_data_testsprite_sprite_amiga:
	incbin	"../src/incbin/testsprite_sprite_amiga.bin"
_data_testsprite_sprite_amiga_pos       equ _data_testsprite_sprite_amiga/_chunk_size
_data_testsprite_sprite_amiga_length    equ ((_data_testsprite_sprite_amiga_end-_data_testsprite_sprite_amiga)+(_chunk_size-1))/_chunk_size
_data_testsprite_sprite_amiga_end:


; testsprite_palette.bin

	cnop		0,_chunk_size
_data_testsprite_palette:
	incbin	"../src/incbin/testsprite_palette.bin"
_data_testsprite_palette_pos            equ _data_testsprite_palette/_chunk_size
_data_testsprite_palette_length         equ ((_data_testsprite_palette_end-_data_testsprite_palette)+(_chunk_size-1))/_chunk_size
_data_testsprite_palette_end:


; testsprite_sprite.bin

	cnop		0,_chunk_size
_data_testsprite_sprite:
	incbin	"../src/incbin/testsprite_sprite.bin"
_data_testsprite_sprite_pos             equ _data_testsprite_sprite/_chunk_size
_data_testsprite_sprite_length          equ ((_data_testsprite_sprite_end-_data_testsprite_sprite)+(_chunk_size-1))/_chunk_size
_data_testsprite_sprite_end:


; testsprite2_sprite_chunky.bin

	cnop		0,_chunk_size
_data_testsprite2_sprite_chunky:
	incbin	"../src/incbin/testsprite2_sprite_chunky.bin"
_data_testsprite2_sprite_chunky_pos     equ _data_testsprite2_sprite_chunky/_chunk_size
_data_testsprite2_sprite_chunky_length  equ ((_data_testsprite2_sprite_chunky_end-_data_testsprite2_sprite_chunky)+(_chunk_size-1))/_chunk_size
_data_testsprite2_sprite_chunky_end:


; testsprite2_sprite_amiga.bin

	cnop		0,_chunk_size
_data_testsprite2_sprite_amiga:
	incbin	"../src/incbin/testsprite2_sprite_amiga.bin"
_data_testsprite2_sprite_amiga_pos      equ _data_testsprite2_sprite_amiga/_chunk_size
_data_testsprite2_sprite_amiga_length   equ ((_data_testsprite2_sprite_amiga_end-_data_testsprite2_sprite_amiga)+(_chunk_size-1))/_chunk_size
_data_testsprite2_sprite_amiga_end:


; testsprite2_palette.bin

	cnop		0,_chunk_size
_data_testsprite2_palette:
	incbin	"../src/incbin/testsprite2_palette.bin"
_data_testsprite2_palette_pos           equ _data_testsprite2_palette/_chunk_size
_data_testsprite2_palette_length        equ ((_data_testsprite2_palette_end-_data_testsprite2_palette)+(_chunk_size-1))/_chunk_size
_data_testsprite2_palette_end:


; testsprite2_sprite.bin

	cnop		0,_chunk_size
_data_testsprite2_sprite:
	incbin	"../src/incbin/testsprite2_sprite.bin"
_data_testsprite2_sprite_pos            equ _data_testsprite2_sprite/_chunk_size
_data_testsprite2_sprite_length         equ ((_data_testsprite2_sprite_end-_data_testsprite2_sprite)+(_chunk_size-1))/_chunk_size
_data_testsprite2_sprite_end:


; testtiles_bank.bin

	cnop		0,_chunk_size
_data_testtiles_bank:
	incbin	"../src/incbin/testtiles_bank.bin"
_data_testtiles_bank_pos                equ _data_testtiles_bank/_chunk_size
_data_testtiles_bank_length             equ ((_data_testtiles_bank_end-_data_testtiles_bank)+(_chunk_size-1))/_chunk_size
_data_testtiles_bank_end:


; testtiles_bank_amiga.bin

	cnop		0,_chunk_size
_data_testtiles_bank_amiga:
	incbin	"../src/incbin/testtiles_bank_amiga.bin"
_data_testtiles_bank_amiga_pos          equ _data_testtiles_bank_amiga/_chunk_size
_data_testtiles_bank_amiga_length       equ ((_data_testtiles_bank_amiga_end-_data_testtiles_bank_amiga)+(_chunk_size-1))/_chunk_size
_data_testtiles_bank_amiga_end:


; testtiles_map.bin

	cnop		0,_chunk_size
_data_testtiles_map:
	incbin	"../src/incbin/testtiles_map.bin"
_data_testtiles_map_pos                 equ _data_testtiles_map/_chunk_size
_data_testtiles_map_length              equ ((_data_testtiles_map_end-_data_testtiles_map)+(_chunk_size-1))/_chunk_size
_data_testtiles_map_end:


; testtiles_palette.bin

	cnop		0,_chunk_size
_data_testtiles_palette:
	incbin	"../src/incbin/testtiles_palette.bin"
_data_testtiles_palette_pos             equ _data_testtiles_palette/_chunk_size
_data_testtiles_palette_length          equ ((_data_testtiles_palette_end-_data_testtiles_palette)+(_chunk_size-1))/_chunk_size
_data_testtiles_palette_end:


; untitled_splash_bank.bin

	cnop		0,_chunk_size
_data_untitled_splash_bank:
	incbin	"../src/incbin/untitled_splash_bank.bin"
_data_untitled_splash_bank_pos          equ _data_untitled_splash_bank/_chunk_size
_data_untitled_splash_bank_length       equ ((_data_untitled_splash_bank_end-_data_untitled_splash_bank)+(_chunk_size-1))/_chunk_size
_data_untitled_splash_bank_end:


; untitled_splash_bank_amiga.bin

	cnop		0,_chunk_size
_data_untitled_splash_bank_amiga:
	incbin	"../src/incbin/untitled_splash_bank_amiga.bin"
_data_untitled_splash_bank_amiga_pos    equ _data_untitled_splash_bank_amiga/_chunk_size
_data_untitled_splash_bank_amiga_length equ ((_data_untitled_splash_bank_amiga_end-_data_untitled_splash_bank_amiga)+(_chunk_size-1))/_chunk_size
_data_untitled_splash_bank_amiga_end:


; untitled_splash_map.bin

	cnop		0,_chunk_size
_data_untitled_splash_map:
	incbin	"../src/incbin/untitled_splash_map.bin"
_data_untitled_splash_map_pos           equ _data_untitled_splash_map/_chunk_size
_data_untitled_splash_map_length        equ ((_data_untitled_splash_map_end-_data_untitled_splash_map)+(_chunk_size-1))/_chunk_size
_data_untitled_splash_map_end:


; untitled_splash_palette.bin

	cnop		0,_chunk_size
_data_untitled_splash_palette:
	incbin	"../src/incbin/untitled_splash_palette.bin"
_data_untitled_splash_palette_pos       equ _data_untitled_splash_palette/_chunk_size
_data_untitled_splash_palette_length    equ ((_data_untitled_splash_palette_end-_data_untitled_splash_palette)+(_chunk_size-1))/_chunk_size
_data_untitled_splash_palette_end:


; herotestpng_sprite_chunky.bin

	cnop		0,_chunk_size
_data_herotestpng_sprite_chunky:
	incbin	"../src/incbin/herotestpng_sprite_chunky.bin"
_data_herotestpng_sprite_chunky_pos     equ _data_herotestpng_sprite_chunky/_chunk_size
_data_herotestpng_sprite_chunky_length  equ ((_data_herotestpng_sprite_chunky_end-_data_herotestpng_sprite_chunky)+(_chunk_size-1))/_chunk_size
_data_herotestpng_sprite_chunky_end:


; herotestpng_sprite_amiga.bin

	cnop		0,_chunk_size
_data_herotestpng_sprite_amiga:
	incbin	"../src/incbin/herotestpng_sprite_amiga.bin"
_data_herotestpng_sprite_amiga_pos      equ _data_herotestpng_sprite_amiga/_chunk_size
_data_herotestpng_sprite_amiga_length   equ ((_data_herotestpng_sprite_amiga_end-_data_herotestpng_sprite_amiga)+(_chunk_size-1))/_chunk_size
_data_herotestpng_sprite_amiga_end:


; herotestpng_palette.bin

	cnop		0,_chunk_size
_data_herotestpng_palette:
	incbin	"../src/incbin/herotestpng_palette.bin"
_data_herotestpng_palette_pos           equ _data_herotestpng_palette/_chunk_size
_data_herotestpng_palette_length        equ ((_data_herotestpng_palette_end-_data_herotestpng_palette)+(_chunk_size-1))/_chunk_size
_data_herotestpng_palette_end:


; herotestpng_sprite.bin

	cnop		0,_chunk_size
_data_herotestpng_sprite:
	incbin	"../src/incbin/herotestpng_sprite.bin"
_data_herotestpng_sprite_pos            equ _data_herotestpng_sprite/_chunk_size
_data_herotestpng_sprite_length         equ ((_data_herotestpng_sprite_end-_data_herotestpng_sprite)+(_chunk_size-1))/_chunk_size
_data_herotestpng_sprite_end:


; signpost_bank.bin

	cnop		0,_chunk_size
_data_signpost_bank:
	incbin	"../src/incbin/signpost_bank.bin"
_data_signpost_bank_pos                 equ _data_signpost_bank/_chunk_size
_data_signpost_bank_length              equ ((_data_signpost_bank_end-_data_signpost_bank)+(_chunk_size-1))/_chunk_size
_data_signpost_bank_end:


; signpost_bank_amiga.bin

	cnop		0,_chunk_size
_data_signpost_bank_amiga:
	incbin	"../src/incbin/signpost_bank_amiga.bin"
_data_signpost_bank_amiga_pos           equ _data_signpost_bank_amiga/_chunk_size
_data_signpost_bank_amiga_length        equ ((_data_signpost_bank_amiga_end-_data_signpost_bank_amiga)+(_chunk_size-1))/_chunk_size
_data_signpost_bank_amiga_end:


; signpost_map.bin

	cnop		0,_chunk_size
_data_signpost_map:
	incbin	"../src/incbin/signpost_map.bin"
_data_signpost_map_pos                  equ _data_signpost_map/_chunk_size
_data_signpost_map_length               equ ((_data_signpost_map_end-_data_signpost_map)+(_chunk_size-1))/_chunk_size
_data_signpost_map_end:


; signpost_palette.bin

	cnop		0,_chunk_size
_data_signpost_palette:
	incbin	"../src/incbin/signpost_palette.bin"
_data_signpost_palette_pos              equ _data_signpost_palette/_chunk_size
_data_signpost_palette_length           equ ((_data_signpost_palette_end-_data_signpost_palette)+(_chunk_size-1))/_chunk_size
_data_signpost_palette_end:


; testmap_map.bin

	cnop		0,_chunk_size
_data_testmap_map:
	incbin	"../src/incbin/testmap_map.bin"
_data_testmap_map_pos                   equ _data_testmap_map/_chunk_size
_data_testmap_map_length                equ ((_data_testmap_map_end-_data_testmap_map)+(_chunk_size-1))/_chunk_size
_data_testmap_map_end:


; testmap2_map.bin

	cnop		0,_chunk_size
_data_testmap2_map:
	incbin	"../src/incbin/testmap2_map.bin"
_data_testmap2_map_pos                  equ _data_testmap2_map/_chunk_size
_data_testmap2_map_length               equ ((_data_testmap2_map_end-_data_testmap2_map)+(_chunk_size-1))/_chunk_size
_data_testmap2_map_end:
