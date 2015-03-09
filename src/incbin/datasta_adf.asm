StaticData:


; overworld_goc.bin

	cnop		0,_chunk_size
_data_overworld_goc:
	incbin	"../src/incbin/overworld_goc.bin"
_data_overworld_goc_pos                                     equ _data_overworld_goc/_chunk_size
_data_overworld_goc_length                                  equ ((_data_overworld_goc_end-_data_overworld_goc)+(_chunk_size-1))/_chunk_size
_data_overworld_goc_end:


; dungeon_01_rc.bin

	cnop		0,_chunk_size
_data_dungeon_01_rc:
	incbin	"../src/incbin/dungeon_01_rc.bin"
_data_dungeon_01_rc_pos                                     equ _data_dungeon_01_rc/_chunk_size
_data_dungeon_01_rc_length                                  equ ((_data_dungeon_01_rc_end-_data_dungeon_01_rc)+(_chunk_size-1))/_chunk_size
_data_dungeon_01_rc_end:


; overworld_rc.bin

	cnop		0,_chunk_size
_data_overworld_rc:
	incbin	"../src/incbin/overworld_rc.bin"
_data_overworld_rc_pos                                      equ _data_overworld_rc/_chunk_size
_data_overworld_rc_length                                   equ ((_data_overworld_rc_end-_data_overworld_rc)+(_chunk_size-1))/_chunk_size
_data_overworld_rc_end:
