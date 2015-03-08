

; collisionsprite_bank.bin

	cnop		0,_chunk_size
_data_collisionsprite_bank:
	incbin	"../src/incbin/collisionsprite_bank.bin"
_data_collisionsprite_bank_pos                              equ _data_collisionsprite_bank/_chunk_size
_data_collisionsprite_bank_length                           equ ((_data_collisionsprite_bank_end-_data_collisionsprite_bank)+(_chunk_size-1))/_chunk_size
_data_collisionsprite_bank_end:


; collisionsprite_map.bin

	cnop		0,_chunk_size
_data_collisionsprite_map:
	incbin	"../src/incbin/collisionsprite_map.bin"
_data_collisionsprite_map_pos                               equ _data_collisionsprite_map/_chunk_size
_data_collisionsprite_map_length                            equ ((_data_collisionsprite_map_end-_data_collisionsprite_map)+(_chunk_size-1))/_chunk_size
_data_collisionsprite_map_end:


; collisionsprite_palette.bin

	cnop		0,_chunk_size
_data_collisionsprite_palette:
	incbin	"../src/incbin/collisionsprite_palette.bin"
_data_collisionsprite_palette_pos                           equ _data_collisionsprite_palette/_chunk_size
_data_collisionsprite_palette_length                        equ ((_data_collisionsprite_palette_end-_data_collisionsprite_palette)+(_chunk_size-1))/_chunk_size
_data_collisionsprite_palette_end:


; collisiontiles_bank.bin

	cnop		0,_chunk_size
_data_collisiontiles_bank:
	incbin	"../src/incbin/collisiontiles_bank.bin"
_data_collisiontiles_bank_pos                               equ _data_collisiontiles_bank/_chunk_size
_data_collisiontiles_bank_length                            equ ((_data_collisiontiles_bank_end-_data_collisiontiles_bank)+(_chunk_size-1))/_chunk_size
_data_collisiontiles_bank_end:


; collisiontiles_map.bin

	cnop		0,_chunk_size
_data_collisiontiles_map:
	incbin	"../src/incbin/collisiontiles_map.bin"
_data_collisiontiles_map_pos                                equ _data_collisiontiles_map/_chunk_size
_data_collisiontiles_map_length                             equ ((_data_collisiontiles_map_end-_data_collisiontiles_map)+(_chunk_size-1))/_chunk_size
_data_collisiontiles_map_end:


; collisiontiles_palette.bin

	cnop		0,_chunk_size
_data_collisiontiles_palette:
	incbin	"../src/incbin/collisiontiles_palette.bin"
_data_collisiontiles_palette_pos                            equ _data_collisiontiles_palette/_chunk_size
_data_collisiontiles_palette_length                         equ ((_data_collisiontiles_palette_end-_data_collisiontiles_palette)+(_chunk_size-1))/_chunk_size
_data_collisiontiles_palette_end:


; herotest_sprite_bank.bin

	cnop		0,_chunk_size
_data_herotest_sprite_bank:
	incbin	"../src/incbin/herotest_sprite_bank.bin"
_data_herotest_sprite_bank_pos                              equ _data_herotest_sprite_bank/_chunk_size
_data_herotest_sprite_bank_length                           equ ((_data_herotest_sprite_bank_end-_data_herotest_sprite_bank)+(_chunk_size-1))/_chunk_size
_data_herotest_sprite_bank_end:


; herotest_palette.bin

	cnop		0,_chunk_size
_data_herotest_palette:
	incbin	"../src/incbin/herotest_palette.bin"
_data_herotest_palette_pos                                  equ _data_herotest_palette/_chunk_size
_data_herotest_palette_length                               equ ((_data_herotest_palette_end-_data_herotest_palette)+(_chunk_size-1))/_chunk_size
_data_herotest_palette_end:


; herotest_big_sprite_bank.bin

	cnop		0,_chunk_size
_data_herotest_big_sprite_bank:
	incbin	"../src/incbin/herotest_big_sprite_bank.bin"
_data_herotest_big_sprite_bank_pos                          equ _data_herotest_big_sprite_bank/_chunk_size
_data_herotest_big_sprite_bank_length                       equ ((_data_herotest_big_sprite_bank_end-_data_herotest_big_sprite_bank)+(_chunk_size-1))/_chunk_size
_data_herotest_big_sprite_bank_end:


; herotest_big_palette.bin

	cnop		0,_chunk_size
_data_herotest_big_palette:
	incbin	"../src/incbin/herotest_big_palette.bin"
_data_herotest_big_palette_pos                              equ _data_herotest_big_palette/_chunk_size
_data_herotest_big_palette_length                           equ ((_data_herotest_big_palette_end-_data_herotest_big_palette)+(_chunk_size-1))/_chunk_size
_data_herotest_big_palette_end:


; testsprite_sprite_bank.bin

	cnop		0,_chunk_size
_data_testsprite_sprite_bank:
	incbin	"../src/incbin/testsprite_sprite_bank.bin"
_data_testsprite_sprite_bank_pos                            equ _data_testsprite_sprite_bank/_chunk_size
_data_testsprite_sprite_bank_length                         equ ((_data_testsprite_sprite_bank_end-_data_testsprite_sprite_bank)+(_chunk_size-1))/_chunk_size
_data_testsprite_sprite_bank_end:


; testsprite_palette.bin

	cnop		0,_chunk_size
_data_testsprite_palette:
	incbin	"../src/incbin/testsprite_palette.bin"
_data_testsprite_palette_pos                                equ _data_testsprite_palette/_chunk_size
_data_testsprite_palette_length                             equ ((_data_testsprite_palette_end-_data_testsprite_palette)+(_chunk_size-1))/_chunk_size
_data_testsprite_palette_end:


; testsprite2_sprite_bank.bin

	cnop		0,_chunk_size
_data_testsprite2_sprite_bank:
	incbin	"../src/incbin/testsprite2_sprite_bank.bin"
_data_testsprite2_sprite_bank_pos                           equ _data_testsprite2_sprite_bank/_chunk_size
_data_testsprite2_sprite_bank_length                        equ ((_data_testsprite2_sprite_bank_end-_data_testsprite2_sprite_bank)+(_chunk_size-1))/_chunk_size
_data_testsprite2_sprite_bank_end:


; testsprite2_palette.bin

	cnop		0,_chunk_size
_data_testsprite2_palette:
	incbin	"../src/incbin/testsprite2_palette.bin"
_data_testsprite2_palette_pos                               equ _data_testsprite2_palette/_chunk_size
_data_testsprite2_palette_length                            equ ((_data_testsprite2_palette_end-_data_testsprite2_palette)+(_chunk_size-1))/_chunk_size
_data_testsprite2_palette_end:


; testtiles_bank.bin

	cnop		0,_chunk_size
_data_testtiles_bank:
	incbin	"../src/incbin/testtiles_bank.bin"
_data_testtiles_bank_pos                                    equ _data_testtiles_bank/_chunk_size
_data_testtiles_bank_length                                 equ ((_data_testtiles_bank_end-_data_testtiles_bank)+(_chunk_size-1))/_chunk_size
_data_testtiles_bank_end:


; testtiles_map.bin

	cnop		0,_chunk_size
_data_testtiles_map:
	incbin	"../src/incbin/testtiles_map.bin"
_data_testtiles_map_pos                                     equ _data_testtiles_map/_chunk_size
_data_testtiles_map_length                                  equ ((_data_testtiles_map_end-_data_testtiles_map)+(_chunk_size-1))/_chunk_size
_data_testtiles_map_end:


; testtiles_palette.bin

	cnop		0,_chunk_size
_data_testtiles_palette:
	incbin	"../src/incbin/testtiles_palette.bin"
_data_testtiles_palette_pos                                 equ _data_testtiles_palette/_chunk_size
_data_testtiles_palette_length                              equ ((_data_testtiles_palette_end-_data_testtiles_palette)+(_chunk_size-1))/_chunk_size
_data_testtiles_palette_end:


; untitled_splash_bank.bin

	cnop		0,_chunk_size
_data_untitled_splash_bank:
	incbin	"../src/incbin/untitled_splash_bank.bin"
_data_untitled_splash_bank_pos                              equ _data_untitled_splash_bank/_chunk_size
_data_untitled_splash_bank_length                           equ ((_data_untitled_splash_bank_end-_data_untitled_splash_bank)+(_chunk_size-1))/_chunk_size
_data_untitled_splash_bank_end:


; untitled_splash_map.bin

	cnop		0,_chunk_size
_data_untitled_splash_map:
	incbin	"../src/incbin/untitled_splash_map.bin"
_data_untitled_splash_map_pos                               equ _data_untitled_splash_map/_chunk_size
_data_untitled_splash_map_length                            equ ((_data_untitled_splash_map_end-_data_untitled_splash_map)+(_chunk_size-1))/_chunk_size
_data_untitled_splash_map_end:


; untitled_splash_palette.bin

	cnop		0,_chunk_size
_data_untitled_splash_palette:
	incbin	"../src/incbin/untitled_splash_palette.bin"
_data_untitled_splash_palette_pos                           equ _data_untitled_splash_palette/_chunk_size
_data_untitled_splash_palette_length                        equ ((_data_untitled_splash_palette_end-_data_untitled_splash_palette)+(_chunk_size-1))/_chunk_size
_data_untitled_splash_palette_end:


; herotestpng_sprite_bank.bin

	cnop		0,_chunk_size
_data_herotestpng_sprite_bank:
	incbin	"../src/incbin/herotestpng_sprite_bank.bin"
_data_herotestpng_sprite_bank_pos                           equ _data_herotestpng_sprite_bank/_chunk_size
_data_herotestpng_sprite_bank_length                        equ ((_data_herotestpng_sprite_bank_end-_data_herotestpng_sprite_bank)+(_chunk_size-1))/_chunk_size
_data_herotestpng_sprite_bank_end:


; herotestpng_palette.bin

	cnop		0,_chunk_size
_data_herotestpng_palette:
	incbin	"../src/incbin/herotestpng_palette.bin"
_data_herotestpng_palette_pos                               equ _data_herotestpng_palette/_chunk_size
_data_herotestpng_palette_length                            equ ((_data_herotestpng_palette_end-_data_herotestpng_palette)+(_chunk_size-1))/_chunk_size
_data_herotestpng_palette_end:


; housetiles_bank.bin

	cnop		0,_chunk_size
_data_housetiles_bank:
	incbin	"../src/incbin/housetiles_bank.bin"
_data_housetiles_bank_pos                                   equ _data_housetiles_bank/_chunk_size
_data_housetiles_bank_length                                equ ((_data_housetiles_bank_end-_data_housetiles_bank)+(_chunk_size-1))/_chunk_size
_data_housetiles_bank_end:


; housetiles_map.bin

	cnop		0,_chunk_size
_data_housetiles_map:
	incbin	"../src/incbin/housetiles_map.bin"
_data_housetiles_map_pos                                    equ _data_housetiles_map/_chunk_size
_data_housetiles_map_length                                 equ ((_data_housetiles_map_end-_data_housetiles_map)+(_chunk_size-1))/_chunk_size
_data_housetiles_map_end:


; housetiles_palette.bin

	cnop		0,_chunk_size
_data_housetiles_palette:
	incbin	"../src/incbin/housetiles_palette.bin"
_data_housetiles_palette_pos                                equ _data_housetiles_palette/_chunk_size
_data_housetiles_palette_length                             equ ((_data_housetiles_palette_end-_data_housetiles_palette)+(_chunk_size-1))/_chunk_size
_data_housetiles_palette_end:


; signpost_sprite_bank.bin

	cnop		0,_chunk_size
_data_signpost_sprite_bank:
	incbin	"../src/incbin/signpost_sprite_bank.bin"
_data_signpost_sprite_bank_pos                              equ _data_signpost_sprite_bank/_chunk_size
_data_signpost_sprite_bank_length                           equ ((_data_signpost_sprite_bank_end-_data_signpost_sprite_bank)+(_chunk_size-1))/_chunk_size
_data_signpost_sprite_bank_end:


; signpost_palette.bin

	cnop		0,_chunk_size
_data_signpost_palette:
	incbin	"../src/incbin/signpost_palette.bin"
_data_signpost_palette_pos                                  equ _data_signpost_palette/_chunk_size
_data_signpost_palette_length                               equ ((_data_signpost_palette_end-_data_signpost_palette)+(_chunk_size-1))/_chunk_size
_data_signpost_palette_end:


; stoneblock_sprite_bank.bin

	cnop		0,_chunk_size
_data_stoneblock_sprite_bank:
	incbin	"../src/incbin/stoneblock_sprite_bank.bin"
_data_stoneblock_sprite_bank_pos                            equ _data_stoneblock_sprite_bank/_chunk_size
_data_stoneblock_sprite_bank_length                         equ ((_data_stoneblock_sprite_bank_end-_data_stoneblock_sprite_bank)+(_chunk_size-1))/_chunk_size
_data_stoneblock_sprite_bank_end:


; stoneblock_palette.bin

	cnop		0,_chunk_size
_data_stoneblock_palette:
	incbin	"../src/incbin/stoneblock_palette.bin"
_data_stoneblock_palette_pos                                equ _data_stoneblock_palette/_chunk_size
_data_stoneblock_palette_length                             equ ((_data_stoneblock_palette_end-_data_stoneblock_palette)+(_chunk_size-1))/_chunk_size
_data_stoneblock_palette_end:


; testmap_map.bin

	cnop		0,_chunk_size
_data_testmap_map:
	incbin	"../src/incbin/testmap_map.bin"
_data_testmap_map_pos                                       equ _data_testmap_map/_chunk_size
_data_testmap_map_length                                    equ ((_data_testmap_map_end-_data_testmap_map)+(_chunk_size-1))/_chunk_size
_data_testmap_map_end:


; testmap_collisionmap.bin

	cnop		0,_chunk_size
_data_testmap_collisionmap:
	incbin	"../src/incbin/testmap_collisionmap.bin"
_data_testmap_collisionmap_pos                              equ _data_testmap_collisionmap/_chunk_size
_data_testmap_collisionmap_length                           equ ((_data_testmap_collisionmap_end-_data_testmap_collisionmap)+(_chunk_size-1))/_chunk_size
_data_testmap_collisionmap_end:


; testmap2_map.bin

	cnop		0,_chunk_size
_data_testmap2_map:
	incbin	"../src/incbin/testmap2_map.bin"
_data_testmap2_map_pos                                      equ _data_testmap2_map/_chunk_size
_data_testmap2_map_length                                   equ ((_data_testmap2_map_end-_data_testmap2_map)+(_chunk_size-1))/_chunk_size
_data_testmap2_map_end:


; testmap2_collisionmap.bin

	cnop		0,_chunk_size
_data_testmap2_collisionmap:
	incbin	"../src/incbin/testmap2_collisionmap.bin"
_data_testmap2_collisionmap_pos                             equ _data_testmap2_collisionmap/_chunk_size
_data_testmap2_collisionmap_length                          equ ((_data_testmap2_collisionmap_end-_data_testmap2_collisionmap)+(_chunk_size-1))/_chunk_size
_data_testmap2_collisionmap_end:
