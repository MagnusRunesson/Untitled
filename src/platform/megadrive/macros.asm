perf_start		MACRO
	move.w		#$8700,($00C00004)
	ENDM


perf_stop		MACRO
	move.w		#$8701,($00C00004)
	ENDM

