StaticData:


; overworld_goc.bin

	cnop		0,_chunk_size
_data_overworld_goc:
	incbin	"../src/incbin/overworld_goc.bin"
_data_overworld_goc_pos                                     equ _data_overworld_goc/_chunk_size
_data_overworld_goc_length                                  equ ((_data_overworld_goc_end-_data_overworld_goc)+(_chunk_size-1))/_chunk_size
_data_overworld_goc_end:
