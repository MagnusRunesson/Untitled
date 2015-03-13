StaticData:


; testmap_collisionmap.bin

	cnop		0,4
_data_testmap_collisionmap:
	incbin	"../src/incbin/testmap_collisionmap.bin"
_data_testmap_collisionmap_pos                              equ (_data_testmap_collisionmap-StaticData)


; testmap2_collisionmap.bin

	cnop		0,4
_data_testmap2_collisionmap:
	incbin	"../src/incbin/testmap2_collisionmap.bin"
_data_testmap2_collisionmap_pos                             equ (_data_testmap2_collisionmap-StaticData)


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
