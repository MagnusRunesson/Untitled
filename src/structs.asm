
;==============================================================================
;
; Sprite struct and constants
;
;==============================================================================

spritefile_flag_isspriteb_bit	equ		(0)
spritefile_flag_isspriteb_mask	equ		(1<<0)

								rsreset
spritefile_struct_width			rs.b	1
spritefile_struct_height		rs.b	1
spritefile_struct_num_frames	rs.b	1
spritefile_struct_flags			rs.b	1
spritefile_struct_sizeof		rs.b	0

