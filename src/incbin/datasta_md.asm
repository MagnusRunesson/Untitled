StaticData:


; herotest_sprite.bin

	cnop		0,_chunk_size
_data_herotest_sprite:
	incbin	"../src/incbin/herotest_sprite.bin"
_data_herotest_sprite_pos                                   equ _data_herotest_sprite/_chunk_size
_data_herotest_sprite_length                                equ ((_data_herotest_sprite_end-_data_herotest_sprite)+(_chunk_size-1))/_chunk_size
_data_herotest_sprite_end:


; herotest_big_sprite.bin

	cnop		0,_chunk_size
_data_herotest_big_sprite:
	incbin	"../src/incbin/herotest_big_sprite.bin"
_data_herotest_big_sprite_pos                               equ _data_herotest_big_sprite/_chunk_size
_data_herotest_big_sprite_length                            equ ((_data_herotest_big_sprite_end-_data_herotest_big_sprite)+(_chunk_size-1))/_chunk_size
_data_herotest_big_sprite_end:


; testsprite_sprite.bin

	cnop		0,_chunk_size
_data_testsprite_sprite:
	incbin	"../src/incbin/testsprite_sprite.bin"
_data_testsprite_sprite_pos                                 equ _data_testsprite_sprite/_chunk_size
_data_testsprite_sprite_length                              equ ((_data_testsprite_sprite_end-_data_testsprite_sprite)+(_chunk_size-1))/_chunk_size
_data_testsprite_sprite_end:


; testsprite2_sprite.bin

	cnop		0,_chunk_size
_data_testsprite2_sprite:
	incbin	"../src/incbin/testsprite2_sprite.bin"
_data_testsprite2_sprite_pos                                equ _data_testsprite2_sprite/_chunk_size
_data_testsprite2_sprite_length                             equ ((_data_testsprite2_sprite_end-_data_testsprite2_sprite)+(_chunk_size-1))/_chunk_size
_data_testsprite2_sprite_end:


; herotestpng_sprite.bin

	cnop		0,_chunk_size
_data_herotestpng_sprite:
	incbin	"../src/incbin/herotestpng_sprite.bin"
_data_herotestpng_sprite_pos                                equ _data_herotestpng_sprite/_chunk_size
_data_herotestpng_sprite_length                             equ ((_data_herotestpng_sprite_end-_data_herotestpng_sprite)+(_chunk_size-1))/_chunk_size
_data_herotestpng_sprite_end:


; signpost_sprite.bin

	cnop		0,_chunk_size
_data_signpost_sprite:
	incbin	"../src/incbin/signpost_sprite.bin"
_data_signpost_sprite_pos                                   equ _data_signpost_sprite/_chunk_size
_data_signpost_sprite_length                                equ ((_data_signpost_sprite_end-_data_signpost_sprite)+(_chunk_size-1))/_chunk_size
_data_signpost_sprite_end:


; stoneblock_sprite.bin

	cnop		0,_chunk_size
_data_stoneblock_sprite:
	incbin	"../src/incbin/stoneblock_sprite.bin"
_data_stoneblock_sprite_pos                                 equ _data_stoneblock_sprite/_chunk_size
_data_stoneblock_sprite_length                              equ ((_data_stoneblock_sprite_end-_data_stoneblock_sprite)+(_chunk_size-1))/_chunk_size
_data_stoneblock_sprite_end:


; overworld_goc.bin

	cnop		0,_chunk_size
_data_overworld_goc:
	incbin	"../src/incbin/overworld_goc.bin"
_data_overworld_goc_pos                                     equ _data_overworld_goc/_chunk_size
_data_overworld_goc_length                                  equ ((_data_overworld_goc_end-_data_overworld_goc)+(_chunk_size-1))/_chunk_size
_data_overworld_goc_end:
