;
; Will set the border color to index 0 in the palette. Might get modified so the color index is a parameter.
;
perf_start		MACRO
	move.w		#$8700,($00C00004)
	ENDM


;
; Will set the border color to index 1 in the palette. Might get modified so the color index is a parameter.
;
perf_stop		MACRO
	move.w		#$8701,($00C00004)
	ENDM

