StaticData:


; overworld_goc.bin

	cnop		0,4
_data_overworld_goc:
	incbin	"../src/incbin/overworld_goc.bin"
_data_overworld_goc_pos                                     equ (_data_overworld_goc-StaticData)


; dungeon_01_rc.bin

	cnop		0,4
_data_dungeon_01_rc:
	incbin	"../src/incbin/dungeon_01_rc.bin"
_data_dungeon_01_rc_pos                                     equ (_data_dungeon_01_rc-StaticData)


; overworld_rc.bin

	cnop		0,4
_data_overworld_rc:
	incbin	"../src/incbin/overworld_rc.bin"
_data_overworld_rc_pos                                      equ (_data_overworld_rc-StaticData)
